import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

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

  @override
  void initState() {
    super.initState();
    _glowAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowAnim.dispose();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(err, style: const TextStyle(fontWeight: FontWeight.bold)),
          duration: const Duration(seconds: 2),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(err, style: const TextStyle(fontWeight: FontWeight.bold)),
          duration: const Duration(seconds: 2),
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
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Text('🎤', style: TextStyle(fontSize: 22)),
                        SizedBox(width: 8),
                        Text(
                          'Join Karaoke Mic Queue',
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
                const SizedBox(height: 6),
                const Text(
                  'Select an Afrobeat track to sing. The whole room will listen, clap, and spray Naira on you! 💸',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: KaraokeTrack.curatedTracks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, idx) {
                      final track = KaraokeTrack.curatedTracks[idx];
                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B2236),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.white12,
                            child: Text(track.emoji, style: const TextStyle(fontSize: 18)),
                          ),
                          title: Text(
                            track.title,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          subtitle: Text(
                            track.artist,
                            style: const TextStyle(color: Colors.cyanAccent, fontSize: 11),
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppTheme.purpleRoyal,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Sing This 🎤',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ),
                          onTap: () {
                            Navigator.of(ctx).pop();
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
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gs = widget.gameState;
    final track = gs.karaokeCurrentTrack;
    final elapsed = gs.karaokeElapsedSeconds;
    final total = track.durationSeconds;
    final progress = total > 0 ? (elapsed / total).clamp(0.0, 1.0) : 0.0;

    // Find active lyric line based on elapsed seconds
    KaraokeLyricLine activeLine = track.lyrics.first;
    KaraokeLyricLine? prevLine;
    KaraokeLyricLine? nextLine;

    for (var i = 0; i < track.lyrics.length; i++) {
      if (elapsed >= track.lyrics[i].seconds) {
        activeLine = track.lyrics[i];
        if (i > 0) prevLine = track.lyrics[i - 1];
        if (i < track.lyrics.length - 1) nextLine = track.lyrics[i + 1];
      }
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
                          child: Text(gs.karaokeSingerAvatar, style: const TextStyle(fontSize: 20)),
                        );
                      },
                    ),
                    const SizedBox(width: 10),

                    // Singer Info & Song
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
                                  gs.karaokeSingerName,
                                  style: const TextStyle(
                                    color: Colors.white,
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
                                  '${track.title} • ${track.artist}',
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

                    // Take Mic Button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF2A6D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _openMicQueueModal,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🎤 Take Mic', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 2. SCROLLING / DYNAMIC LYRIC PROMPTER BOX
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C101D),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Previous line (dimmed)
                    if (prevLine != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          prevLine.text,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.35),
                            fontSize: 10.5,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    // Active Sung Line (Glowing Neon Cyan / Gold)
                    AnimatedBuilder(
                      animation: _glowAnim,
                      builder: (context, _) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            activeLine.text,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF00E5FF),
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                              shadows: [
                                Shadow(
                                  color: const Color(0xFF00E5FF).withValues(alpha: 0.7 * _glowAnim.value),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // Next line hint preview
                    if (nextLine?.text != null || activeLine.nextHint != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '( Next: "${nextLine?.text ?? activeLine.nextHint}" )',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppTheme.lagosYellow,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    const SizedBox(height: 8),

                    // Audio track progression bar
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
                        const Row(
                          children: [
                            Text('🔥 ', style: TextStyle(fontSize: 12)),
                            Text(
                              'AUDIENCE REACTIONS:',
                              style: TextStyle(
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
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF00B0FF), Color(0xFF00E676)],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.greenAccent.withValues(alpha: 0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('💸 ', style: TextStyle(fontSize: 14)),
                                      Text(
                                        'SPRAY NAIRA',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 11,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    '50 🪙 (+35 to Singer)',
                                    style: TextStyle(color: Colors.black87, fontSize: 8.5, fontWeight: FontWeight.w700),
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
                                border: Border.all(color: Colors.pinkAccent.withValues(alpha: 0.4)),
                              ),
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('🍹 ', style: TextStyle(fontSize: 14)),
                                      Text(
                                        'COCKTAIL',
                                        style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    '50 🪙 (+150 XP)',
                                    style: TextStyle(color: AppTheme.lagosYellow, fontSize: 8.5),
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
