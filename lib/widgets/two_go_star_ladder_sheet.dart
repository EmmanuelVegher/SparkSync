import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

class TwoGoStarLadderSheet extends StatelessWidget {
  final GameState gameState;

  const TwoGoStarLadderSheet({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    final user = gameState.user;
    final currentRank = user.starRank;
    final nextRank = currentRank.nextRank;
    final progress = currentRank.progressToNext(user.xp);
    final rankColor = AppTheme.getRankColor(currentRank.rankName);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF101522) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : const Color(0xFFD1D1D6),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header with Expanded to prevent RenderFlex overflow
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '⭐ STAR PROGRESSION LADDER',
                        style: TextStyle(
                          color: AppTheme.lagosYellow,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                          letterSpacing: 0.8,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Your Clout & Social Status Score',
                        style: TextStyle(
                          color: isDark ? Colors.white.withValues(alpha: 0.6) : AppTheme.textMuted,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close_rounded,
                    color: isDark ? AppTheme.textMuted : const Color(0xFF8E8E93),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Divider(
            color: isDark ? const Color(0xFF222C42) : const Color(0xFFE5E5EA),
            height: 1,
          ),

          // Current Rank Showcase Card
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        rankColor.withValues(alpha: 0.25),
                        const Color(0xFF161E2E),
                      ]
                    : [
                        rankColor.withValues(alpha: 0.15),
                        const Color(0xFFF9F9FB),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: rankColor.withValues(alpha: isDark ? 0.5 : 0.4),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(user.avatarEmoji, style: const TextStyle(fontSize: 26)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.username,
                                  style: TextStyle(
                                    color: isDark ? Colors.white : AppTheme.textDark,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${user.xp} Total Clout XP',
                                  style: TextStyle(
                                    color: isDark ? AppTheme.skyCyan : const Color(0xFF007AFF),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: rankColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        currentRank.badgeTitle,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Progress Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        nextRank != null
                            ? 'Progress to ${nextRank.rankName}:'
                            : 'Legendary Status Achieved!',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : AppTheme.textDark,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        color: isDark ? Colors.white : AppTheme.textDark,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: isDark ? Colors.black38 : const Color(0xFFE5E5EA),
                    valueColor: AlwaysStoppedAnimation<Color>(rankColor),
                    minHeight: 9,
                  ),
                ),
                if (nextRank != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Need ${nextRank.requiredXp - user.xp} more XP to unlock ${nextRank.badgeTitle}',
                    style: TextStyle(
                      color: isDark ? AppTheme.textMuted : const Color(0xFF8E8E93),
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // All 8 Tiers List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: TwoGoStarRank.values.length,
              itemBuilder: (context, index) {
                final tier = TwoGoStarRank.values[index];
                final isCurrent = tier == currentRank;
                final isUnlocked = user.xp >= tier.requiredXp;
                final tierColor = AppTheme.getRankColor(tier.rankName);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? tierColor.withValues(alpha: isDark ? 0.14 : 0.08)
                        : (isDark ? const Color(0xFF141A28) : const Color(0xFFF2F2F7)),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isCurrent
                          ? tierColor
                          : (isDark
                              ? (isUnlocked ? Colors.white24 : Colors.white10)
                              : (isUnlocked ? const Color(0xFFD1D1D6) : const Color(0xFFE5E5EA))),
                      width: isCurrent ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: tierColor.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: tierColor, width: 1.5),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        color: tierColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    tier.badgeTitle,
                                    style: TextStyle(
                                      color: tierColor,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isUnlocked
                                  ? (isDark
                                      ? AppTheme.neonEmerald.withValues(alpha: 0.2)
                                      : const Color(0xFF34C759).withValues(alpha: 0.15))
                                  : (isDark ? Colors.white10 : const Color(0xFFE5E5EA)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              isUnlocked ? 'UNLOCKED ✅' : '${tier.requiredXp} XP',
                              style: TextStyle(
                                color: isUnlocked
                                    ? (isDark ? AppTheme.neonEmerald : const Color(0xFF1B873F))
                                    : (isDark ? AppTheme.textMuted : const Color(0xFF8E8E93)),
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Perks
                      ...tier.perks.map((perk) => Padding(
                            padding: const EdgeInsets.only(bottom: 3.0),
                            child: Row(
                              children: [
                                Icon(
                                  isUnlocked ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
                                  size: 13,
                                  color: isUnlocked
                                      ? (isDark ? AppTheme.neonEmerald : const Color(0xFF1B873F))
                                      : (isDark ? AppTheme.textMuted : const Color(0xFF8E8E93)),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    perk,
                                    style: TextStyle(
                                      color: isUnlocked
                                          ? (isDark ? Colors.white70 : AppTheme.textDark)
                                          : (isDark ? AppTheme.textMuted : const Color(0xFF8E8E93)),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
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
