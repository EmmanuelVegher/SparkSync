import 'package:flutter/material.dart';
import '../services/game_state.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ambient_particle_sky.dart';
import '../widgets/nepa_banner.dart';
import 'avatar_onboarding_screen.dart';
import 'daily_gacha_wheel_screen.dart';
import 'inventory_screen.dart';
import 'selfie_liveness_screen.dart';
import 'venues_screen.dart';

class DashboardScreen extends StatelessWidget {
  final GameState gameState;
  final Function(int) onNavigateTab;

  const DashboardScreen({
    super.key,
    required this.gameState,
    required this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context) {
    final user = gameState.user;

    return AmbientParticleSky(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dynamic Lagos Event Alert (e.g. NEPA, traffic)
            NepaBanner(gameState: gameState),

            // Minimalist City Hub Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'City Hub',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Rewards, local hustles, shop & chill venues',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141926),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF222C42)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('⚡ ', style: TextStyle(fontSize: 12)),
                        Text(
                          '${user.energy}/${user.maxEnergy}',
                          style: const TextStyle(
                            color: AppTheme.neonEmerald,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Quick City Hub 2x2 Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      _buildHubTile(
                        icon: '🎁',
                        title: 'Daily Spin',
                        subtitle: user.canClaimDailyGacha
                            ? 'Free Spin Ready!'
                            : (user.currentStreakDays > 0 ? '${user.currentStreakDays}d streak' : 'Next spin tomorrow'),
                        badgeText: user.canClaimDailyGacha ? 'READY' : (user.currentStreakDays > 0 ? '🔥 ${user.currentStreakDays}d' : null),
                        badgeColor: user.canClaimDailyGacha ? AppTheme.neonEmerald : AppTheme.lagosYellow,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DailyGachaWheelScreen(gameState: gameState),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      _buildHubTile(
                        icon: '🎒',
                        title: 'Bag & Shop',
                        subtitle: 'Snacks, items & flairs',
                        badgeText: 'MALL',
                        badgeColor: AppTheme.skyCyan,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => InventoryScreen(gameState: gameState),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildHubTile(
                        icon: '🌆',
                        title: 'Dating Venues',
                        subtitle: '${gameState.venues.length} local hotspots',
                        badgeText: 'LIVE',
                        badgeColor: AppTheme.brandCoral,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VenuesScreen(gameState: gameState),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),
                      _buildHubTile(
                        icon: user.isVerified ? '🎨' : '📸',
                        title: user.isVerified ? 'Avatar Studio' : 'Selfie Verify',
                        subtitle: user.isVerified ? 'Customize 2D look' : 'Verify for badge & XP',
                        badgeText: user.isVerified ? 'VERIFIED' : '+150 XP',
                        badgeColor: user.isVerified ? const Color(0xFF76B900) : Colors.amberAccent,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => user.isVerified
                                  ? AvatarOnboardingScreen(
                                      gameState: gameState,
                                      isUpdateMode: true,
                                    )
                                  : SelfieLivenessScreen(
                                      gameState: gameState,
                                      isModal: true,
                                    ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

          const SizedBox(height: 18),

          // Active Hustles Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Text('💼', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 6),
                    Text(
                      'City Jobs & Work',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Earn Coins & XP',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.neonEmerald.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Hustles List
          ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: gameState.hustles.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final job = gameState.hustles[index];
              final cooldown = gameState.activeHustleCooldowns[job.id] ?? 0;
              final isCoolingDown = cooldown > 0;
              final hasEnergy = user.energy >= job.energyCost;

              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isCoolingDown
                        ? AppTheme.neonEmerald.withValues(alpha: 0.5)
                        : AppTheme.cardBorder,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.darkShimmer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(job.iconEmoji, style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            job.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            job.description,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            runSpacing: 2,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                '-${job.energyCost} ⚡',
                                style: const TextStyle(
                                  color: AppTheme.brandCoral,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '+${job.coinReward} 🪙',
                                style: const TextStyle(
                                  color: AppTheme.lagosYellow,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '• ${job.hood}',
                                style: const TextStyle(
                                  color: AppTheme.skyCyan,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: isCoolingDown || !hasEnergy
                          ? null
                          : () {
                              final ok = gameState.startHustle(job);
                              if (ok) {
                                if (job.id == 'danfo_conductor') {
                                  SoundService().playDanfoHorn();
                                } else {
                                  SoundService().playCoinEarned();
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppTheme.neonEmerald,
                                    duration: const Duration(seconds: 2),
                                    content: Text('Hustle complete! Earned +${job.coinReward} 🪙'),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.neonEmerald,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: AppTheme.darkShimmer,
                        disabledForegroundColor: AppTheme.textMuted,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        isCoolingDown
                            ? '${cooldown}s'
                            : (hasEnergy ? 'Hustle' : 'Low ⚡'),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 22),

          // Hotspots Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Text('🌆', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 6),
                    Text(
                      'Live Dating Hotspots',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VenuesScreen(gameState: gameState),
                      ),
                    );
                  },
                  child: const Text(
                    'View All →',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.brandCoral,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Quick Venues Horizontal Scroll
          SizedBox(
            height: 140,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: gameState.venues.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final venue = gameState.venues[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VenuesScreen(gameState: gameState),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 200,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.cardSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(venue.iconEmoji, style: const TextStyle(fontSize: 22)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.brandCoral.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.circle, size: 6, color: AppTheme.brandCoral),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${venue.activeSingles} live',
                                    style: const TextStyle(
                                      color: AppTheme.brandCoral,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          venue.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          venue.vibeTag,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.lagosYellow,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    ),
  );
}

  Widget _buildHubTile({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? badgeText,
    Color? badgeColor,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF131926),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF222C42)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(icon, style: const TextStyle(fontSize: 22)),
                  if (badgeText != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: (badgeColor ?? AppTheme.brandCoral).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badgeText,
                        style: TextStyle(
                          color: badgeColor ?? AppTheme.brandCoral,
                          fontWeight: FontWeight.w900,
                          fontSize: 9,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
