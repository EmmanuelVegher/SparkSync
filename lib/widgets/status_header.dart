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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121214) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF242426) : const Color(0xFFE5E5EA),
            width: 0.5,
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
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppTheme.textDark,
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

                  // Line 2: [🪙 200] + [★ AMATEUR]
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Coins Chip
                      InkWell(
                        onTap: onWalletTap,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.darkShimmer : const Color(0xFFF2F2F7),
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
                    ],
                  ),
                  const SizedBox(height: 3),

                  // Line 3: Dynamic Location Indicator - Displayed in FULL without truncation
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (ctx) => OfflineLocationPickerSheet(gameState: gameState),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.only(top: 2, bottom: 1),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 1.5),
                            child: Icon(
                              user.isTravelMode ? Icons.flight_takeoff_rounded : Icons.location_on_rounded,
                              size: 11.5,
                              color: user.isTravelMode
                                  ? (isDark ? Colors.cyanAccent : const Color(0xFF0071E3))
                                  : AppTheme.brandCoral,
                            ),
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: user.isTravelMode
                                ? Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '✈️ Traveling: ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isDark ? Colors.cyanAccent : const Color(0xFF0071E3),
                                          ),
                                        ),
                                        TextSpan(text: user.dynamicLocationDisplay),
                                      ],
                                    ),
                                    softWrap: true,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      color: isDark ? AppTheme.textMuted : const Color(0xFF6E6E73),
                                      fontWeight: FontWeight.w500,
                                      height: 1.25,
                                    ),
                                  )
                                : Text(
                                    user.dynamicLocationDisplay,
                                    softWrap: true,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      color: isDark ? AppTheme.textMuted : const Color(0xFF6E6E73),
                                      fontWeight: FontWeight.w500,
                                      height: 1.25,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 2),
                          Padding(
                            padding: const EdgeInsets.only(top: 0.5),
                            child: Icon(
                              Icons.arrow_drop_down_rounded,
                              size: 14,
                              color: isDark ? AppTheme.textMuted : const Color(0xFF6E6E73),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Apple Theme Mode Toggle Icon (☀️ Light / 🌙 Dark)
            Tooltip(
              message: isDark ? 'Switch to Light Theme' : 'Switch to Dark Theme',
              child: InkWell(
                onTap: () => gameState.toggleTheme(),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFE5E5EA),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFD1D1D6),
                      width: 0.5,
                    ),
                  ),
                  child: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    size: 17,
                    color: isDark ? const Color(0xFFFFD60A) : const Color(0xFF1D1D1F),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
