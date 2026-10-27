import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/game_state.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import 'acapella_challenge_arena_modal.dart';

/// Displays the current weekly room mode banner and allows toggling/inspecting the schedule matrix
class RoomScheduleBanner extends StatelessWidget {
  final GameState gameState;

  const RoomScheduleBanner({
    super.key,
    required this.gameState,
  });

  static void showScheduleModal(BuildContext context, GameState gameState) {
    SoundService().playButtonTap();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141928),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isChallengeSelected = gameState.currentRoomScheduleMode == RoomScheduleMode.challenge;

            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Text('📅', style: TextStyle(fontSize: 20)),
                            SizedBox(width: 8),
                            Text(
                              'WEEKLY SCHEDULE & EVENTS',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white60, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Our rooms dynamically transform based on the weekly event calendar. You can switch modes or jump directly into the Saturday Challenge Arena:',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                    ),
                    const SizedBox(height: 16),

                    _scheduleTile(
                      mode: RoomScheduleMode.standard,
                      daysText: 'Mondays – Wednesdays',
                      icon: '🛋️',
                      title: 'Standard Lounge Mode',
                      description: 'Chill vibe, real-time chat & Afrobeat drum pads active.',
                      isSelected: gameState.currentRoomScheduleMode == RoomScheduleMode.standard,
                      onTap: () {
                        gameState.setRoomScheduleMode(RoomScheduleMode.standard);
                        setModalState(() {});
                      },
                    ),
                    const SizedBox(height: 10),

                    _scheduleTile(
                      mode: RoomScheduleMode.karaoke,
                      daysText: 'Thursdays & Fridays',
                      icon: '🎤',
                      title: 'Karaoke Nights',
                      description: 'Stage Mic open! Pick full songs, lyrics prompter & spray Naira.',
                      isSelected: gameState.currentRoomScheduleMode == RoomScheduleMode.karaoke,
                      onTap: () {
                        gameState.setRoomScheduleMode(RoomScheduleMode.karaoke);
                        setModalState(() {});
                      },
                    ),
                    const SizedBox(height: 10),

                    _scheduleTile(
                      mode: RoomScheduleMode.challenge,
                      daysText: 'Saturdays (The Ultimate Showdown)',
                      icon: '🏆',
                      title: 'Saturday Musical Challenge',
                      description: 'Acapella Arena! Raw vocals without music, live Zoom-style multi-user video grid & audience voting poll!',
                      isSelected: isChallengeSelected,
                      onTap: () {
                        gameState.setRoomScheduleMode(RoomScheduleMode.challenge);
                        setModalState(() {});
                      },
                    ),

                    const SizedBox(height: 16),

                    // Dedicated Highlighted Section to Enter Acapella Challenge Arena
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.amberAccent.withValues(alpha: 0.18),
                            const Color(0xFF1B233D),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.5), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amberAccent.withValues(alpha: 0.1),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('🔥', style: TextStyle(fontSize: 18)),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'SATURDAY ACAPELLA ARENA',
                                  style: TextStyle(
                                    color: Colors.amberAccent,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'ZOOM CALL GRID',
                                  style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Enter the 4-user video stage! 15s chorus preview plays, music stops, and contestants sing raw acapella numbered 1-by-1 with live voting.',
                            style: TextStyle(color: Colors.white70, fontSize: 11, height: 1.3),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.amberAccent,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  icon: const Text('🏆', style: TextStyle(fontSize: 15)),
                                  label: const Text(
                                    'Launch Acapella Arena',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    AcapellaChallengeArenaModal.launch(context, gameState);
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: gameState.isRegisteredForChallenge ? AppTheme.neonEmerald : Colors.amberAccent,
                                    side: BorderSide(
                                      color: gameState.isRegisteredForChallenge ? AppTheme.neonEmerald : Colors.amberAccent.withValues(alpha: 0.8),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () {
                                    final ok = gameState.registerInterestInMusicalChallenge();
                                    setModalState(() {});
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: ok ? AppTheme.neonEmerald : AppTheme.lagosYellow,
                                        content: Text(
                                          ok
                                              ? '🙋 You are registered for the Saturday Acapella Arena!'
                                              : '✅ You are already registered for this Saturday\'s Arena!',
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    gameState.isRegisteredForChallenge ? '✅ Entered' : '🙋 Sign Up',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
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
            );
          },
        );
      },
    );
  }

  void _showScheduleModal(BuildContext context) {
    showScheduleModal(context, gameState);
  }

  void _indicateInterest(BuildContext context) {
    SoundService().playButtonTap();
    final ok = gameState.registerInterestInMusicalChallenge();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: ok ? AppTheme.neonEmerald : AppTheme.lagosYellow,
        content: Text(
          ok
              ? '🙋 You are registered for the Saturday Acapella Arena! When your turn arrives, the live video stage will open raw.'
              : '✅ You are already registered for this Saturday\'s Arena!',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mode = gameState.currentRoomScheduleMode;
    final isChallenge = mode == RoomScheduleMode.challenge;
    final isKaraoke = mode == RoomScheduleMode.karaoke;

    final Color primaryColor = isChallenge
        ? Colors.amberAccent
        : isKaraoke
            ? AppTheme.neonEmerald
            : Colors.cyanAccent;

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 6, 14, 6),
      decoration: BoxDecoration(
        color: const Color(0xFF141928),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primaryColor.withValues(alpha: 0.4), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.12),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showScheduleModal(context),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Text(mode.emoji, style: const TextStyle(fontSize: 16)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              mode.shortTag,
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              mode.displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        mode.badgeDescription,
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 9.5),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (isChallenge)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amberAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _indicateInterest(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🙋', style: TextStyle(fontSize: 11)),
                        const SizedBox(width: 4),
                        Text(
                          gameState.isRegisteredForChallenge ? 'Entered' : 'Sign Up',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  )
                else
                  Icon(Icons.tune_rounded, color: primaryColor.withValues(alpha: 0.8), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _scheduleTile({
    required RoomScheduleMode mode,
    required String daysText,
    required String icon,
    required String title,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final Color color = mode == RoomScheduleMode.challenge
        ? Colors.amberAccent
        : mode == RoomScheduleMode.karaoke
            ? AppTheme.neonEmerald
            : Colors.cyanAccent;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : const Color(0xFF0F111E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : Colors.white12,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isSelected ? color : Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'ACTIVE NOW',
                            style: TextStyle(color: Colors.black, fontSize: 8.5, fontWeight: FontWeight.w900),
                          ),
                        ),
                    ],
                  ),
                  Text(
                    daysText,
                    style: TextStyle(color: color.withValues(alpha: 0.9), fontSize: 10, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
