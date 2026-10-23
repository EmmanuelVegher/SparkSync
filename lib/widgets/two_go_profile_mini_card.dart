import 'package:flutter/material.dart';
import '../models/models.dart';
import '../screens/profile_screen.dart';
import '../services/game_state.dart';
import '../services/location_service.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import 'human_avatar_widget.dart';
import 'two_go_presence_sheet.dart';

class TwoGoProfileMiniCard extends StatefulWidget {
  final String senderId;
  final String name;
  final String avatar;
  final TwoGoStarRank starRank;
  final String? statusText;
  final bool hasNeonGlow;
  final String roomId;
  final GameState gameState;
  final VoidCallback? onDirectMessage;

  const TwoGoProfileMiniCard({
    super.key,
    required this.senderId,
    required this.name,
    required this.avatar,
    required this.starRank,
    this.statusText,
    this.hasNeonGlow = false,
    required this.roomId,
    required this.gameState,
    this.onDirectMessage,
  });

  @override
  State<TwoGoProfileMiniCard> createState() => _TwoGoProfileMiniCardState();
}

class _TwoGoProfileMiniCardState extends State<TwoGoProfileMiniCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Widget _buildAvatarImage(bool isMe, String fallbackEmoji) {
    if (isMe) {
      return HumanAvatarWidget(
        user: widget.gameState.user,
        size: 58,
        showBorder: false,
      );
    }
    return HumanAvatarWidget(
      avatarEmoji: fallbackEmoji,
      size: 58,
      showBorder: false,
    );
  }

  String _resolveLocation(bool isMe, UserStats user) {
    if (isMe) {
      final hood = user.neighborhood.isNotEmpty ? user.neighborhood : 'Maitama';
      final city = LocationService().activeConfig.cityName;
      return '$hood, $city';
    }
    // Dynamic location based on active chatroom
    final rName = widget.roomId.toLowerCase();
    if (rName.contains('abuja') || widget.gameState.twoGoRooms.any((r) => r.id == widget.roomId && r.name.toLowerCase().contains('abuja'))) {
      return 'Maitama, Abuja (1.4 km away)';
    } else if (rName.contains('lagos') || widget.gameState.twoGoRooms.any((r) => r.id == widget.roomId && r.name.toLowerCase().contains('lagos'))) {
      return 'Victoria Island, Lagos (2.2 km away)';
    } else if (rName.contains('ph') || rName.contains('port')) {
      return 'GRA Phase 2, Port Harcourt (1.8 km away)';
    }
    return '${user.neighborhood} (Nearby)';
  }

  @override
  Widget build(BuildContext context) {
    final rankColor = AppTheme.getRankColor(widget.starRank.rankName);
    final user = widget.gameState.user;
    final isMe = widget.name == user.username;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF131926),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppTheme.brandCoral.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.flash_on_rounded, color: AppTheme.brandCoral, size: 16),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'PING INTERACTION LOUNGE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 13,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted, size: 22),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Animated Neon Glowing Canvas
            AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                final double glowVal = _glowController.value;
                return Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: widget.hasNeonGlow
                        ? LinearGradient(
                            colors: [
                              Colors.cyanAccent.withValues(alpha: 0.7 + (glowVal * 0.3)),
                              Colors.pinkAccent.withValues(alpha: 0.7 + (glowVal * 0.3)),
                              Colors.purpleAccent.withValues(alpha: 0.7 + (glowVal * 0.3)),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    border: !widget.hasNeonGlow
                        ? Border.all(color: rankColor.withValues(alpha: 0.4), width: 1.5)
                        : null,
                    boxShadow: widget.hasNeonGlow
                        ? [
                            BoxShadow(
                              color: Colors.cyanAccent.withValues(alpha: 0.25 * glowVal),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1420),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    // Avatar with online beacon & Encrypted Vault Lock badge
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF1E2638),
                            border: Border.all(color: rankColor, width: 2),
                          ),
                          child: ClipOval(
                            child: _buildAvatarImage(isMe, widget.avatar),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 13,
                            height: 13,
                            decoration: BoxDecoration(
                              color: AppTheme.neonEmerald,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                          ),
                        ),
                        Positioned(
                          top: -3,
                          right: -3,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.orangeAccent, width: 1.5),
                            ),
                            child: const Icon(Icons.lock_rounded, size: 10, color: Colors.orangeAccent),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),

                    // User Info & SparkSync Rank Badge
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  widget.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              if (widget.starRank.index >= TwoGoStarRank.veteran.index || (isMe && user.isVerified))
                                const Icon(Icons.verified_rounded, color: Colors.cyanAccent, size: 17),
                            ],
                          ),
                          const SizedBox(height: 4),

                          // SparkSync Status Tier Tag & Vault Teaser Pill
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: rankColor.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: rankColor.withValues(alpha: 0.5)),
                                ),
                                child: Text(
                                  widget.starRank.badgeTitle,
                                  style: TextStyle(
                                    color: rankColor,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 10.5,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.orangeAccent.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.5)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.lock_rounded, size: 10, color: Colors.orangeAccent),
                                    SizedBox(width: 3),
                                    Text(
                                      '🔒 4 Vault Photos',
                                      style: TextStyle(color: Colors.orangeAccent, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Status Text
                          Text(
                            '"${widget.statusText ?? 'Chilling, no dry chats pls.'}"',
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Dynamic Stats Deck
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF161D2B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📊 STATS DECK',
                    style: TextStyle(
                      color: AppTheme.lagosYellow,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 14, color: AppTheme.brandCoral),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Location: ${_resolveLocation(isMe, user)}',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.shield_rounded, size: 14, color: Colors.cyanAccent),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          isMe
                              ? 'Identity: Anti-Catfish Biometric Verified ✅'
                              : 'Identity: 2D Custom Avatar Active 🛡️',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.card_giftcard_rounded, size: 14, color: AppTheme.lagosYellow),
                      const SizedBox(width: 6),
                      Text(
                        isMe
                            ? 'Generosity Score: 🎁 ${user.totalGiftsSent} Gifts Sent'
                            : 'Generosity Score: 🎁 ${widget.starRank.index * 12 + 6} Gifts Sent',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2.0),
                        child: Icon(Icons.lock_rounded, size: 14, color: Colors.orangeAccent),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          isMe
                              ? 'Photo Vault: 🔒 4 Verified Photos (Protected in Encrypted Vault)'
                              : 'Photo Vault: 🔒 4 Photos (Reveals in DM at Tier 3 🍃)',
                          style: const TextStyle(color: Colors.orangeAccent, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Interactive Actions Layout
            if (!isMe) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: AppTheme.skyCyan, width: 1.2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: AppTheme.skyCyan),
                      label: const Text(
                        'DIRECT MESSAGE',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onDirectMessage?.call();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.brandCoral,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                      icon: const Text('🍸', style: TextStyle(fontSize: 16)),
                      label: const Text(
                        'SEND DRINK (50 Cr)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      onPressed: () {
                        final ok = widget.gameState.sendDrinkToUser(widget.roomId, widget.name);
                        Navigator.of(context).pop();
                        if (ok) {
                          SoundService().playCoinEarned();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppTheme.neonEmerald,
                              content: Text(
                                '🥂 Sent a cocktail to ${widget.name}! +80 Clout XP earned.',
                                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.redAccent,
                              content: Text('Insufficient Credits! Need at least 50 🪙.'),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.purpleRoyal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: Icon(
                  user.isVerified ? Icons.person_rounded : Icons.verified_user_rounded,
                  size: 18,
                  color: user.isVerified ? Colors.white : Colors.amberAccent,
                ),
                label: Text(
                  user.isVerified ? 'VIEW & EDIT MY PROFILE' : 'VIEW PROFILE & VERIFY SELFIE',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(gameState: widget.gameState),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textMuted,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.edit_rounded, size: 16),
                label: const Text(
                  'Quick Status & Mood',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => TwoGoPresenceSheet(gameState: widget.gameState),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
