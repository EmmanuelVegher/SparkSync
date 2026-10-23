import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/game_state.dart';
import '../services/location_service.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../widgets/gift_selection_sheet.dart';
import '../widgets/photo_vault_reveal_card.dart';

class SparkDeckScreen extends StatefulWidget {
  final GameState gameState;

  const SparkDeckScreen({super.key, required this.gameState});

  @override
  State<SparkDeckScreen> createState() => _SparkDeckScreenState();
}

class _SparkDeckScreenState extends State<SparkDeckScreen> {
  String _selectedFilter = 'All';
  bool _isScanningGps = false;

  List<String> get filterOptions => [
        'All',
        '⚡ < 3 km',
        '🚗 < 6 km',
        ...LocationService().activeConfig.neighborhoods,
      ];

  Future<void> _triggerLiveGpsScan() async {
    setState(() => _isScanningGps = true);
    SoundService().playSparkMatch();
    final pos = await LocationService().requestLiveGpsUpdate();
    if (mounted) {
      setState(() {
        _isScanningGps = false;
        // Recalculate and sort all profiles
        for (final p in widget.gameState.discoveryProfiles) {
          p.updateLiveDistance(
            LocationService().userLatitude,
            LocationService().userLongitude,
          );
        }
        widget.gameState.discoveryProfiles.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      });

      final cityName = LocationService().currentCity;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.neonEmerald,
          content: Text(
            pos != null
              ? '📍 Location updated! Showing people near you in $cityName'
              : '📍 Location updated for $cityName (${widget.gameState.discoveryProfiles.length} people near you)',
          ),
        ),
      );
    }
  }

  void _handleSwipe(MatchProfile profile, bool isSpark) {
    if (isSpark && widget.gameState.user.energy < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.brandCoral,
          content: Text('You need Energy ⚡! Eat some food from your bag to recharge.'),
        ),
      );
      return;
    }

    final success = widget.gameState.swipeProfile(profile, isSpark);
    if (success && isSpark) {
      SoundService().playSparkMatch();
      _showMatchCelebration(profile);
    }
  }

  void _showMatchCelebration(MatchProfile profile) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppTheme.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppTheme.skyCyan, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/images/app_logo_emblem.png', width: 56, height: 56),
              const SizedBox(height: 10),
              const Text(
                'IT\'S A MATCH!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.skyCyan,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'You and ${profile.name} liked each other in ${LocationService().currentCity}!',
                style: const TextStyle(fontSize: 14, color: AppTheme.textLight),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppTheme.nightObsidian,
                    child: Text(widget.gameState.user.avatarEmoji, style: const TextStyle(fontSize: 34)),
                  ),
                  const SizedBox(width: 14),
                  const Text('⚡', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 14),
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: AppTheme.nightObsidian,
                    child: Text(profile.avatarEmoji, style: const TextStyle(fontSize: 34)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.brandCoral,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Send a DM in Matches 💬', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allProfiles = widget.gameState.discoveryProfiles;
    final cityConfig = LocationService().activeConfig;

    final profiles = allProfiles.where((p) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == '⚡ < 3 km') return p.distanceKm <= 3.0;
      if (_selectedFilter == '🚗 < 6 km') return p.distanceKm <= 6.0;
      return p.neighborhood.toLowerCase().contains(_selectedFilter.toLowerCase());
    }).toList();

    return Column(
      children: [
        // Live GPS Status & Location Header
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.cardSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.cardBorder),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 18, color: AppTheme.neonEmerald),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${cityConfig.cityName} Live Location',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppTheme.neonEmerald.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'LIVE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.neonEmerald,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      'Showing people nearby in your area',
                      style: TextStyle(fontSize: 10, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: _isScanningGps
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.brandCoral),
                      )
                    : const Icon(Icons.my_location, size: 18, color: AppTheme.brandCoral),
                tooltip: 'Re-scan Live GPS Proximity',
                onPressed: _isScanningGps ? null : _triggerLiveGpsScan,
              ),
            ],
          ),
        ),

        // Location & Proximity Filter Chips Bar
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: filterOptions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final option = filterOptions[index];
              final isSelected = _selectedFilter == option;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedFilter = option;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.brandCoral : AppTheme.cardSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppTheme.brandCoral : AppTheme.cardBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 13,
                        color: isSelected ? Colors.white : AppTheme.brandCoral,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        option,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textLight,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Deck View
        Expanded(
          child: profiles.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('📍', style: TextStyle(fontSize: 54)),
                        const SizedBox(height: 16),
                        Text(
                          _selectedFilter == 'All'
                              ? 'You Have Explored All Singles in ${cityConfig.cityName}!'
                              : 'No Singles within $_selectedFilter in ${cityConfig.cityName}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try changing your distance filter or tap Refresh to find new people in ${cityConfig.cityName}.',
                          style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedFilter = 'All';
                              widget.gameState.syncWithSupabaseLive();
                            });
                          },
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Refresh People'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.brandCoral,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              final freshProfiles = LocationService().getProfilesForCity(
                                cityConfig.cityName,
                                userLat: LocationService().userLatitude,
                                userLon: LocationService().userLongitude,
                              );
                              widget.gameState.discoveryProfiles.addAll(freshProfiles);
                            });
                          },
                          icon: const Icon(Icons.people_outline, size: 16, color: AppTheme.skyCyan),
                          label: const Text('Load Demo Singles (For Testing)', style: TextStyle(color: AppTheme.skyCyan, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: _buildCardView(profiles.first),
                ),
        ),
      ],
    );
  }

  Widget _buildCardView(MatchProfile topProfile) {
    final cityConfig = LocationService().activeConfig;

    return Column(
      children: [
        // Card
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.cardSurface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Avatar Banner
                  Expanded(
                    flex: 4,
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF2E1A47), Color(0xFF16203B)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Text(
                              topProfile.avatarEmoji,
                              style: const TextStyle(fontSize: 88),
                            ),
                          ),
                          Positioned(
                            top: 14,
                            left: 14,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.neonEmerald.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${topProfile.syncScore}% VIBE SYNC',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 14,
                            right: 14,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.cardBorder),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.near_me, size: 12, color: AppTheme.brandCoral),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${topProfile.distanceKm} km away',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Bottom Left: Encrypted Photo Vault Teaser Pill
                          Positioned(
                            bottom: 12,
                            left: 14,
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => Dialog(
                                    backgroundColor: Colors.transparent,
                                    insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                                    child: PhotoVaultRevealCard(
                                      profile: topProfile,
                                      isUnlocked: false,
                                      userCredits: widget.gameState.user.walletBalance,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.75),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.65)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.lock_rounded, size: 12, color: Colors.orangeAccent),
                                    const SizedBox(width: 5),
                                    Text(
                                      '🔒 ${topProfile.realPhotos.length} Vaulted Photos',
                                      style: const TextStyle(
                                        color: Colors.orangeAccent,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Bottom Right: Star Clout Rank Pill
                          Positioned(
                            bottom: 12,
                            right: 14,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.getRankColor(topProfile.starRank.rankName).withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: AppTheme.getRankColor(topProfile.starRank.rankName),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                topProfile.starRank.badgeTitle,
                                style: TextStyle(
                                  color: AppTheme.getRankColor(topProfile.starRank.rankName),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Profile Details
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  '${topProfile.name}, ${topProfile.age}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.verified, size: 18, color: AppTheme.skyCyan),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.place, size: 13, color: AppTheme.brandCoral),
                              const SizedBox(width: 3),
                              Text(
                                '${topProfile.neighborhood}, ${topProfile.city.isNotEmpty ? topProfile.city : cityConfig.cityName}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                topProfile.occupation,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textMuted,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            topProfile.bio,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.textLight,
                              height: 1.35,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: topProfile.interests.map((interest) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.darkShimmer,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.cardBorder),
                                ),
                                child: Text(
                                  '#$interest',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.skyCyan,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Action Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Pass Button
            FloatingActionButton(
              heroTag: 'pass_btn',
              onPressed: () => _handleSwipe(topProfile, false),
              backgroundColor: AppTheme.cardSurface,
              elevation: 4,
              child: const Icon(Icons.close, color: Color(0xFFFF5252), size: 28),
            ),

            // Super-Spark with Gift
            FloatingActionButton.extended(
              heroTag: 'super_spark_btn',
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isScrollControlled: true,
                  builder: (_) => GiftSelectionSheet(
                    gameState: widget.gameState,
                    match: topProfile,
                  ),
                );
              },
              backgroundColor: AppTheme.lagosYellow,
              foregroundColor: Colors.black,
              icon: const Text('🎁', style: TextStyle(fontSize: 18)),
              label: const Text(
                'Send Gift',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
              ),
            ),

            // Spark / Like Button
            FloatingActionButton(
              heroTag: 'spark_btn',
              onPressed: () => _handleSwipe(topProfile, true),
              backgroundColor: AppTheme.brandCoral,
              elevation: 6,
              child: const Icon(Icons.favorite, color: Colors.white, size: 30),
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
