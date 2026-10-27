import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../models/models.dart';
import '../services/acapella_arena_service.dart';
import '../services/game_state.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import 'karaoke_stage_widget.dart';

/// Zoom-style LIVE Saturday Acapella Challenge.
///
/// Real people only (Supabase Presence), real camera + mic over WebRTC, one hot mic
/// at a time, host-synchronised chorus → beat cut → numbered turns → live voting.
class AcapellaChallengeArenaModal extends StatefulWidget {
  final GameState gameState;
  final KaraokeTrack track;
  final String roomId;

  const AcapellaChallengeArenaModal({
    super.key,
    required this.gameState,
    required this.track,
    this.roomId = 'room_afrobeat_vibes',
  });

  static void launch(BuildContext context, GameState gameState, {KaraokeTrack? track, String? roomId}) {
    final selectedTrack = track ?? gameState.karaokeCurrentTrack ?? gameState.karaokeAvailableTracks.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AcapellaChallengeArenaModal(
        gameState: gameState,
        track: selectedTrack,
        roomId: roomId ?? 'room_afrobeat_vibes',
      ),
    );
  }

  @override
  State<AcapellaChallengeArenaModal> createState() => _AcapellaChallengeArenaModalState();
}

class _AcapellaChallengeArenaModalState extends State<AcapellaChallengeArenaModal> {
  late final AcapellaArenaService _arena;
  StreamSubscription<ArenaPhase>? _phaseSub;
  Timer? _clock;

  @override
  void initState() {
    super.initState();
    final user = widget.gameState.user;
    _arena = AcapellaArenaService(
      roomId: widget.roomId,
      profile: {
        'name': user.username,
        'emoji': user.avatarEmoji,
        'rank': user.starRank.badgeTitle,
        'city': user.lgaName.isNotEmpty ? user.lgaName : 'Nigeria',
      },
    );
    _arena.track = {
      'id': widget.track.id,
      'title': widget.track.title,
      'artist': widget.track.artist,
      'audio': widget.track.audioPreviewUrl,
      'emoji': widget.track.emoji,
    };
    _phaseSub = _arena.phaseChanges.stream.listen(_onPhaseChanged);
    _clock = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) setState(() {}); // refresh countdowns
    });
    _arena.start();
  }

  @override
  void dispose() {
    _clock?.cancel();
    _phaseSub?.cancel();
    SoundService().stopKaraokeAudio();
    _arena.dispose();
    super.dispose();
  }

  void _onPhaseChanged(ArenaPhase phase) {
    switch (phase) {
      case ArenaPhase.chorusPreview:
        final url = _arena.track?['audio'] as String?;
        if (url != null && url.isNotEmpty) SoundService().playKaraokeAudio(url);
        break;
      case ArenaPhase.beatCutOff:
        SoundService().stopKaraokeAudio();
        SoundService().playDanfoHorn();
        break;
      case ArenaPhase.contestantTurn:
        SoundService().stopKaraokeAudio();
        SoundService().playButtonTap();
        break;
      case ArenaPhase.results:
        SoundService().playSparkMatch();
        break;
      case ArenaPhase.voting:
      case ArenaPhase.lobby:
        SoundService().stopKaraokeAudio();
        break;
    }
  }

  Map<String, dynamic> get _trackInfo => {
        'id': _arena.track?['id'] ?? widget.track.id,
        'title': _arena.track?['title'] ?? widget.track.title,
        'artist': _arena.track?['artist'] ?? widget.track.artist,
        'audio': _arena.track?['audio'] ?? widget.track.audioPreviewUrl,
        'emoji': _arena.track?['emoji'] ?? widget.track.emoji,
      };

  void _openSongSearchModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141928),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return KaraokeSongSearchModal(
          gameState: widget.gameState,
          onTrackSelected: (selectedTrack) {
            final trackMap = {
              'id': selectedTrack.id,
              'title': selectedTrack.title,
              'artist': selectedTrack.artist,
              'audio': selectedTrack.audioPreviewUrl,
              'emoji': selectedTrack.emoji,
            };
            widget.gameState.karaokeCurrentTrack = selectedTrack;
            _arena.hostSetTrack(trackMap);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppTheme.neonEmerald,
                content: Text('🎵 Challenge song updated to "${selectedTrack.title}"!'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        );
      },
    );
  }

  // ===================================================================
  // Build
  // ===================================================================

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _arena,
      builder: (context, _) {
        final title = _arena.track?['title'] ?? widget.track.title;
        final artist = _arena.track?['artist'] ?? widget.track.artist;

        return Container(
          height: MediaQuery.of(context).size.height * 0.94,
          decoration: const BoxDecoration(
            color: Color(0xFF0C101E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                const SizedBox(height: 10),
                _buildHeader(title, artist),
                const SizedBox(height: 6),
                ..._buildStatusNotices(),
                _buildPhaseBanner(),
                if (_arena.phase == ArenaPhase.lobby)
                  _buildLobbySongCard(title, artist),
                const SizedBox(height: 8),
                Expanded(child: _buildGrid()),
                _buildBottomControls(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLobbySongCard(String title, String artist) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF13182E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.5), width: 1.0),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8A2387), Color(0xFFE94057), Color(0xFFF27121)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text('🎶', style: TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Row(
                  children: [
                    Text(
                      'CHALLENGE SONG',
                      style: TextStyle(
                        color: Colors.amberAccent,
                        fontSize: 9.0,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.7,
                      ),
                    ),
                    SizedBox(width: 5),
                    Text(
                      '• 15s Chorus',
                      style: TextStyle(color: AppTheme.neonEmerald, fontSize: 8.5, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Text(
                  '$title • $artist',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amberAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.search_rounded, size: 13),
            label: const Text(
              'Change',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
            ),
            onPressed: _openSongSearchModal,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title, String artist) {
    final live = _arena.connected;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.amberAccent.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Text('🏆', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Flexible(
                      child: Text(
                        'LIVE ACAPELLA CHALLENGE',
                        style: TextStyle(
                          color: Colors.amberAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: live ? AppTheme.neonEmerald : Colors.orangeAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      live ? '${_arena.peers.length} in arena' : 'connecting…',
                      style: TextStyle(
                        color: live ? AppTheme.neonEmerald : Colors.orangeAccent,
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  '$title • $artist',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (_arena.phase == ArenaPhase.lobby)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.amberAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.music_note_rounded, size: 14),
                label: const Text('Change', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                onPressed: _openSongSearchModal,
              ),
            ),
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
              child: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStatusNotices() {
    final notices = <Widget>[];
    void add(String text, Color color) {
      notices.add(Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Text(text, style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w600)),
      ));
    }

    if (_arena.error != null) add('⚠️ ${_arena.error}', Colors.redAccent);
    if (_arena.mediaError != null) add('🎙️ ${_arena.mediaError}', Colors.orangeAccent);
    if (_arena.arenaFull) {
      add('🚪 Arena is full (${AcapellaArenaService.maxParticipants} max for live P2P video). Please try again shortly.',
          Colors.orangeAccent);
    }
    return notices;
  }

  // ===================================================================
  // Phase banner
  // ===================================================================

  Widget _buildPhaseBanner() {
    final secs = _arena.secondsRemaining;
    late Color color;
    late String title;
    late String subtitle;
    String? badge;

    switch (_arena.phase) {
      case ArenaPhase.lobby:
        color = Colors.cyanAccent;
        final n = _arena.peers.length;
        title = '🛋️ LOBBY • $n/${AcapellaArenaService.maxContestants} SINGERS READY';
        if (n <= 1) {
          subtitle = 'You\'re the first one here. Share the room so others can join — real people only, no bots.';
        } else if (_arena.isHost) {
          subtitle = 'You are the host. Tap "Start Challenge" when everyone is in.';
        } else {
          subtitle = 'Waiting for host ${_arena.peers.first.name} to start the challenge…';
        }
        break;
      case ArenaPhase.chorusPreview:
        color = Colors.purpleAccent;
        title = '🎵 CHORUS PREVIEW — LEARN THE HOOK';
        subtitle = 'Studio audio is playing on every phone. Beat cuts off soon!';
        badge = '$secs s';
        break;
      case ArenaPhase.beatCutOff:
        color = Colors.redAccent;
        title = '🔇 BEAT CUT! MUSIC STOPPED!';
        final first = _arena.peerById(_arena.turnOrder.isNotEmpty ? _arena.turnOrder.first : '');
        subtitle = 'Contestant #1 ${first?.name ?? ''} gets ready to sing raw…';
        badge = '$secs s';
        break;
      case ArenaPhase.contestantTurn:
        color = Colors.amberAccent;
        final singer = _arena.peerById(_arena.hotMicPeerId ?? '');
        final number = _arena.turnIndex + 1;
        if (_arena.isMyTurn) {
          title = '🎤 YOUR TURN, CONTESTANT #$number — YOUR MIC IS LIVE!';
          subtitle = 'Everyone in the arena hears you right now. Sing the chorus raw!';
        } else {
          title = '🎤 CONTESTANT #$number SINGING: ${singer?.name ?? '…'}';
          subtitle = 'Live audio — all other mics are muted.';
        }
        badge = '$secs s';
        break;
      case ArenaPhase.voting:
        color = AppTheme.neonEmerald;
        title = '🗳️ JUDGEMENT DECK OPEN — VOTE NOW';
        subtitle = _arena.myVote == null
            ? 'Tap the singer who killed it (you can\'t vote for yourself).'
            : 'Vote locked in for ${_arena.peerById(_arena.myVote!)?.name ?? ''}. You can still change it.';
        badge = '$secs s';
        break;
      case ArenaPhase.results:
        color = Colors.amberAccent;
        final winner = _winnerId();
        final w = winner == null ? null : _arena.peerById(winner);
        title = w == null ? '🤝 NO VOTES CAST' : '👑 WINNER: ${w.name}!';
        subtitle = w == null
            ? 'No one voted this round.'
            : '${_arena.voteTally[winner]} vote(s) from the live arena.';
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color, width: 1.2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(color: Colors.white, fontSize: 10)),
              ],
            ),
          ),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
              child: Text(badge,
                  style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w900)),
            ),
        ],
      ),
    );
  }

  String? _winnerId() {
    final tally = _arena.voteTally;
    String? best;
    var bestVotes = 0;
    tally.forEach((id, v) {
      if (v > bestVotes) {
        best = id;
        bestVotes = v;
      }
    });
    return best;
  }

  // ===================================================================
  // Live video grid
  // ===================================================================

  Widget _buildGrid() {
    final ids = _arena.stageIds;
    if (ids.isEmpty) {
      return const Center(
        child: Text('Joining the live arena…', style: TextStyle(color: Colors.white60, fontSize: 12)),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const spacing = 8.0;
          final rows = math.max(2, (ids.length / 2).ceil());
          final tileW = (constraints.maxWidth - spacing) / 2;
          final tileH = (constraints.maxHeight - spacing * (rows - 1)) / rows;
          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              childAspectRatio: tileW / math.max(tileH, 1),
            ),
            itemCount: ids.length,
            itemBuilder: (context, idx) => _buildTile(ids[idx], idx),
          );
        },
      ),
    );
  }

  Widget _buildTile(String peerId, int idx) {
    final peer = _arena.peerById(peerId);
    final isMe = peerId == _arena.localPeerId;
    final isHot = _arena.hotMicPeerId == peerId;
    final present = _arena.isPresent(peerId);
    final inShow = _arena.phase != ArenaPhase.lobby;
    final number = inShow ? idx + 1 : null;
    final voting = _arena.phase == ArenaPhase.voting;
    final votesForMe = _arena.voteTally[peerId] ?? 0;
    final iVotedThis = _arena.myVote == peerId;

    final RTCVideoRenderer? renderer = isMe ? (_arena.mediaReady ? _arena.localRenderer : null) : _arena.remoteRenderers[peerId];
    final level = _arena.audioLevels[peerId] ?? 0;

    final borderColor = isHot
        ? Colors.amberAccent
        : iVotedThis
            ? AppTheme.neonEmerald
            : isMe
                ? Colors.cyanAccent.withValues(alpha: 0.6)
                : Colors.white12;

    return GestureDetector(
      onTap: voting && !isMe && present ? () => _arena.castVote(peerId) : null,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFF13182C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: isHot || iVotedThis ? 2.2 : 1.0),
          boxShadow: isHot
              ? [BoxShadow(color: Colors.amberAccent.withValues(alpha: 0.3), blurRadius: 14, spreadRadius: 1)]
              : null,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Live camera feed (or avatar while connecting / camera off)
            if (renderer != null && renderer.srcObject != null && present)
              RTCVideoView(
                renderer,
                mirror: isMe,
                objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
              )
            else
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2642),
                        shape: BoxShape.circle,
                        border: Border.all(color: isHot ? Colors.amberAccent : Colors.white24, width: 1.5),
                      ),
                      child: Center(child: Text(peer?.emoji ?? '🎤', style: const TextStyle(fontSize: 26))),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      !present
                          ? 'left the arena'
                          : isMe
                              ? (_arena.mediaReady ? 'starting camera…' : 'camera off')
                              : 'connecting video…',
                      style: const TextStyle(color: Colors.white38, fontSize: 9),
                    ),
                  ],
                ),
              ),

            // Name strip
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(8, 14, 8, 6),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isHot) _buildLevelMeter(level),
                    Text(
                      '${peer?.name ?? 'Singer'}${isMe ? ' (You)' : ''}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      [peer?.city, peer?.rank].where((s) => s != null && s.isNotEmpty).join(' • '),
                      style: TextStyle(color: isHot ? Colors.amberAccent : Colors.white60, fontSize: 8.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // Top-left: contestant number / host badge
            Positioned(
              top: 8,
              left: 8,
              child: Row(
                children: [
                  if (number != null)
                    _chip('#$number', isHot ? Colors.amberAccent : Colors.black54, isHot ? Colors.black : Colors.white),
                  if (_arena.peers.isNotEmpty && _arena.peers.first.id == peerId) ...[
                    const SizedBox(width: 4),
                    _chip('HOST', Colors.cyanAccent.withValues(alpha: 0.85), Colors.black),
                  ],
                ],
              ),
            ),

            // Top-right: mic state or vote count
            Positioned(
              top: 8,
              right: 8,
              child: voting || _arena.phase == ArenaPhase.results
                  ? _chip('🗳️ $votesForMe', iVotedThis ? AppTheme.neonEmerald : Colors.black54,
                      iVotedThis ? Colors.black : Colors.white)
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: isHot ? Colors.redAccent : Colors.black45,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(isHot ? Icons.mic_rounded : Icons.mic_off_rounded, size: 11, color: Colors.white),
                          const SizedBox(width: 3),
                          Text(
                            isHot ? 'ON AIR' : 'MUTED',
                            style: const TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
            ),

            if (voting && !isMe && present)
              Positioned(
                right: 8,
                bottom: 40,
                child: _chip(iVotedThis ? '✅ Voted' : 'Tap to vote',
                    iVotedThis ? AppTheme.neonEmerald : Colors.white24, iVotedThis ? Colors.black : Colors.white),
              ),
          ],
        ),
      ),
    );
  }

  /// Meter driven by REAL WebRTC audio levels (0..1).
  Widget _buildLevelMeter(double level) {
    final active = (level.clamp(0.0, 1.0) * 14 * 2.2).round().clamp(0, 14);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: List.generate(14, (i) {
          final on = i < active;
          return Container(
            width: 4,
            height: 4.0 + i * 0.8,
            margin: const EdgeInsets.only(right: 2),
            decoration: BoxDecoration(
              color: on ? (i > 10 ? Colors.redAccent : Colors.greenAccent) : Colors.white12,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }

  Widget _chip(String text, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
        child: Text(text, style: TextStyle(color: fg, fontWeight: FontWeight.w900, fontSize: 9)),
      );

  // ===================================================================
  // Bottom controls
  // ===================================================================

  Widget _buildBottomControls() {
    final children = <Widget>[];

    // Spray naira (real wallet deduction)
    children.add(OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.neonEmerald,
        side: BorderSide(color: AppTheme.neonEmerald.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        final gs = widget.gameState;
        if (gs.user.walletBalance < 10) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(backgroundColor: Colors.redAccent, content: Text('Need 10 🪙 to spray.')),
          );
          return;
        }
        SoundService().playMoneySpray();
        gs.user.walletBalance -= 10;
        gs.notifyListeners();
      },
      child: const Text('💸 Spray 10 🪙', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
    ));

    Widget primary(String label, VoidCallback? onTap, {Color color = Colors.amberAccent}) => Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.black,
              disabledBackgroundColor: Colors.white12,
              disabledForegroundColor: Colors.white38,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: onTap,
            child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
          ),
        );

    switch (_arena.phase) {
      case ArenaPhase.lobby:
        children.add(OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.amberAccent,
            side: BorderSide(color: Colors.amberAccent.withValues(alpha: 0.7)),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          icon: const Icon(Icons.library_music_rounded, size: 14),
          label: const Text('Pick Song 🎵', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          onPressed: _openSongSearchModal,
        ));
        if (_arena.isHost) {
          children.add(primary(
            _arena.peers.length < 2 ? '🏁 Start (waiting for singers…)' : '🏁 Start Challenge',
            _arena.connected && _arena.peers.isNotEmpty ? () => _arena.hostStartChallenge(_trackInfo) : null,
          ));
        } else {
          children.add(primary('⏳ Waiting for host…', null));
        }
        break;
      case ArenaPhase.chorusPreview:
      case ArenaPhase.beatCutOff:
        children.add(primary(_arena.amContestant ? '🎧 Listen & get ready' : '👀 Spectating', null));
        break;
      case ArenaPhase.contestantTurn:
        if (_arena.isMyTurn) {
          children.add(primary('✅ Done singing — next', _arena.requestNextSinger, color: Colors.redAccent));
        } else if (_arena.isHost) {
          children.add(primary('⏭️ Next singer', _arena.requestNextSinger));
        } else {
          children.add(primary('🔇 Your mic is muted', null));
        }
        break;
      case ArenaPhase.voting:
        children.add(primary(_arena.myVote == null ? '👆 Tap a singer to vote' : '✅ Vote cast', null,
            color: AppTheme.neonEmerald));
        break;
      case ArenaPhase.results:
        if (_arena.isHost) {
          children.add(primary('🔁 New Round', _arena.hostResetToLobby));
        } else {
          children.add(primary('🎉 Round over', null));
        }
        break;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: const BoxDecoration(
        color: Color(0xFF090D1A),
        border: Border(top: BorderSide(color: Colors.white12, width: 0.5)),
      ),
      child: Row(
        children: [
          children.first,
          const SizedBox(width: 10),
          ...children.skip(1),
        ],
      ),
    );
  }
}
