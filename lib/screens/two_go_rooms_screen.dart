import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/game_state.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';
import '../widgets/two_go_star_ladder_sheet.dart';
import 'two_go_room_view.dart';

class TwoGoRoomsScreen extends StatefulWidget {
  final GameState gameState;

  const TwoGoRoomsScreen({super.key, required this.gameState});

  @override
  State<TwoGoRoomsScreen> createState() => _TwoGoRoomsScreenState();
}

class _TwoGoRoomsScreenState extends State<TwoGoRoomsScreen> {
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.gameState,
      builder: (context, _) {
        final user = widget.gameState.user;

        final userCity = LocationService().currentCity.toLowerCase();
        final userState = user.stateName.toLowerCase();
        final userLga = user.lgaName.toLowerCase();
        final userHood = user.neighborhood.toLowerCase();

        // Check if room belongs to user's immediate city / state / region
        bool isRoomLocal(TwoGoChatRoom r) {
          if (r.city == null) return false;
          final rc = r.city!.toLowerCase();
          if (rc == userCity || userHood.contains(rc) || userState.contains(rc) || userLga.contains(rc)) return true;
          // Niger State & Minna
          if (userState.contains('niger') && rc == 'minna') return true;
          // FCT & Abuja
          if ((userState.contains('abuja') || userState.contains('fct')) && rc == 'abuja') return true;
          // Border proximity
          if ((userCity == 'abuja' && rc == 'minna') || (userCity == 'minna' && rc == 'abuja')) {
            return true;
          }
          return false;
        }

        final rooms = widget.gameState.twoGoRooms.where((r) {
          if (_selectedCategory == 'city') {
            return isRoomLocal(r);
          } else if (_selectedCategory == 'vibe') {
            return r.category == 'vibe';
          } else if (_selectedCategory == 'vip') {
            return r.category == 'vip';
          } else if (_selectedCategory == 'other_cities') {
            // Far away cities (e.g. Lagos when in Abuja or Minna)
            return r.category == 'city' && !isRoomLocal(r);
          } else {
            // 'all': Show local city rooms, vibe rooms, VIP rooms, and global diaspora, but NOT faraway cities!
            if (r.category == 'city' && r.city != null && !isRoomLocal(r)) {
              return false;
            }
            return true;
          }
        }).toList();

        // Sort: User's local city rooms first
        rooms.sort((a, b) {
          final aIsCity = isRoomLocal(a);
          final bIsCity = isRoomLocal(b);
          if (aIsCity && !bIsCity) return -1;
          if (!aIsCity && bIsCity) return 1;
          return 0;
        });

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: CustomScrollView(
            slivers: [
              // Minimalist Rooms Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Chat Rooms',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Drop in, chat live, and vibe with locals',
                                style: TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Builder(
                            builder: (context) {
                              final totalOnline = rooms.fold<int>(0, (sum, r) => sum + r.activeOnline);
                              final hasOnline = totalOnline > 0;
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: (hasOnline ? AppTheme.neonEmerald : AppTheme.brandCoral).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: (hasOnline ? AppTheme.neonEmerald : AppTheme.brandCoral).withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 7,
                                      height: 7,
                                      decoration: BoxDecoration(
                                        color: hasOnline ? AppTheme.neonEmerald : AppTheme.brandCoral,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      hasOnline ? '$totalOnline Online' : '${rooms.length} Rooms',
                                      style: TextStyle(
                                        color: hasOnline ? AppTheme.neonEmerald : Colors.white70,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _buildStarProgressionMicroBar(context, user),
                    ],
                  ),
                ),
              ),

              // Category Filter Pills
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      _buildCategoryChip('all', 'All Rooms'),
                      const SizedBox(width: 8),
                      _buildCategoryChip('city', '📍 Local City'),
                      const SizedBox(width: 8),
                      _buildCategoryChip('vibe', '🎵 Vibes'),
                      const SizedBox(width: 8),
                      _buildCategoryChip('vip', '👑 VIP Rooms'),
                      const SizedBox(width: 8),
                      _buildCategoryChip('other_cities', '✈️ Travel Mode'),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 14)),

              // Chatrooms List
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final room = rooms[index];
                      return _buildRoomCard(room);
                    },
                    childCount: rooms.length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 28)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(String cat, String label) {
    final isSelected = _selectedCategory == cat;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = cat;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.brandCoral : const Color(0xFF141926),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.brandCoral : const Color(0xFF222C42),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppTheme.textMuted,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildRoomCard(TwoGoChatRoom room) {
    final user = widget.gameState.user;
    final canEnter = room.canUserEnter(user);
    final isVip = room.category == 'vip';
    final userCity = LocationService().currentCity.toLowerCase();
    final userHood = user.neighborhood.toLowerCase();
    final isLocalCity = room.city != null && (
      room.city!.toLowerCase() == userCity || 
      userHood.contains(room.city!.toLowerCase()) ||
      (userCity == 'abuja' && room.city!.toLowerCase() == 'minna') ||
      (userCity == 'minna' && room.city!.toLowerCase() == 'abuja')
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isVip ? const Color(0xFF1D162B) : const Color(0xFF131926),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLocalCity
              ? Colors.cyanAccent.withValues(alpha: 0.5)
              : (isVip ? AppTheme.lagosYellow.withValues(alpha: 0.4) : const Color(0xFF222C42)),
          width: isLocalCity || isVip ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (!canEnter) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.redAccent,
                content: Text(
                  'Locked! Requires ${room.minStarRank.badgeTitle} or ${room.creditEntryCost} Credits.',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
            return;
          }

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (ctx) => TwoGoRoomView(
                room: room,
                gameState: widget.gameState,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Line 1: Full Room Name with Icon (Unconstrained full width!)
              Row(
                children: [
                  Text(room.iconEmoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      room.name.startsWith(room.iconEmoji)
                          ? room.name.substring(room.iconEmoji.length).trim()
                          : room.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.5,
                      ),
                    ),
                  ),
                  if (isVip)
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: AppTheme.lagosYellow.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.lagosYellow.withValues(alpha: 0.4), width: 1),
                      ),
                      child: const Text(
                        '👑 VIP',
                        style: TextStyle(
                          color: AppTheme.lagosYellow,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),

              // Line 2: [📍 Your City] and [• 0 Online] badges under the name
              Row(
                children: [
                  if (isLocalCity) ...[
                    Builder(
                      builder: (context) {
                        final userCity = LocationService().currentCity.toLowerCase();
                        final isDirect = room.city != null && room.city!.toLowerCase() == userCity;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.cyanAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.4), width: 1),
                          ),
                          child: Text(
                            isDirect ? '📍 Your City' : '📍 Local Region',
                            style: const TextStyle(
                              color: Colors.cyanAccent,
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 6),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: room.activeOnline > 0
                          ? AppTheme.neonEmerald.withValues(alpha: 0.15)
                          : AppTheme.textMuted.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: room.activeOnline > 0 ? AppTheme.neonEmerald : AppTheme.textMuted,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${room.activeOnline} Online',
                          style: TextStyle(
                            color: room.activeOnline > 0 ? AppTheme.neonEmerald : AppTheme.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                room.description,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
              ),
              const SizedBox(height: 8),

              // Latest Message Snippet
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Text('💬 ', style: TextStyle(fontSize: 11)),
                    Expanded(
                      child: Text(
                        room.latestMessage,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStarProgressionMicroBar(BuildContext context, UserStats user) {
    final currentRank = user.starRank;
    final nextRank = currentRank.nextRank;
    final progress = currentRank.progressToNext(user.xp);
    final rankColor = AppTheme.getRankColor(currentRank.rankName);
    final percentage = (progress * 100).toInt();

    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => TwoGoStarLadderSheet(gameState: widget.gameState),
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.cardSurface.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: rankColor.withValues(alpha: 0.28),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  currentRank.badgeTitle,
                  style: TextStyle(
                    color: rankColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
                if (nextRank != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 11,
                      color: AppTheme.textMuted.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    nextRank.badgeTitle,
                    style: TextStyle(
                      color: AppTheme.textMuted.withValues(alpha: 0.8),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  nextRank != null ? '$percentage% • ${user.xp} XP' : 'MAX 🌌',
                  style: TextStyle(
                    color: nextRank != null ? Colors.white.withValues(alpha: 0.85) : rankColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 14,
                  color: AppTheme.textMuted.withValues(alpha: 0.6),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Hairline 3.5px Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Stack(
                children: [
                  Container(
                    height: 3.5,
                    width: double.infinity,
                    color: Colors.white12,
                  ),
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0.02, 1.0),
                    child: Container(
                      height: 3.5,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            rankColor.withValues(alpha: 0.7),
                            rankColor,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: rankColor.withValues(alpha: 0.4),
                            blurRadius: 3,
                            spreadRadius: 0.5,
                          ),
                        ],
                      ),
                    ),
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
