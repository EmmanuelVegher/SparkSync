import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/models.dart';
import '../services/game_state.dart';
import '../services/song_search_service.dart';
import '../services/sound_service.dart';
import '../services/youtube_service.dart';
import '../theme/app_theme.dart';
import 'audience_voting_poll_modal.dart';
import 'credit_top_up_sheet.dart';

class KaraokeStageWidget extends StatefulWidget {
  final GameState gameState;
  final String roomId;

  const KaraokeStageWidget({
    super.key,
    required this.gameState,
    required this.roomId,
  });

  @override
  State<KaraokeStageWidget> createState() => _KaraokeStageWidgetState();
}

class _KaraokeStageWidgetState extends State<KaraokeStageWidget> with SingleTickerProviderStateMixin {
  late AnimationController _glowAnim;
  final List<_FloatingReaction> _reactions = [];
  final ScrollController _lyricsScrollCtrl = ScrollController();
  int _lastActiveIndex = -1;
  final SongSearchService _searchService = SongSearchService();

  // YouTube player fields
  YoutubePlayerController? _ytCtrl;
  String? _loadedVideoId;
  Timer? _ytSyncTimer;       // ticks elapsed from YT player position
  bool _ytPlayerReady = false;
  bool _showYtPlayer = true; // user can collapse the video
  String? _resolvingTrackId;
  bool _ytHasPlaybackError = false;
  int _ytErrorCode = 0;
  bool _isFindingAlternative = false;

  @override
  void initState() {
    super.initState();
    _glowAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // If stage already live when widget mounts, init YouTube player
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gs = widget.gameState;
      if (gs.karaokeIsPlaying && gs.karaokeCurrentTrack != null) {
        if (gs.karaokeCurrentTrack!.youtubeVideoId != null) {
          _attachYouTubePlayer(gs.karaokeCurrentTrack!);
        } else {
          _resolveAndAttachYouTube(gs.karaokeCurrentTrack!);
        }
      }
    });
  }

  Future<void> _resolveAndAttachYouTube(KaraokeTrack track) async {
    if (_resolvingTrackId == track.id) return;
    _resolvingTrackId = track.id;
    try {
      final videoId = await YoutubeService().findKaraokeVideoId(track.title, track.artist);
      _resolvingTrackId = null;
      if (!mounted) return;
      if (videoId != null && widget.gameState.karaokeCurrentTrack?.id == track.id) {
        final updatedTrack = track.copyWith(youtubeVideoId: videoId);
        widget.gameState.karaokeCurrentTrack = updatedTrack;
        _attachYouTubePlayer(updatedTrack);
      }
    } catch (_) {
      _resolvingTrackId = null;
    }
  }

  void _attachYouTubePlayer(KaraokeTrack track) {
    final videoId = track.youtubeVideoId;
    if (videoId == null || videoId.isEmpty) return;
    if (_loadedVideoId == videoId && !_ytHasPlaybackError) return; // already loaded cleanly

    _ytCtrl?.removeListener(_onYtPlayerStateChanged);
    _ytCtrl?.dispose();
    _ytSyncTimer?.cancel();
    _ytPlayerReady = false;
    _ytHasPlaybackError = false;
    _ytErrorCode = 0;
    _loadedVideoId = videoId;

    _ytCtrl = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: widget.gameState.isAcapellaModeActive,
        enableCaption: false,
        loop: false,
        forceHD: false,
        useHybridComposition: true,
      ),
    );

    _ytCtrl!.addListener(_onYtPlayerStateChanged);

    // Stop the iTunes/WAV audio initially; if Error 150 is caught, fallback resumes
    SoundService().stopKaraokeAudio();

    // Sync elapsed seconds from the YouTube player position every second
    _ytSyncTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_ytCtrl == null) return;
      final pos = _ytCtrl!.value.position.inSeconds;
      if (_ytCtrl!.value.isPlaying) {
        widget.gameState.karaokeElapsedSeconds = pos;
        if (mounted) setState(() {});
        final trackDuration = widget.gameState.karaokeCurrentTrack?.durationSeconds ?? 0;
        if (trackDuration > 0 && pos >= trackDuration) {
          _onFinishTurnWithVoting();
        }
      }
    });

    if (mounted) setState(() {});
  }

  void _onYtPlayerStateChanged() {
    if (!mounted || _ytCtrl == null) return;
    final val = _ytCtrl!.value;

    // Detect YouTube Error 150 / 101 (Owner restricted embedded playback)
    if (val.hasError || val.errorCode == 150 || val.errorCode == 101) {
      if (!_ytHasPlaybackError) {
        setState(() {
          _ytHasPlaybackError = true;
          _ytErrorCode = val.errorCode;
        });

        debugPrint('[KaraokeStageWidget] ⚠️ YouTube Error ${val.errorCode} detected! Starting fallback audio.');
        final track = widget.gameState.karaokeCurrentTrack;
        if (track != null && _loadedVideoId != null) {
          YoutubeService().markVideoRestricted(track.title, track.artist, _loadedVideoId!);
        }

        // Start background audio immediately so user never loses music
        SoundService().playKaraokeAudio(track?.audioPreviewUrl);
      }
    }
  }

  Future<void> _tryAlternateVideo() async {
    final track = widget.gameState.karaokeCurrentTrack;
    if (track == null) return;
    setState(() {
      _isFindingAlternative = true;
    });

    final newId = await YoutubeService().findKaraokeVideoId(
      track.title,
      track.artist,
      excludeVideoId: _loadedVideoId,
    );

    if (!mounted) return;
    setState(() {
      _isFindingAlternative = false;
    });

    if (newId != null && newId != _loadedVideoId) {
      final updatedTrack = track.copyWith(youtubeVideoId: newId);
      widget.gameState.karaokeCurrentTrack = updatedTrack;
      _loadedVideoId = null; // force reload
      _attachYouTubePlayer(updatedTrack);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.electricPink,
          content: Text('No other video available without owner restrictions. Streaming high-def audio! 🎶'),
        ),
      );
    }
  }

  Future<void> _openInYoutubeApp() async {
    if (_loadedVideoId == null) return;
    final uri = Uri.parse('https://www.youtube.com/watch?v=$_loadedVideoId');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  void _showPasteLyricsDialog(BuildContext context, KaraokeTrack track) {
    final textController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141928),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Text('✍️', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Paste Real Lyrics: ${track.title}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Paste the actual verses and chorus. The prompter will sync them across your performance.',
                style: TextStyle(color: Colors.white60, fontSize: 11),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0C101D),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3)),
                ),
                child: TextField(
                  controller: textController,
                  maxLines: 7,
                  style: const TextStyle(color: Colors.white, fontSize: 12.5, height: 1.3),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(12),
                    hintText: 'Paste song lyrics here...\nVerse 1...\nChorus...',
                    hintStyle: TextStyle(color: Colors.white30, fontSize: 12),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0071E3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final pasted = textController.text.trim();
                    if (pasted.isNotEmpty) {
                      final lines = _searchService.parsePlainLyrics(pasted, track.durationSeconds);
                      final updated = track.copyWith(
                        lyrics: lines,
                        hasRealLyrics: true,
                      );
                      widget.gameState.karaokeCurrentTrack = updated;
                      Navigator.pop(ctx);
                      if (mounted) setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: AppTheme.neonEmerald,
                          content: Text('✅ Real lyrics updated and synced to the Live Prompter!'),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    '✓ Sync Real Lyrics to Prompter',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onFinishTurnWithVoting() {
    final track = widget.gameState.karaokeCurrentTrack;
    final singerName = widget.gameState.karaokeSingerName ?? 'Singer';
    final singerAvatar = widget.gameState.karaokeSingerAvatar;
    final singerRank = widget.gameState.karaokeSingerRank;
    final isAcapella = widget.gameState.isAcapellaModeActive;

    _ytCtrl?.pause();
    widget.gameState.finishCurrentKaraokeSong();
    if (mounted) setState(() {});

    if (track != null) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => AudienceVotingPollModal(
          gameState: widget.gameState,
          performerName: singerName,
          performerAvatar: singerAvatar,
          performerRank: singerRank,
          trackTitle: track.title,
          trackArtist: track.artist,
          isAcapella: isAcapella,
        ),
      );
    }
  }

  @override
  void dispose() {
    _glowAnim.dispose();
    _lyricsScrollCtrl.dispose();
    _ytSyncTimer?.cancel();
    _ytCtrl?.dispose();
    SoundService().stopKaraokeAudio();
    super.dispose();
  }

  void _spawnReaction(String emoji) {
    if (!mounted) return;
    setState(() {
      _reactions.add(
        _FloatingReaction(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          emoji: emoji,
          startX: 0.15 + math.Random().nextDouble() * 0.70,
        ),
      );
      if (_reactions.length > 14) {
        _reactions.removeAt(0);
      }
    });

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() {
          _reactions.removeWhere((r) => DateTime.now().difference(r.created).inMilliseconds > 1300);
        });
      }
    });
  }

  void _onClapTapped() {
    widget.gameState.clapForKaraokeSinger();
    _spawnReaction('👏');
    _spawnReaction('✨');
  }

  void _onSprayNairaTapped() {
    final err = widget.gameState.sprayNairaOnSinger();
    if (err != null) {
      final isLowBalance = err.contains('Need at least') || err.contains('50 🪙');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(err, style: const TextStyle(fontWeight: FontWeight.bold)),
          duration: const Duration(seconds: 3),
          action: isLowBalance
              ? SnackBarAction(
                  label: 'TOP UP ⚡',
                  textColor: AppTheme.lagosYellow,
                  onPressed: () => CreditTopUpSheet.show(context, widget.gameState),
                )
              : null,
        ),
      );
    } else {
      _spawnReaction('💸');
      _spawnReaction('💵');
      _spawnReaction('💰');
    }
  }

  void _onCocktailTapped() {
    final err = widget.gameState.buySingerCocktail();
    if (err != null) {
      final isLowBalance = err.contains('Need at least') || err.contains('50 🪙');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(err, style: const TextStyle(fontWeight: FontWeight.bold)),
          duration: const Duration(seconds: 3),
          action: isLowBalance
              ? SnackBarAction(
                  label: 'TOP UP ⚡',
                  textColor: AppTheme.lagosYellow,
                  onPressed: () => CreditTopUpSheet.show(context, widget.gameState),
                )
              : null,
        ),
      );
    } else {
      _spawnReaction('🍹');
      _spawnReaction('🥂');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.neonEmerald,
          content: Text('🍹 Chilled VIP cocktail sent to the singer! +150 XP!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _openMicQueueModal() {
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
          onTrackSelected: (track) {
            final err = widget.gameState.joinKaraokeMicQueue(track);
            if (err != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.redAccent,
                  content: Text(err, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppTheme.neonEmerald,
                  content: Text('🎉 Signed up for the Mic with "${track.title}"!'),
                ),
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gs = widget.gameState;
    final track = gs.karaokeCurrentTrack;
    final isStageActive = gs.karaokeSingerName != null && track != null;
    final elapsed = gs.karaokeElapsedSeconds;
    final total = track?.durationSeconds ?? 0;
    final progress = total > 0 ? (elapsed / total).clamp(0.0, 1.0) : 0.0;

    // Attach (or re-attach) YouTube player whenever the track changes
    if (isStageActive && track.youtubeVideoId != null && track.youtubeVideoId != _loadedVideoId) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _attachYouTubePlayer(track));
    } else if (isStageActive && track.youtubeVideoId == null && _resolvingTrackId != track.id && _loadedVideoId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _resolveAndAttachYouTube(track));
    }
    // If stage cleared, release the player
    if (!isStageActive && _loadedVideoId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _ytCtrl?.dispose();
        _ytCtrl = null;
        _loadedVideoId = null;
        _ytSyncTimer?.cancel();
      });
    }

    // Find active lyric index based on elapsed seconds
    int activeIndex = 0;
    if (track != null && track.lyrics.isNotEmpty) {
      for (var i = 0; i < track.lyrics.length; i++) {
        if (elapsed >= track.lyrics[i].seconds) {
          activeIndex = i;
        }
      }
    }

    if (activeIndex != _lastActiveIndex && activeIndex >= 0) {
      _lastActiveIndex = activeIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_lyricsScrollCtrl.hasClients) {
          final targetOffset = math.max(0.0, (activeIndex * 56.0) - 48.0);
          _lyricsScrollCtrl.animateTo(
            targetOffset,
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(10, 4, 10, 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1B1530),
                Color(0xFF121424),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF382B55), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. SINGER PROFILE & STAGE STATUS
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                child: Row(
                  children: [
                    // Glowing Microphone Avatar
                    AnimatedBuilder(
                      animation: _glowAnim,
                      builder: (context, _) {
                        return Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              colors: [Color(0xFF9C27B0), Color(0xFF311B92)],
                            ),
                            border: Border.all(
                              color: Colors.purpleAccent.withValues(alpha: 0.7 + 0.3 * _glowAnim.value),
                              width: 1.8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.purpleAccent.withValues(alpha: 0.35 * _glowAnim.value),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: isStageActive
                              ? (track.artworkUrl != null && track.artworkUrl!.isNotEmpty)
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: Image.network(
                                        track.artworkUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Text(gs.karaokeSingerAvatar, style: const TextStyle(fontSize: 20)),
                                      ),
                                    )
                                  : Text(gs.karaokeSingerAvatar, style: const TextStyle(fontSize: 20))
                              : const Text('🎙️', style: TextStyle(fontSize: 22)),
                        );
                      },
                    ),
                    const SizedBox(width: 10),

                    // Singer Info & Song or Open Stage Indicator
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                '🎤 STAGE: ',
                                style: TextStyle(
                                  color: Color(0xFFFF80AB),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  isStageActive ? (gs.karaokeSingerName ?? 'Singer') : 'Stage is Open! 🌟',
                                  style: TextStyle(
                                    color: isStageActive ? Colors.white : Colors.amberAccent,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Text('🎵 ', style: TextStyle(fontSize: 10)),
                              Expanded(
                                child: Text(
                                  isStageActive
                                      ? '${track.title} • ${track.artist}'
                                      : 'Mic is free — Search any song to sing along!',
                                  style: const TextStyle(
                                    color: Color(0xFF00E5FF),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Stage Status Badge (No duplicate search button)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isStageActive
                            ? const Color(0xFFFF2A6D).withValues(alpha: 0.15)
                            : AppTheme.lagosYellow.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isStageActive
                              ? const Color(0xFFFF2A6D).withValues(alpha: 0.5)
                              : AppTheme.lagosYellow.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Text(
                        isStageActive ? '🔥 LIVE' : '30 🪙 to Sing',
                        style: TextStyle(
                          color: isStageActive ? const Color(0xFFFF2A6D) : AppTheme.lagosYellow,
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // THE SINGLE UNIFIED SEARCH BAR ON STAGE
              InkWell(
                onTap: _openMicQueueModal,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1524),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.4), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyanAccent.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.cyanAccent, size: 17),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Search songs online (Davido, Asake, Burna Boy, Buga)...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF2A6D), Color(0xFF9C27B0)],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🎤 ', style: TextStyle(fontSize: 10)),
                            Text(
                              'Search & Sing',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. DYNAMIC SCROLLING TELEPROMPTER VIEW (SMOOTH & NEVER STATIC)
              if (isStageActive && track.lyrics.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C101D),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.35)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyanAccent.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Prompter Header with Live Index & Real Lyrics Indicator
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(track.hasRealLyrics ? '🎶 ' : '⚠️ ', style: const TextStyle(fontSize: 11)),
                                Text(
                                  track.hasRealLyrics
                                      ? 'LIVE PROMPTER • REAL LYRICS'
                                      : 'NO DB LYRICS • READ VIDEO',
                                  style: TextStyle(
                                    color: track.hasRealLyrics
                                        ? Colors.cyanAccent.withValues(alpha: 0.9)
                                        : Colors.amberAccent,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () => _showPasteLyricsDialog(context, track),
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.cyanAccent.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.4)),
                                    ),
                                    child: const Text(
                                      '✍️ Paste Lyrics',
                                      style: TextStyle(
                                        color: Colors.cyanAccent,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.purpleAccent.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${activeIndex + 1} / ${track.lyrics.length}',
                                    style: const TextStyle(
                                      color: Colors.purpleAccent,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Smooth Vertical Scrolling Lyrics Feed with Fade ShaderMask
                      // When video is active, shrink height so entire widget fits without RenderFlex overflow
                      Builder(
                        builder: (context) {
                          final bool hasActiveVideo = _ytCtrl != null && _showYtPlayer && !_ytHasPlaybackError;
                          final double prompterHeight = hasActiveVideo ? 68.0 : 130.0;

                          return SizedBox(
                            height: prompterHeight,
                            child: ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.white,
                                Colors.white,
                                Colors.transparent,
                              ],
                              stops: [0.0, 0.12, 0.88, 1.0],
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.dstIn,
                          child: ListView.builder(
                            controller: _lyricsScrollCtrl,
                            physics: const BouncingScrollPhysics(),
                            itemCount: track.lyrics.length,
                            itemBuilder: (context, idx) {
                              final line = track.lyrics[idx];
                              final isCurrent = idx == activeIndex;
                              final isPast = idx < activeIndex;

                              // Calculate real-time line progress
                              final nextSec = (idx + 1 < track.lyrics.length)
                                  ? track.lyrics[idx + 1].seconds
                                  : track.durationSeconds;
                              final lineSpan = math.max(1, nextSec - line.seconds);
                              final linePct = ((elapsed - line.seconds) / lineSpan).clamp(0.0, 1.0);

                              return InkWell(
                                onTap: () {
                                  widget.gameState.karaokeElapsedSeconds = line.seconds;
                                  widget.gameState.notifyListeners();
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  margin: EdgeInsets.symmetric(vertical: isCurrent ? 4 : 2),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isCurrent ? 12 : 8,
                                    vertical: isCurrent ? 7 : 3,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: isCurrent
                                        ? const LinearGradient(
                                            colors: [
                                              Color(0x3300E5FF),
                                              Color(0x339C27B0),
                                            ],
                                          )
                                        : null,
                                    borderRadius: BorderRadius.circular(10),
                                    border: isCurrent
                                        ? Border.all(
                                            color: Colors.cyanAccent.withValues(alpha: 0.7),
                                            width: 1.2,
                                          )
                                        : null,
                                    boxShadow: isCurrent
                                        ? [
                                            BoxShadow(
                                              color: Colors.cyanAccent.withValues(alpha: 0.2),
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          if (isCurrent)
                                            AnimatedBuilder(
                                              animation: _glowAnim,
                                              builder: (context, _) => Padding(
                                                padding: const EdgeInsets.only(right: 6),
                                                child: Text(
                                                  '🎙️',
                                                  style: TextStyle(
                                                    fontSize: 12 + 2 * _glowAnim.value,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          Flexible(
                                            child: Text(
                                              line.text,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: isCurrent
                                                    ? const Color(0xFF00E5FF)
                                                    : (isPast ? Colors.white38 : Colors.white70),
                                                fontSize: isCurrent ? 14.5 : (isPast ? 11.5 : 12.5),
                                                fontWeight: isCurrent ? FontWeight.w900 : (isPast ? FontWeight.normal : FontWeight.w600),
                                                fontStyle: isPast ? FontStyle.italic : FontStyle.normal,
                                                letterSpacing: isCurrent ? 0.3 : 0.0,
                                                shadows: isCurrent
                                                    ? [
                                                        Shadow(
                                                          color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
                                                          blurRadius: 8,
                                                        ),
                                                      ]
                                                    : null,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      // Real-time line progress sweep indicator for active line
                                      if (isCurrent)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(2),
                                            child: LinearProgressIndicator(
                                              value: linePct,
                                              minHeight: 2.5,
                                              backgroundColor: Colors.white10,
                                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),

                      const SizedBox(height: 8),

                      // ── YOUTUBE KARAOKE PLAYER (primary) ─────────────────
                      if (_ytCtrl != null) ...[
                        const SizedBox(height: 8),

                        // Collapsible header bar
                        InkWell(
                          onTap: () => setState(() => _showYtPlayer = !_showYtPlayer),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A0E1A),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _ytHasPlaybackError
                                    ? Colors.amberAccent.withValues(alpha: 0.6)
                                    : Colors.redAccent.withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(_ytHasPlaybackError ? '⚠️' : '▶️', style: const TextStyle(fontSize: 11)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    widget.gameState.isAcapellaModeActive
                                        ? '🏆 Saturday Acapella Arena • Raw Vocals (Muted Beat)'
                                        : _ytHasPlaybackError
                                            ? 'Audio Stream Active (Video Embed Restricted by Owner)'
                                            : _ytPlayerReady
                                                ? 'YouTube Karaoke • Beat + Lyrics (LIVE)'
                                                : 'YouTube Karaoke • Loading video...',
                                    style: TextStyle(
                                      color: widget.gameState.isAcapellaModeActive
                                          ? Colors.amberAccent
                                          : (_ytHasPlaybackError ? Colors.amberAccent : Colors.redAccent),
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ),
                                Icon(
                                  _showYtPlayer ? Icons.expand_less : Icons.expand_more,
                                  color: _ytHasPlaybackError ? Colors.amberAccent : Colors.redAccent,
                                  size: 16,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Embedded YouTube player or Error 150 Fallback Card
                        if (_showYtPlayer)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: _ytHasPlaybackError
                                ? Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF13192B),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.amberAccent.withValues(alpha: 0.5),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(7),
                                              decoration: BoxDecoration(
                                                color: Colors.amberAccent.withValues(alpha: 0.15),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Icon(Icons.music_note_rounded, color: Colors.amberAccent, size: 18),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    'HIGH-DEF AUDIO STREAM ACTIVE 🎵',
                                                    style: TextStyle(
                                                      color: AppTheme.neonEmerald,
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w900,
                                                      letterSpacing: 0.4,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'Owner blocked video embed (Error $_ytErrorCode). Backing music is playing seamlessly!',
                                                    style: const TextStyle(color: Colors.white70, fontSize: 10, height: 1.2),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            InkWell(
                                              onTap: _isFindingAlternative ? null : _tryAlternateVideo,
                                              borderRadius: BorderRadius.circular(8),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF202A44),
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.4)),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    if (_isFindingAlternative)
                                                      const SizedBox(
                                                        width: 11,
                                                        height: 11,
                                                        child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.cyanAccent),
                                                      )
                                                    else
                                                      const Icon(Icons.refresh_rounded, color: Colors.cyanAccent, size: 12),
                                                    const SizedBox(width: 4),
                                                    const Text(
                                                      'Try Alternate Video',
                                                      style: TextStyle(color: Colors.cyanAccent, fontSize: 9.5, fontWeight: FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            InkWell(
                                              onTap: _openInYoutubeApp,
                                              borderRadius: BorderRadius.circular(8),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                decoration: BoxDecoration(
                                                  color: Colors.redAccent.withValues(alpha: 0.2),
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
                                                ),
                                                child: const Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(Icons.open_in_new_rounded, color: Colors.redAccent, size: 12),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      'Open on YouTube',
                                                      style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: YoutubePlayer(
                                      controller: _ytCtrl!,
                                      showVideoProgressIndicator: true,
                                      progressIndicatorColor: Colors.redAccent,
                                      progressColors: const ProgressBarColors(
                                        playedColor: Colors.redAccent,
                                        handleColor: Color(0xFFFF2A6D),
                                        bufferedColor: Colors.white24,
                                        backgroundColor: Colors.black26,
                                      ),
                                      onReady: () {
                                        if (mounted) {
                                          setState(() {
                                            _ytPlayerReady = true;
                                          });
                                        }
                                        SoundService().stopKaraokeAudio();
                                      },
                                    ),
                                  ),
                          ),

                        const SizedBox(height: 6),

                        // Controls row: Restart | Finish | Mute/Unmute
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Restart: seek YouTube to 0
                            InkWell(
                              onTap: () {
                                _ytCtrl?.seekTo(Duration.zero);
                                _ytCtrl?.play();
                                widget.gameState.karaokeElapsedSeconds = 0;
                                if (mounted) setState(() {});
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.replay, color: Colors.white70, size: 11),
                                    SizedBox(width: 3),
                                    Text('Restart', style: TextStyle(color: Colors.white70, fontSize: 8.5, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Finish with Audience Voting Poll
                            InkWell(
                              onTap: _onFinishTurnWithVoting,
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF2A6D).withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFFF2A6D).withValues(alpha: 0.5), width: 0.8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.stop_circle_outlined, color: Color(0xFFFF2A6D), size: 11),
                                    SizedBox(width: 2),
                                    Text('Finish', style: TextStyle(color: Color(0xFFFF2A6D), fontSize: 8.5, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            // Mute/Unmute YouTube player
                            InkWell(
                              onTap: () {
                                if (_ytCtrl!.value.volume == 0) {
                                  _ytCtrl!.setVolume(100);
                                } else {
                                  _ytCtrl!.setVolume(0);
                                }
                                if (mounted) setState(() {});
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  (_ytCtrl?.value.volume ?? 100) == 0 ? Icons.volume_off : Icons.volume_up,
                                  color: (_ytCtrl?.value.volume ?? 100) == 0 ? Colors.redAccent : const Color(0xFF00E5FF),
                                  size: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        // ── FALLBACK: No YouTube video yet — show progress + WAV beat ─
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '${elapsed ~/ 60}:${(elapsed % 60).toString().padLeft(2, '0')}',
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 9, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 4,
                                  backgroundColor: Colors.white10,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF2A6D)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${total ~/ 60}:${(total % 60).toString().padLeft(2, '0')}',
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 9, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedBuilder(
                                  animation: _glowAnim,
                                  builder: (context, _) {
                                    final isPlaying = SoundService().isKaraokePlaying && !SoundService().isKaraokeMuted;
                                    return Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(width: 3, height: isPlaying ? (4 + 8 * _glowAnim.value) : 3,
                                          decoration: BoxDecoration(color: const Color(0xFF00E5FF), borderRadius: BorderRadius.circular(2))),
                                        const SizedBox(width: 2.5),
                                        Container(width: 3, height: isPlaying ? (11 - 6 * _glowAnim.value) : 5,
                                          decoration: BoxDecoration(color: const Color(0xFFFF2A6D), borderRadius: BorderRadius.circular(2))),
                                        const SizedBox(width: 2.5),
                                        Container(width: 3, height: isPlaying ? (5 + 7 * (1.0 - _glowAnim.value)) : 4,
                                          decoration: BoxDecoration(color: AppTheme.lagosYellow, borderRadius: BorderRadius.circular(2))),
                                      ],
                                    );
                                  },
                                ),
                                const SizedBox(width: 6),
                                const Text('🔍 Finding Karaoke Video...', style: TextStyle(color: Colors.white38, fontSize: 9, fontStyle: FontStyle.italic)),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () { widget.gameState.restartKaraokeTrack(); if (mounted) setState(() {}); },
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(6)),
                                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                                      Icon(Icons.replay, color: Colors.white70, size: 10),
                                      SizedBox(width: 3),
                                      Text('Restart', style: TextStyle(color: Colors.white70, fontSize: 8.5, fontWeight: FontWeight.bold)),
                                    ]),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                InkWell(
                                  onTap: _onFinishTurnWithVoting,
                                  borderRadius: BorderRadius.circular(6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF2A6D).withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color(0xFFFF2A6D).withValues(alpha: 0.4), width: 0.8),
                                    ),
                                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                                      Icon(Icons.skip_next, color: Color(0xFFFF2A6D), size: 11),
                                      SizedBox(width: 2),
                                      Text('Finish', style: TextStyle(color: Color(0xFFFF2A6D), fontSize: 8.5, fontWeight: FontWeight.bold)),
                                    ]),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                )
              else
                // OPEN STAGE BANNER
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C101D),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.35)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purpleAccent.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('🎙️ ', style: TextStyle(fontSize: 16)),
                          Text(
                            'THE STAGE IS YOURS!',
                            style: TextStyle(
                              color: Color(0xFF00E5FF),
                              fontSize: 12.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(' ✨', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'No one is singing right now. Tap the search bar above to search any song online and take the mic!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

              // 3. AUDIENCE REACTIONS DECK (Clap, Spray Naira, Buy Cocktail)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('🔥 ', style: TextStyle(fontSize: 12)),
                            Text(
                              isStageActive ? 'AUDIENCE REACTIONS:' : 'ROOM VIBES & CHEERS:',
                              style: const TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '🪙 ${gs.user.walletBalance}',
                          style: const TextStyle(
                            color: AppTheme.lagosYellow,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        // A. 👏 CLAP (Free Dopamine)
                        Expanded(
                          flex: 3,
                          child: InkWell(
                            onTap: _onClapTapped,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF231E3D),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.4)),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('👏 ', style: TextStyle(fontSize: 14)),
                                      const Text(
                                        'CLAP',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                      ),
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: Colors.black45,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${gs.karaokeClapCount}',
                                          style: const TextStyle(color: Colors.purpleAccent, fontSize: 9, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Free Emote',
                                    style: TextStyle(color: AppTheme.textMuted, fontSize: 8.5),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // B. 💸 SPRAY NAIRA (50 Credits -> 70% to Singer)
                        Expanded(
                          flex: 4,
                          child: InkWell(
                            onTap: _onSprayNairaTapped,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                gradient: isStageActive
                                    ? const LinearGradient(
                                        colors: [Color(0xFF00B0FF), Color(0xFF00E676)],
                                      )
                                    : LinearGradient(
                                        colors: [Colors.grey.shade800, Colors.grey.shade700],
                                      ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: isStageActive
                                    ? [
                                        BoxShadow(
                                          color: Colors.greenAccent.withValues(alpha: 0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text('💸 ', style: TextStyle(fontSize: 14)),
                                      Text(
                                        'SPRAY NAIRA',
                                        style: TextStyle(
                                          color: isStageActive ? Colors.black : Colors.white70,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 11,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isStageActive ? '50 🪙 (+35 to Singer)' : 'Takes 🎤 to spray',
                                    style: TextStyle(
                                      color: isStageActive ? Colors.black87 : Colors.white54,
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // C. 🍹 BUY COCKTAIL (50 Credits)
                        Expanded(
                          flex: 3,
                          child: InkWell(
                            onTap: _onCocktailTapped,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF331D2A),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isStageActive
                                      ? Colors.pinkAccent.withValues(alpha: 0.4)
                                      : Colors.white12,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('🍹 ', style: TextStyle(fontSize: 14)),
                                      Text(
                                        'COCKTAIL',
                                        style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isStageActive ? '50 🪙 (+150 XP)' : 'Stage Open',
                                    style: const TextStyle(color: AppTheme.lagosYellow, fontSize: 8.5),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Floating Animated Emoji Reactions
        ..._reactions.map((r) {
          final age = DateTime.now().difference(r.created).inMilliseconds;
          final progress = (age / 1200.0).clamp(0.0, 1.0);
          final opacity = (1.0 - progress).clamp(0.0, 1.0);
          final dy = (1.0 - progress) * 160.0;
          return Positioned(
            left: MediaQuery.of(context).size.width * r.startX,
            bottom: 40 + dy,
            child: Opacity(
              opacity: opacity,
              child: Text(
                r.emoji,
                style: const TextStyle(fontSize: 26),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _FloatingReaction {
  final String id;
  final String emoji;
  final double startX;
  final DateTime created;

  _FloatingReaction({
    required this.id,
    required this.emoji,
    required this.startX,
  }) : created = DateTime.now();
}

class KaraokeSongSearchModal extends StatefulWidget {
  final GameState gameState;
  final ValueChanged<KaraokeTrack> onTrackSelected;

  const KaraokeSongSearchModal({
    super.key,
    required this.gameState,
    required this.onTrackSelected,
  });

  @override
  State<KaraokeSongSearchModal> createState() => _KaraokeSongSearchModalState();
}

class _KaraokeSongSearchModalState extends State<KaraokeSongSearchModal> {
  final TextEditingController _searchCtrl = TextEditingController();
  final SongSearchService _searchService = SongSearchService();
  List<KaraokeTrack> _tracks = [];
  bool _isLoading = false;
  String? _syncingTrackId;
  String _selectedTag = 'All';
  Timer? _debounce;

  final List<Map<String, String>> _trendingTags = [
    {'label': '🔥 All Hits', 'query': ''},
    {'label': 'Davido 🚀', 'query': 'Davido'},
    {'label': 'Asake 🪵', 'query': 'Asake'},
    {'label': 'Burna Boy 🎷', 'query': 'Burna Boy'},
    {'label': 'Buga 🦚', 'query': 'Buga Kizz Daniel'},
    {'label': 'Omah Lay 🌊', 'query': 'Omah Lay'},
    {'label': 'Tems 🕊️', 'query': 'Tems'},
    {'label': 'Rema 💃', 'query': 'Rema'},
    {'label': 'Ayra Starr ⚡', 'query': 'Ayra Starr'},
    {'label': 'Amapiano 🪵', 'query': 'Amapiano'},
  ];

  @override
  void initState() {
    super.initState();
    _tracks = _searchService.getOfflineTrendingTracks();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 380), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
    });

    final results = await _searchService.searchTracks(query);

    if (mounted) {
      setState(() {
        _tracks = results;
        _isLoading = false;
      });
    }
  }

  void _selectTag(String label, String query) {
    setState(() {
      _selectedTag = label;
      _searchCtrl.text = query;
    });
    _performSearch(query);
  }

  Future<void> _handleSelectTrack(KaraokeTrack track) async {
    setState(() {
      _syncingTrackId = track.id;
    });

    // Fetch synced lyrics AND YouTube karaoke video ID in parallel
    final results = await Future.wait([
      _searchService.fetchSyncedLyricsWithDuration(
        track.title,
        track.artist,
        durationSeconds: track.durationSeconds,
      ),
      YoutubeService().findKaraokeVideoId(track.title, track.artist),
    ]);

    final lyricsResult = results[0] as KaraokeLyricsResult;
    final videoId = results[1] as String?;

    int finalDuration = math.max(track.durationSeconds, lyricsResult.durationSeconds);
    if (lyricsResult.lyrics.isNotEmpty && lyricsResult.lyrics.last.seconds > finalDuration - 6) {
      finalDuration = lyricsResult.lyrics.last.seconds + 6;
    }

    final finalTrack = track.copyWith(
      durationSeconds: finalDuration,
      lyrics: lyricsResult.lyrics,
      youtubeVideoId: videoId,
      hasRealLyrics: lyricsResult.hasRealLyrics,
    );

    if (mounted) {
      Navigator.of(context).pop();
      widget.onTrackSelected(finalTrack);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottomInset + 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Modal Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('🎤', style: TextStyle(fontSize: 22)),
                  SizedBox(width: 8),
                  Text(
                    'Search & Sing Along',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.lagosYellow.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.lagosYellow.withValues(alpha: 0.4)),
                ),
                child: const Text(
                  'Fee: 30 🪙',
                  style: TextStyle(color: AppTheme.lagosYellow, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Search any song online. Synced lyrics will guide your singing on stage! 🎵',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 11.5),
          ),
          const SizedBox(height: 12),

          // Search Bar Input Field
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1B2236),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.35)),
            ),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 13.5),
              onChanged: _onSearchChanged,
              onSubmitted: _performSearch,
              decoration: InputDecoration(
                hintText: 'Search song or artist (e.g. Davido, Asake, Buga)...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 12.5),
                prefixIcon: const Icon(Icons.search, color: Colors.cyanAccent, size: 20),
                suffixIcon: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.cyanAccent),
                        ),
                      )
                    : _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white60, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              _performSearch('');
                            },
                          )
                        : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Trending Tags Chips
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _trendingTags.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, idx) {
                final tag = _trendingTags[idx];
                final isSelected = _selectedTag == tag['label'];
                return InkWell(
                  onTap: () => _selectTag(tag['label']!, tag['query']!),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.cyanAccent.withValues(alpha: 0.2)
                          : const Color(0xFF1C2237),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? Colors.cyanAccent : Colors.white10,
                      ),
                    ),
                    child: Text(
                      tag['label']!,
                      style: TextStyle(
                        color: isSelected ? Colors.cyanAccent : Colors.white70,
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Results Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _searchCtrl.text.isEmpty ? '🔥 Trending Karaoke Bangers' : '🔍 Search Results (${_tracks.length})',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_isLoading)
                const Text(
                  'Fetching online...',
                  style: TextStyle(color: Colors.cyanAccent, fontSize: 10.5, fontStyle: FontStyle.italic),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Results List
          Expanded(
            child: _tracks.isEmpty && !_isLoading
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🎵', style: TextStyle(fontSize: 36)),
                        const SizedBox(height: 8),
                        Text(
                          'No match found for "${_searchCtrl.text}"',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.mic, size: 16),
                          label: const Text('Sing Custom Track With Auto-Sync Lyrics'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.purpleRoyal,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            final custom = KaraokeTrack(
                              id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                              title: _searchCtrl.text.trim().isNotEmpty ? _searchCtrl.text.trim() : 'Custom Anthem',
                              artist: widget.gameState.user.username,
                              emoji: '🎤',
                              durationSeconds: 30,
                              lyrics: _searchService.generateSynthesizedLyrics(
                                _searchCtrl.text.trim().isNotEmpty ? _searchCtrl.text.trim() : 'Custom Anthem',
                                widget.gameState.user.username,
                                30,
                              ),
                            );
                            _handleSelectTrack(custom);
                          },
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: _tracks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, idx) {
                      final track = _tracks[idx];
                      final isSyncing = _syncingTrackId == track.id;

                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B2236),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: track.artworkUrl != null
                                ? Image.network(
                                    track.artworkUrl!,
                                    width: 44,
                                    height: 44,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => CircleAvatar(
                                      backgroundColor: Colors.white12,
                                      child: Text(track.emoji, style: const TextStyle(fontSize: 18)),
                                    ),
                                  )
                                : CircleAvatar(
                                    backgroundColor: Colors.white12,
                                    child: Text(track.emoji, style: const TextStyle(fontSize: 18)),
                                  ),
                          ),
                          title: Text(
                            track.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  track.artist,
                                  style: const TextStyle(color: Colors.cyanAccent, fontSize: 11),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${track.durationSeconds}s',
                                  style: const TextStyle(color: Colors.white60, fontSize: 9.5),
                                ),
                              ),
                            ],
                          ),
                          trailing: isSyncing
                              ? const SizedBox(
                                  width: 80,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.cyanAccent),
                                      ),
                                      SizedBox(width: 6),
                                      Text('Syncing...', style: TextStyle(color: Colors.cyanAccent, fontSize: 10)),
                                    ],
                                  ),
                                )
                              : InkWell(
                                  onTap: () => _handleSelectTrack(track),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF8A2387), Color(0xFFE94057)],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.pinkAccent.withValues(alpha: 0.25),
                                          blurRadius: 6,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('🎤 ', style: TextStyle(fontSize: 11)),
                                        Text(
                                          'Sing This',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
