import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Phases of the live Saturday Acapella Challenge.
enum ArenaPhase { lobby, chorusPreview, beatCutOff, contestantTurn, voting, results }

/// A real participant currently present in the arena (from Supabase Presence).
class ArenaPeer {
  final String id;
  final String name;
  final String emoji;
  final String rank;
  final String city;
  final int joinedAt;

  const ArenaPeer({
    required this.id,
    required this.name,
    required this.emoji,
    required this.rank,
    required this.city,
    required this.joinedAt,
  });

  factory ArenaPeer.fromPayload(Map<String, dynamic> p) => ArenaPeer(
        id: p['peer_id']?.toString() ?? '',
        name: p['name']?.toString() ?? 'Guest',
        emoji: p['emoji']?.toString() ?? '🎤',
        rank: p['rank']?.toString() ?? '',
        city: p['city']?.toString() ?? '',
        joinedAt: (p['joined_at'] as num?)?.toInt() ?? 0,
      );
}

/// Live, multi-device Acapella Arena.
///
/// * **Supabase Presence** → who is really in the arena (no simulated bots).
/// * **Supabase Broadcast** → WebRTC signaling, host-driven phase timeline, votes.
/// * **flutter_webrtc** → peer-to-peer mesh carrying live camera + microphone.
///
/// Only the contestant whose turn it is has an open mic; everyone else is muted,
/// so the whole room hears exactly one live singer in real time.
class AcapellaArenaService extends ChangeNotifier {
  static const int maxParticipants = 6; // full-mesh P2P limit for mobile networks
  static const int maxContestants = 4;
  static const int chorusMs = 15000;
  static const int cutOffMs = 3000;
  static const int turnMs = 18000;
  static const int votingMs = 20000;

  final String roomId;
  final Map<String, dynamic> _profile;
  late final String localPeerId;

  SupabaseClient? _client;
  RealtimeChannel? _channel;
  bool _disposed = false;

  // ---- Media ----
  MediaStream? localStream;
  final RTCVideoRenderer localRenderer = RTCVideoRenderer();
  final Map<String, RTCPeerConnection> _pcs = {};
  final Map<String, RTCVideoRenderer> remoteRenderers = {};
  final Map<String, List<RTCIceCandidate>> _pendingRemoteIce = {};
  final Map<String, List<Map<String, dynamic>>> _outgoingIce = {};
  Timer? _iceFlushTimer;
  Timer? _statsTimer;

  // ---- Shared state ----
  List<ArenaPeer> peers = [];
  ArenaPhase phase = ArenaPhase.lobby;
  List<String> turnOrder = [];
  int turnIndex = 0;
  DateTime? phaseEndsAt;
  Map<String, dynamic>? track; // {id,title,artist,audio}
  final Map<String, String> votes = {}; // voterId -> contestantId
  final Map<String, double> audioLevels = {}; // peerId -> 0..1
  final Map<String, Map<String, dynamic>> _knownProfiles = {}; // keep names of contestants who left

  // ---- Status ----
  bool connected = false;
  bool mediaReady = false;
  String? mediaError;
  String? error;
  bool arenaFull = false;

  Timer? _hostTimer;

  /// Fires when a new phase begins (UI uses it for sounds/chorus audio).
  final StreamController<ArenaPhase> phaseChanges = StreamController<ArenaPhase>.broadcast();

  AcapellaArenaService({required this.roomId, required Map<String, dynamic> profile})
      : _profile = profile {
    try {
      _client = Supabase.instance.client;
    } catch (_) {
      _client = null;
    }
    final uid = _client?.auth.currentUser?.id ?? 'guest';
    final rnd = math.Random().nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0');
    localPeerId = '${uid}_$rnd';
  }

  // ===================================================================
  // Getters
  // ===================================================================

  bool get isHost => peers.isNotEmpty && peers.first.id == localPeerId;

  ArenaPeer? peerById(String id) {
    for (final p in peers) {
      if (p.id == id) return p;
    }
    final known = _knownProfiles[id];
    return known == null ? null : ArenaPeer.fromPayload(known);
  }

  bool isPresent(String id) => peers.any((p) => p.id == id);

  String? get hotMicPeerId =>
      phase == ArenaPhase.contestantTurn && turnIndex < turnOrder.length ? turnOrder[turnIndex] : null;

  bool get isMyTurn => hotMicPeerId == localPeerId;

  bool get amContestant => turnOrder.contains(localPeerId);

  int get secondsRemaining {
    final end = phaseEndsAt;
    if (end == null) return 0;
    final ms = end.difference(DateTime.now()).inMilliseconds;
    return ms <= 0 ? 0 : (ms / 1000).ceil();
  }

  /// Contestants shown on the stage grid. In the lobby this is everyone present.
  List<String> get stageIds =>
      phase == ArenaPhase.lobby ? peers.map((p) => p.id).toList() : List.of(turnOrder);

  Map<String, int> get voteTally {
    final tally = <String, int>{for (final id in turnOrder) id: 0};
    for (final target in votes.values) {
      tally[target] = (tally[target] ?? 0) + 1;
    }
    return tally;
  }

  // ===================================================================
  // Lifecycle
  // ===================================================================

  Future<void> start() async {
    if (_client == null) {
      error = 'Live Arena needs an internet connection to Supabase. Please reconnect and try again.';
      _notify();
      return;
    }
    await _openMedia();
    _joinChannel();
    _statsTimer = Timer.periodic(const Duration(milliseconds: 350), (_) => _pollAudioLevels());
  }

  Future<void> _openMedia() async {
    try {
      await localRenderer.initialize();
      localStream = await navigator.mediaDevices.getUserMedia({
        'audio': {
          'echoCancellation': true,
          'noiseSuppression': false, // keeps sustained sung notes natural
          'autoGainControl': true,
        },
        'video': {
          'facingMode': 'user',
          'width': 320,
          'height': 240,
          'frameRate': 15,
        },
      });
      localRenderer.srcObject = localStream;
      _applyMicGate(); // mic muted until it is your turn
      mediaReady = true;
      try {
        await Helper.setSpeakerphoneOn(true); // play singers on loudspeaker, not earpiece
      } catch (_) {}
    } catch (e) {
      mediaError = 'Microphone/camera permission denied. Enable them in Settings to sing. ($e)';
      debugPrint('[Arena] getUserMedia failed: $e');
    }
    _notify();
  }

  void _joinChannel() {
    final ch = _client!.channel(
      'acapella_arena:$roomId',
      opts: RealtimeChannelConfig(key: localPeerId, self: false),
    );
    _channel = ch;

    ch.onPresenceSync((_) => _onPresenceChanged());
    ch.onBroadcast(event: 'signal', callback: (raw) => _onSignal(_unwrap(raw)));
    ch.onBroadcast(event: 'phase', callback: (raw) => _onPhase(_unwrap(raw)));
    ch.onBroadcast(event: 'vote', callback: (raw) => _onVote(_unwrap(raw)));
    ch.onBroadcast(event: 'state_request', callback: (raw) => _onStateRequest(_unwrap(raw)));
    ch.onBroadcast(event: 'advance_request', callback: (raw) => _onAdvanceRequest(_unwrap(raw)));
    ch.onBroadcast(event: 'track_select', callback: (raw) => _onTrackSelect(_unwrap(raw)));

    ch.subscribe((status, err) async {
      if (status == RealtimeSubscribeStatus.subscribed) {
        connected = true;
        error = null;
        await ch.track({
          'peer_id': localPeerId,
          'name': _profile['name'],
          'emoji': _profile['emoji'],
          'rank': _profile['rank'],
          'city': _profile['city'],
          'joined_at': DateTime.now().millisecondsSinceEpoch,
        });
        // Ask the host for the current timeline (late joiners).
        _send('state_request', {'from': localPeerId});
      } else if (status == RealtimeSubscribeStatus.channelError ||
          status == RealtimeSubscribeStatus.timedOut) {
        connected = false;
        error = 'Realtime connection lost. Reconnecting… ${err ?? ''}';
      } else if (status == RealtimeSubscribeStatus.closed) {
        connected = false;
      }
      _notify();
    });
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _hostTimer?.cancel();
    _statsTimer?.cancel();
    _iceFlushTimer?.cancel();
    try {
      await _channel?.untrack();
    } catch (_) {}
    if (_channel != null) {
      try {
        await _client?.removeChannel(_channel!);
      } catch (_) {}
    }
    for (final pc in _pcs.values) {
      try {
        await pc.close();
      } catch (_) {}
    }
    _pcs.clear();
    for (final r in remoteRenderers.values) {
      r.srcObject = null;
      await r.dispose();
    }
    remoteRenderers.clear();
    try {
      localStream?.getTracks().forEach((t) => t.stop());
      await localStream?.dispose();
    } catch (_) {}
    localRenderer.srcObject = null;
    await localRenderer.dispose();
    try {
      await Helper.setSpeakerphoneOn(false);
    } catch (_) {}
    await phaseChanges.close();
    super.dispose();
  }

  // ===================================================================
  // Presence → real participant list + mesh management
  // ===================================================================

  void _onPresenceChanged() {
    final ch = _channel;
    if (ch == null) return;
    final list = <ArenaPeer>[];
    for (final state in ch.presenceState()) {
      if (state.presences.isEmpty) continue;
      final payload = state.presences.first.payload;
      final peer = ArenaPeer.fromPayload(payload);
      if (peer.id.isEmpty) continue;
      _knownProfiles[peer.id] = Map<String, dynamic>.from(payload);
      list.add(peer);
    }
    list.sort((a, b) {
      final c = a.joinedAt.compareTo(b.joinedAt);
      return c != 0 ? c : a.id.compareTo(b.id);
    });

    // Enforce the P2P mesh cap: only the first N arrivals take part.
    final myIndex = list.indexWhere((p) => p.id == localPeerId);
    arenaFull = myIndex >= maxParticipants;
    peers = list.take(maxParticipants).toList();

    if (!arenaFull) {
      final ids = peers.map((p) => p.id).toSet();
      // Close connections to peers who left.
      for (final id in _pcs.keys.toList()) {
        if (!ids.contains(id)) _closePeer(id);
      }
      // Deterministic initiator: lower id creates the offer (prevents glare).
      for (final p in peers) {
        if (p.id == localPeerId || _pcs.containsKey(p.id)) continue;
        if (localPeerId.compareTo(p.id) < 0) _callPeer(p.id);
      }
    }

    // Host hand-over: if the previous host left mid-show, resume the timeline.
    if (isHost && phase != ArenaPhase.lobby && phase != ArenaPhase.results) {
      _scheduleHostAdvance();
    }
    _notify();
  }

  // ===================================================================
  // WebRTC
  // ===================================================================

  static const String _turnUrl = String.fromEnvironment('TURN_URL');
  static const String _turnUser = String.fromEnvironment('TURN_USERNAME');
  static const String _turnPass = String.fromEnvironment('TURN_CREDENTIAL');

  Map<String, dynamic> get _rtcConfig => {
        'iceServers': [
          {
            'urls': [
              'stun:stun.l.google.com:19302',
              'stun:stun1.l.google.com:19302',
              'stun:stun2.l.google.com:19302',
            ]
          },
          if (_turnUrl.isNotEmpty) {'urls': _turnUrl, 'username': _turnUser, 'credential': _turnPass},
        ],
        'sdpSemantics': 'unified-plan',
      };

  Future<RTCPeerConnection> _createPeer(String remoteId) async {
    final pc = await createPeerConnection(_rtcConfig);
    _pcs[remoteId] = pc;

    final stream = localStream;
    if (stream != null) {
      for (final t in stream.getTracks()) {
        await pc.addTrack(t, stream);
      }
    } else {
      // No local media (permission denied) → still receive the singers.
      await pc.addTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeAudio,
        init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly),
      );
      await pc.addTransceiver(
        kind: RTCRtpMediaType.RTCRtpMediaTypeVideo,
        init: RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly),
      );
    }

    pc.onIceCandidate = (c) {
      if (c.candidate == null) return;
      (_outgoingIce[remoteId] ??= []).add({
        'candidate': c.candidate,
        'sdpMid': c.sdpMid,
        'sdpMLineIndex': c.sdpMLineIndex,
      });
      // Batch candidates to stay well under Realtime message rate limits.
      _iceFlushTimer ??= Timer(const Duration(milliseconds: 250), _flushIce);
    };

    pc.onTrack = (event) async {
      if (event.streams.isEmpty) return;
      var renderer = remoteRenderers[remoteId];
      if (renderer == null) {
        renderer = RTCVideoRenderer();
        await renderer.initialize();
        remoteRenderers[remoteId] = renderer;
      }
      renderer.srcObject = event.streams.first;
      _notify();
    };

    pc.onConnectionState = (state) {
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed) {
        // Retry once from the initiator side.
        if (localPeerId.compareTo(remoteId) < 0 && isPresent(remoteId)) {
          _closePeer(remoteId);
          _callPeer(remoteId);
        }
      }
      _notify();
    };
    return pc;
  }

  Future<void> _callPeer(String remoteId) async {
    try {
      final pc = await _createPeer(remoteId);
      final offer = await pc.createOffer({});
      await pc.setLocalDescription(offer);
      _send('signal', {
        'from': localPeerId,
        'to': remoteId,
        'kind': 'offer',
        'sdp': offer.sdp,
        'type': offer.type,
      });
    } catch (e) {
      debugPrint('[Arena] offer to $remoteId failed: $e');
    }
  }

  Future<void> _onSignal(Map<String, dynamic> msg) async {
    if (msg['to'] != localPeerId || arenaFull) return;
    final from = msg['from']?.toString();
    if (from == null) return;
    try {
      switch (msg['kind']) {
        case 'offer':
          if (_pcs.containsKey(from)) _closePeer(from); // fresh renegotiation
          final pc = await _createPeer(from);
          await pc.setRemoteDescription(RTCSessionDescription(msg['sdp'], msg['type']));
          await _drainPendingIce(from);
          final answer = await pc.createAnswer({});
          await pc.setLocalDescription(answer);
          _send('signal', {
            'from': localPeerId,
            'to': from,
            'kind': 'answer',
            'sdp': answer.sdp,
            'type': answer.type,
          });
          break;
        case 'answer':
          final pc = _pcs[from];
          if (pc == null) return;
          await pc.setRemoteDescription(RTCSessionDescription(msg['sdp'], msg['type']));
          await _drainPendingIce(from);
          break;
        case 'ice':
          final list = (msg['candidates'] as List?) ?? const [];
          for (final raw in list) {
            final m = Map<String, dynamic>.from(raw as Map);
            final cand = RTCIceCandidate(
              m['candidate'] as String?,
              m['sdpMid'] as String?,
              (m['sdpMLineIndex'] as num?)?.toInt(),
            );
            final pc = _pcs[from];
            final hasRemote = pc != null && (await pc.getRemoteDescription()) != null;
            if (hasRemote) {
              await pc.addCandidate(cand);
            } else {
              (_pendingRemoteIce[from] ??= []).add(cand);
            }
          }
          break;
      }
    } catch (e) {
      debugPrint('[Arena] signal ${msg['kind']} from $from failed: $e');
    }
  }

  Future<void> _drainPendingIce(String remoteId) async {
    final pc = _pcs[remoteId];
    final pending = _pendingRemoteIce.remove(remoteId);
    if (pc == null || pending == null) return;
    for (final c in pending) {
      try {
        await pc.addCandidate(c);
      } catch (_) {}
    }
  }

  void _flushIce() {
    _iceFlushTimer = null;
    final batch = Map<String, List<Map<String, dynamic>>>.from(_outgoingIce);
    _outgoingIce.clear();
    batch.forEach((to, cands) {
      if (cands.isEmpty) return;
      _send('signal', {'from': localPeerId, 'to': to, 'kind': 'ice', 'candidates': cands});
    });
  }

  void _closePeer(String id) {
    final pc = _pcs.remove(id);
    pc?.close();
    final r = remoteRenderers.remove(id);
    if (r != null) {
      r.srcObject = null;
      r.dispose();
    }
    _pendingRemoteIce.remove(id);
    audioLevels.remove(id);
  }

  /// Only the singer whose turn it is transmits audio. Spectators keep video off.
  void _applyMicGate() {
    final stream = localStream;
    if (stream == null) return;
    final micOpen = isMyTurn;
    for (final t in stream.getAudioTracks()) {
      t.enabled = micOpen;
    }
    final showVideo = phase == ArenaPhase.lobby || amContestant;
    for (final t in stream.getVideoTracks()) {
      t.enabled = showVideo;
    }
  }

  /// Real audio levels from WebRTC stats → live meters on each tile.
  Future<void> _pollAudioLevels() async {
    if (_disposed) return;
    bool changed = false;
    double localLevel = 0;
    for (final entry in _pcs.entries) {
      try {
        final reports = await entry.value.getStats();
        for (final r in reports) {
          final v = r.values;
          if (v['kind'] != 'audio' && v['mediaType'] != 'audio') continue;
          final level = (v['audioLevel'] as num?)?.toDouble();
          if (level == null) continue;
          if (r.type == 'inbound-rtp') {
            audioLevels[entry.key] = level;
            changed = true;
          } else if (r.type == 'media-source') {
            localLevel = math.max(localLevel, level);
          }
        }
      } catch (_) {}
    }
    audioLevels[localPeerId] = isMyTurn ? localLevel : 0;
    if (changed || isMyTurn) _notify();
  }

  // ===================================================================
  // Host-driven timeline
  // ===================================================================

  /// Host starts the challenge with the first 4 present players as contestants.
  void hostStartChallenge(Map<String, dynamic> trackInfo) {
    if (!isHost) return;
    final order = peers.take(maxContestants).map((p) => p.id).toList();
    votes.clear();
    _broadcastPhase(ArenaPhase.chorusPreview, order: order, index: 0, durationMs: chorusMs, trackInfo: trackInfo);
  }

  /// Current singer (or host) can finish a turn early.
  void requestNextSinger() {
    if (phase != ArenaPhase.contestantTurn) return;
    if (isHost) {
      _hostAdvance();
    } else if (isMyTurn) {
      _send('advance_request', {'from': localPeerId, 'turn': turnIndex});
    }
  }

  void hostResetToLobby() {
    if (!isHost) return;
    _broadcastPhase(ArenaPhase.lobby, order: const [], index: 0, durationMs: 0);
  }

  void _broadcastPhase(
    ArenaPhase next, {
    required List<String> order,
    required int index,
    required int durationMs,
    Map<String, dynamic>? trackInfo,
  }) {
    final payload = {
      'phase': next.name,
      'order': order,
      'index': index,
      'remaining_ms': durationMs,
      'track': trackInfo ?? track,
      'votes': votes,
    };
    _send('phase', payload);
    _onPhase(payload); // apply locally (self broadcast disabled)
  }

  void _onPhase(Map<String, dynamic> p) {
    final next = ArenaPhase.values.firstWhere(
      (e) => e.name == p['phase'],
      orElse: () => ArenaPhase.lobby,
    );
    final changed = next != phase || (p['index'] as num?)?.toInt() != turnIndex;
    phase = next;
    turnOrder = ((p['order'] as List?) ?? const []).map((e) => e.toString()).toList();
    turnIndex = (p['index'] as num?)?.toInt() ?? 0;
    final remaining = (p['remaining_ms'] as num?)?.toInt() ?? 0;
    phaseEndsAt = remaining > 0 ? DateTime.now().add(Duration(milliseconds: remaining)) : null;
    if (p['track'] is Map) track = Map<String, dynamic>.from(p['track'] as Map);
    if (p['votes'] is Map) {
      votes
        ..clear()
        ..addAll((p['votes'] as Map).map((k, v) => MapEntry(k.toString(), v.toString())));
    }
    if (next == ArenaPhase.lobby) votes.clear();

    _applyMicGate();
    if (isHost) _scheduleHostAdvance();
    if (changed && !phaseChanges.isClosed) phaseChanges.add(next);
    _notify();
  }

  void _scheduleHostAdvance() {
    _hostTimer?.cancel();
    final end = phaseEndsAt;
    if (end == null) return;
    final wait = end.difference(DateTime.now());
    _hostTimer = Timer(wait.isNegative ? Duration.zero : wait, _hostAdvance);
  }

  void _hostAdvance() {
    if (!isHost) return;
    switch (phase) {
      case ArenaPhase.chorusPreview:
        _broadcastPhase(ArenaPhase.beatCutOff, order: turnOrder, index: 0, durationMs: cutOffMs);
        break;
      case ArenaPhase.beatCutOff:
        _broadcastPhase(ArenaPhase.contestantTurn, order: turnOrder, index: _nextPresentTurn(0), durationMs: turnMs);
        break;
      case ArenaPhase.contestantTurn:
        final next = _nextPresentTurn(turnIndex + 1);
        if (next < turnOrder.length) {
          _broadcastPhase(ArenaPhase.contestantTurn, order: turnOrder, index: next, durationMs: turnMs);
        } else {
          _broadcastPhase(ArenaPhase.voting, order: turnOrder, index: 0, durationMs: votingMs);
        }
        break;
      case ArenaPhase.voting:
        _broadcastPhase(ArenaPhase.results, order: turnOrder, index: 0, durationMs: 0);
        break;
      case ArenaPhase.lobby:
      case ArenaPhase.results:
        break;
    }
  }

  /// Skip contestants who left the arena.
  int _nextPresentTurn(int from) {
    var i = from;
    while (i < turnOrder.length && !isPresent(turnOrder[i])) {
      i++;
    }
    return i;
  }

  /// Host can change the challenge song anytime in the lobby, which syncs to all phones
  void hostSetTrack(Map<String, dynamic> trackInfo) {
    track = trackInfo;
    _send('track_select', {'track': trackInfo});
    _notify();
  }

  void _onTrackSelect(Map<String, dynamic> p) {
    if (p['track'] is Map) {
      track = Map<String, dynamic>.from(p['track'] as Map);
      _notify();
    }
  }

  void _onStateRequest(Map<String, dynamic> msg) {
    if (!isHost) return;
    final end = phaseEndsAt;
    _send('phase', {
      'phase': phase.name,
      'order': turnOrder,
      'index': turnIndex,
      'remaining_ms': end == null ? 0 : math.max(0, end.difference(DateTime.now()).inMilliseconds),
      'track': track,
      'votes': votes,
    });
  }

  void _onAdvanceRequest(Map<String, dynamic> msg) {
    if (!isHost || phase != ArenaPhase.contestantTurn) return;
    final turn = (msg['turn'] as num?)?.toInt();
    final from = msg['from']?.toString();
    if (turn == turnIndex && from == hotMicPeerId) _hostAdvance();
  }

  // ===================================================================
  // Voting
  // ===================================================================

  String? get myVote => votes[localPeerId];

  void castVote(String contestantId) {
    if (phase != ArenaPhase.voting || contestantId == localPeerId) return;
    votes[localPeerId] = contestantId;
    _send('vote', {'voter': localPeerId, 'target': contestantId});
    _notify();
  }

  void _onVote(Map<String, dynamic> msg) {
    final voter = msg['voter']?.toString();
    final target = msg['target']?.toString();
    if (voter == null || target == null || voter == target) return;
    votes[voter] = target;
    _notify();
  }

  // ===================================================================
  // Helpers
  // ===================================================================

  /// Broadcast callbacks may deliver either the raw payload or the full envelope.
  Map<String, dynamic> _unwrap(Map<String, dynamic> raw) {
    final inner = raw['payload'];
    if (inner is Map && raw.containsKey('event')) return Map<String, dynamic>.from(inner);
    return raw;
  }

  void _send(String event, Map<String, dynamic> payload) {
    final ch = _channel;
    if (ch == null) return;
    ch.sendBroadcastMessage(event: event, payload: payload).catchError((Object e) {
      debugPrint('[Arena] send $event failed: $e');
      return ChannelResponse.error;
    });
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }
}
