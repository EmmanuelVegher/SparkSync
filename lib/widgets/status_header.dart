import 'package:flutter/material.dart';
import '../models/models.dart';
import '../screens/profile_screen.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import 'human_avatar_widget.dart';
import 'offline_location_picker_sheet.dart';
import 'two_go_star_ladder_sheet.dart';

class StatusHeader extends StatelessWidget {
  final GameState gameState;
  final VoidCallback? onEnergyTap;
  final VoidCallback? onWalletTap;

  const StatusHeader({
    super.key,
    required this.gameState,
    this.onEnergyTap,
    this.onWalletTap,
  });

  Widget _buildAvatarImage(UserStats user) {
    return HumanAvatarWidget(
      user: user,
      size: 46,
      showBorder: false,
    );
  }

  Color _getPresenceColor(TwoGoPresence p) {
    switch (p) {
      case TwoGoPresence.online:
        return AppTheme.neonEmerald;
      case TwoGoPresence.busy:
        return const Color(0xFFFF3B30);
      case TwoGoPresence.away:
        return AppTheme.lagosYellow;
      case TwoGoPresence.offline:
        return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = gameState.user;
    final rankColor = AppTheme.getRankColor(user.starRank.rankName);
    final presenceColor = _getPresenceColor(user.presence);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface.withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(
            color: gameState.isNepaBlackout ? AppTheme.lagosYellow.withValues(alpha: 0.4) : AppTheme.cardBorder,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Minimalist 2D Avatar with subtle presence indicator
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(gameState: gameState),
                  ),
                );
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: user.isVerified ? AppTheme.neonEmerald : rankColor.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: ClipOval(
                      child: _buildAvatarImage(user),
                    ),
                  ),
                  Positioned(
                    right: -1,
                    bottom: -1,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: presenceColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.cardSurface, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // User Info Column: Full Name on Line 1, [200] & [Amateur] & Location on Line 2
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Line 1: Full Username + Verified Icon (Unconstrained full width!)
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProfileScreen(gameState: gameState),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.username,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (user.isVerified) ...[
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.verified_rounded,
                            color: Colors.cyanAccent,
                            size: 14.5,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),

                  // Line 2: [🪙 200] + [★ AMATEUR] + 📍 Location (Aligned directly under the name!)
                  Row(
                    children: [
                      // Coins Chip
                      InkWell(
                        onTap: onWalletTap,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: AppTheme.darkShimmer,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.lagosYellow.withValues(alpha: 0.35)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🪙', style: TextStyle(fontSize: 10)),
                              const SizedBox(width: 3),
                              Text(
                                '${user.walletBalance}',
                                style: const TextStyle(
                                  color: AppTheme.lagosYellow,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Clean Rank Badge
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (ctx) => TwoGoStarLadderSheet(gameState: gameState),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: rankColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: rankColor.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            user.starRank.badgeTitle,
                            style: TextStyle(
                              color: rankColor,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Dynamic Location Indicator (State, LGA, Area) with tap-to-change
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (ctx) => OfflineLocationPickerSheet(gameState: gameState),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_on_rounded, size: 11, color: AppTheme.brandCoral),
                                const SizedBox(width: 2.5),
                                Flexible(
                                  child: Text(
                                    user.dynamicLocationDisplay,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppTheme.textMuted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Icon(Icons.arrow_drop_down_rounded, size: 13, color: AppTheme.textMuted),
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
    );
  }
}
