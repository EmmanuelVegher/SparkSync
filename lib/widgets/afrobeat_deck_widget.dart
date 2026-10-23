import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/game_state.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import 'karaoke_stage_widget.dart';

class AfrobeatDeckWidget extends StatefulWidget {
  final GameState gameState;
  final String roomId;

  const AfrobeatDeckWidget({
    super.key,
    required this.gameState,
    required this.roomId,
  });

  @override
  State<AfrobeatDeckWidget> createState() => _AfrobeatDeckWidgetState();
}

class _AfrobeatDeckWidgetState extends State<AfrobeatDeckWidget> with TickerProviderStateMixin {
  late AnimationController _vinylAnim;
  late AnimationController _equalizerAnim;
  final List<_FloatingParticle> _particles = [];
  bool _isBackingLoopActive = false;
  String _selectedMode = 'karaoke'; // 'karaoke' or 'dj'

  final List<Map<String, String>> _afrobeatTracks = const [
    {'title': 'Burna Boy - City Boys (Ambiance Loop)', 'emoji': '🔥', 'tag': 'High Energy'},
    {'title': 'Asake - Lonely At The Top (Log Drum Cut)', 'emoji': '🪵', 'tag': 'Amapiano'},
    {'title': 'Rema - Calm Down (Vibe Rhythms)', 'emoji': '✨', 'tag': 'Afro-Rave'},
    {'title': 'Ayra Starr - Rush (Groove Edition)', 'emoji': '💫', 'tag': 'Vocal Afrobeat'},
    {'title': 'Wizkid - Essence (Chill Nightlife)', 'emoji': '🎷', 'tag': 'Mellow'},
    {'title': 'Davido - Unavailable (Club Mix)', 'emoji': '🚀', 'tag': 'Banger'},
  ];

  @override
  void initState() {
    super.initState();
    _vinylAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _equalizerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _vinylAnim.dispose();
    _equalizerAnim.dispose();
    SoundService().stopAfrobeatLoop();
    super.dispose();
  }

  void _spawnParticle(String emoji) {
    if (!mounted) return;
    setState(() {
      _particles.add(
        _FloatingParticle(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          emoji: emoji,
          startX: 0.15 + math.Random().nextDouble() * 0.70,
        ),
      );
      if (_particles.length > 14) {
        _particles.removeAt(0);
      }
    });

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() {
          _particles.removeWhere((p) => DateTime.now().difference(p.created).inMilliseconds > 1300);
        });
      }
    });
  }

  void _onPadTapped(String padId, String emoji) {
    final err = widget.gameState.triggerAfrobeatPad(padId);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(err, style: const TextStyle(fontWeight: FontWeight.bold)),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      _spawnParticle(emoji);
    }
  }

  void _onHypeTapped() {
    widget.gameState.hypeAfrobeatDj();
    _spawnParticle('🔥');
    _spawnParticle('🎶');
  }

  void _onBooTapped() {
    widget.gameState.booAfrobeatDj();
    _spawnParticle('👎');
    _spawnParticle('💨');
  }

  void _openQueueModal() {
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
                        Text('🎧', style: TextStyle(fontSize: 22)),
                        SizedBox(width: 8),
                        Text(
                          'Take The DJ Decks',
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
                      child: const Row(
                        children: [
                          Text('Cost: 20 🪙', style: TextStyle(color: AppTheme.lagosYellow, fontWeight: FontWeight.bold, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Choose an Afrobeat banger loop. The crowd will vote 🔥 HYPE or 👎 BOO on your set!',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _afrobeatTracks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, idx) {
                      final track = _afrobeatTracks[idx];
                      return Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B2236),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.white12,
                            child: Text(track['emoji']!, style: const TextStyle(fontSize: 18)),
                          ),
                          title: Text(
                            track['title']!,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          subtitle: Text(
                            track['tag']!,
                            style: const TextStyle(color: Colors.cyanAccent, fontSize: 11),
                          ),
                          trailing: const Icon(Icons.play_circle_fill_rounded, color: AppTheme.neonEmerald, size: 24),
                          onTap: () {
                            Navigator.of(ctx).pop();
                            final err = widget.gameState.joinAfrobeatDjQueue(track['title']!);
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
                                  content: Text('🎉 Stepped into the DJ booth with "${track['title']}"!'),
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

  Widget _buildModeSwitcher() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF13172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedMode = 'karaoke'),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  gradient: _selectedMode == 'karaoke'
                      ? const LinearGradient(
                          colors: [Color(0xFFFF2A6D), Color(0xFF9C27B0)],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🎤 ', style: TextStyle(fontSize: 12)),
                    Text(
                      'Live Karaoke Stage',
                      style: TextStyle(
                        color: _selectedMode == 'karaoke' ? Colors.white : AppTheme.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedMode = 'dj'),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  gradient: _selectedMode == 'dj'
                      ? const LinearGradient(
                          colors: [AppTheme.purpleRoyal, Color(0xFF00B0FF)],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🎧 ', style: TextStyle(fontSize: 12)),
                    Text(
                      'DJ Deck & Drum Pad',
                      style: TextStyle(
                        color: _selectedMode == 'dj' ? Colors.white : AppTheme.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildModeSwitcher(),
        if (_selectedMode == 'karaoke')
          KaraokeStageWidget(
            gameState: widget.gameState,
            roomId: widget.roomId,
          )
        else
          _buildDjDeck(context),
      ],
    );
  }

  Widget _buildDjDeck(BuildContext context) {
    final gs = widget.gameState;
    final hypeProgress = gs.afrobeatHypeProgress;
    final hypePct = (hypeProgress * 100).toInt();

    // Dynamic Hype Color (Emerald when > 65%, Amber when 35-65%, Red when < 35%)
    final hypeColor = hypeProgress > 0.65
        ? AppTheme.neonEmerald
        : (hypeProgress > 0.35 ? AppTheme.lagosYellow : Colors.redAccent);

    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(10, 4, 10, 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF16192E),
                Color(0xFF121424),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF2B3354), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. DJ DECK HEADER & ACTIVE STATUS
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                child: Row(
                  children: [
                    // Spinning DJ Vinyl / Avatar
                    RotationTransition(
                      turns: _vinylAnim,
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const SweepGradient(
                            colors: [
                              Colors.black,
                              Color(0xFF282828),
                              Colors.black,
                              Color(0xFF383838),
                              Colors.black,
                            ],
                          ),
                          border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.8), width: 1.5),
                        ),
                        alignment: Alignment.center,
                        child: Text(gs.afrobeatDjAvatar, style: const TextStyle(fontSize: 18)),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // DJ Info & Current Track
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'ON DECKS: ',
                                style: TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  gs.afrobeatDjName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.5,
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
                              // Animated equalizer bars
                              AnimatedBuilder(
                                animation: _equalizerAnim,
                                builder: (context, _) {
                                  return Row(
                                    children: List.generate(4, (i) {
                                      final heights = [
                                        6.0 + 8.0 * _equalizerAnim.value,
                                        12.0 - 6.0 * _equalizerAnim.value,
                                        8.0 + 6.0 * _equalizerAnim.value,
                                        14.0 - 8.0 * _equalizerAnim.value,
                                      ];
                                      return Container(
                                        width: 2.2,
                                        height: heights[i],
                                        margin: const EdgeInsets.only(right: 2),
                                        decoration: BoxDecoration(
                                          color: AppTheme.neonEmerald,
                                          borderRadius: BorderRadius.circular(1),
                                        ),
                                      );
                                    }),
                                  );
                                },
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  gs.afrobeatTrackTitle,
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

                    // Take Decks Queue Button & Ambient Loop Toggle
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Backing loop toggle
                        IconButton(
                          iconSize: 20,
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                          tooltip: 'Toggle Ambient Afrobeat Loop',
                          icon: Icon(
                            _isBackingLoopActive ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                            color: _isBackingLoopActive ? AppTheme.neonEmerald : Colors.white38,
                          ),
                          onPressed: () async {
                            final state = await SoundService().toggleAfrobeatLoop();
                            setState(() {
                              _isBackingLoopActive = state;
                            });
                          },
                        ),
                        const SizedBox(width: 6),
                        // Join DJ Queue button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.purpleRoyal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: _openQueueModal,
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('🎧 Take Decks', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 2. THE CROWD HYPE METER & CROWD VOTING BUTTONS
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D101C),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Text('CROWD HYPE: ', style: TextStyle(color: AppTheme.textMuted, fontSize: 10.5, fontWeight: FontWeight.w700)),
                            Text(
                              '$hypePct% 🔥',
                              style: TextStyle(color: hypeColor, fontWeight: FontWeight.w900, fontSize: 12),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(color: AppTheme.neonEmerald, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${gs.afrobeatPartyGoers} in Party',
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 10.5, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: hypeProgress,
                        minHeight: 6,
                        backgroundColor: Colors.white10,
                        valueColor: AlwaysStoppedAnimation<Color>(hypeColor),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Hype & Boo Massive Action Buttons
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: InkWell(
                            onTap: _onHypeTapped,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFF3D00), Color(0xFFFF9100)],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.redAccent.withValues(alpha: 0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('🔥 ', style: TextStyle(fontSize: 13)),
                                  const Text(
                                    'HYPE DJ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: Colors.black38,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${gs.afrobeatHypeCount}',
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: InkWell(
                            onTap: _onBooTapped,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF26192A),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('👎 ', style: TextStyle(fontSize: 13)),
                                  const Text(
                                    'BOO',
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '(${gs.afrobeatBooCount})',
                                    style: const TextStyle(color: Colors.white54, fontSize: 10),
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

              // 3. AFROBEAT DRUM PAD / LIVE SOUNDBOARD GRID
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Text('🎶 ', style: TextStyle(fontSize: 12)),
                            Text(
                              'TAP TO DROP LIVE BEATS & AD-LIBS:',
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
                    // Row 1 of Pads: Kick, Conga, Sheesh
                    Row(
                      children: [
                        Expanded(child: _buildSoundboardPad(title: 'Kick / Log', emoji: '🥁', cost: 1, id: 'kick')),
                        const SizedBox(width: 6),
                        Expanded(child: _buildSoundboardPad(title: 'Conga', emoji: '🪘', cost: 1, id: 'conga')),
                        const SizedBox(width: 6),
                        Expanded(child: _buildSoundboardPad(title: '"Sheesh!"', emoji: '🗣️', cost: 2, id: 'sheesh')),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Row 2 of Pads: Sax, Agogo Bell, Airhorn
                    Row(
                      children: [
                        Expanded(child: _buildSoundboardPad(title: 'Saxophone', emoji: '🎷', cost: 2, id: 'sax')),
                        const SizedBox(width: 6),
                        Expanded(child: _buildSoundboardPad(title: 'Agogô Bell', emoji: '🔔', cost: 1, id: 'bell')),
                        const SizedBox(width: 6),
                        Expanded(child: _buildSoundboardPad(title: 'Airhorn!', emoji: '📣', cost: 5, id: 'airhorn', isSpecial: true)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Floating Animated Emoji Particles Overlay
        ..._particles.map((p) {
          final age = DateTime.now().difference(p.created).inMilliseconds;
          final progress = (age / 1200.0).clamp(0.0, 1.0);
          final opacity = (1.0 - progress).clamp(0.0, 1.0);
          final dy = (1.0 - progress) * 160.0;
          return Positioned(
            left: MediaQuery.of(context).size.width * p.startX,
            bottom: 40 + dy,
            child: Opacity(
              opacity: opacity,
              child: Text(
                p.emoji,
                style: const TextStyle(fontSize: 26),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSoundboardPad({
    required String title,
    required String emoji,
    required int cost,
    required String id,
    bool isSpecial = false,
  }) {
    return InkWell(
      onTap: () => _onPadTapped(id, emoji),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
        decoration: BoxDecoration(
          color: isSpecial
              ? const Color(0xFF35172C)
              : const Color(0xFF1E2338),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSpecial
                ? Colors.pinkAccent.withValues(alpha: 0.5)
                : const Color(0xFF2C3552),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isSpecial ? Colors.pinkAccent : Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '$cost 🪙',
              style: TextStyle(
                color: isSpecial ? AppTheme.lagosYellow : AppTheme.textMuted,
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingParticle {
  final String id;
  final String emoji;
  final double startX;
  final DateTime created;

  _FloatingParticle({
    required this.id,
    required this.emoji,
    required this.startX,
  }) : created = DateTime.now();
}
