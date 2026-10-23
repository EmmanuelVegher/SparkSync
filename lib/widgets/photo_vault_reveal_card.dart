import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class PhotoVaultRevealCard extends StatefulWidget {
  final MatchProfile profile;
  final bool isUnlocked;
  final VoidCallback? onUnlockWithTicket;
  final int userCredits;

  const PhotoVaultRevealCard({
    super.key,
    required this.profile,
    required this.isUnlocked,
    this.onUnlockWithTicket,
    this.userCredits = 0,
  });

  @override
  State<PhotoVaultRevealCard> createState() => _PhotoVaultRevealCardState();
}

class _PhotoVaultRevealCardState extends State<PhotoVaultRevealCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  int _selectedPhotoIdx = 0;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _flipAnimation = Tween<double>(begin: 0.0, end: pi).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutBack),
    );

    if (widget.isUnlocked) {
      _flipController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant PhotoVaultRevealCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isUnlocked && !oldWidget.isUnlocked) {
      _flipController.forward();
    } else if (!widget.isUnlocked && oldWidget.isUnlocked) {
      _flipController.reverse();
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _flipAnimation,
      builder: (context, child) {
        final isBack = _flipAnimation.value >= pi / 2;

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0015) // Perspective depth
            ..rotateY(_flipAnimation.value),
          alignment: Alignment.center,
          child: isBack
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(pi), // Invert back face mirror
                  child: _buildRealFaceCard(),
                )
              : _buildAvatarShieldCard(),
        );
      },
    );
  }

  // STATE A: THE 2D AVATAR SHIELD
  Widget _buildAvatarShieldCard() {
    final rankColor = AppTheme.getRankColor(widget.profile.starRank.rankName);
    final stage = widget.profile.relationshipStage;

    return Container(
      width: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF141926),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.cyanAccent.withValues(alpha: 0.6),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Clout Tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: rankColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: rankColor.withValues(alpha: 0.6)),
                ),
                child: Text(
                  widget.profile.starRank.badgeTitle,
                  style: TextStyle(
                    color: rankColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.shield_rounded, size: 12, color: Colors.cyanAccent),
                    SizedBox(width: 4),
                    Text(
                      'SHIELD ACTIVE',
                      style: TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 2D Avatar Circle
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF2E1A47), Color(0xFF16203B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.cyanAccent, width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              widget.profile.avatarEmoji,
              style: const TextStyle(fontSize: 54),
            ),
          ),
          const SizedBox(height: 14),

          Text(
            widget.profile.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.profile.neighborhood} • ${widget.profile.city}',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 16),

          // Locked Vault Status Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1D1426),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.5)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_rounded, color: Colors.orangeAccent, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '🔒 ${widget.profile.realPhotos.length} Photos in Encrypted Vault',
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Current: ${stage.displayName}\nUnlocks at Tier 3 (Good Vibe 🍃) or Tier 4 (Official Match 💍)',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Instant Reveal Ticket Option
          if (widget.onUnlockWithTicket != null)
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lagosYellow,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 38),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Text('🎫', style: TextStyle(fontSize: 14)),
              label: Text(
                'Reveal Ticket (100 Cr) [Bal: ${widget.userCredits}]',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
              ),
              onPressed: widget.onUnlockWithTicket,
            ),
        ],
      ),
    );
  }

  // STATE C: THE REAL FACE REVEALED
  Widget _buildRealFaceCard() {
    final photos = widget.profile.realPhotos;
    final activePhotoUrl = photos.isNotEmpty
        ? photos[_selectedPhotoIdx % photos.length]
        : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=600&q=80';

    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: const Color(0xFF141926),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.neonEmerald,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.neonEmerald.withValues(alpha: 0.3),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Image with gradient overlay
            Stack(
              children: [
                SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: _buildPhotoWidget(activePhotoUrl),
                ),

                // Top Unlocked Banner
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.neonEmerald.withValues(alpha: 0.8)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.lock_open_rounded, color: AppTheme.neonEmerald, size: 14),
                        SizedBox(width: 6),
                        Text(
                          '🔓 VAULT UNLOCKED • REAL IDENTITY',
                          style: TextStyle(
                            color: AppTheme.neonEmerald,
                            fontWeight: FontWeight.w900,
                            fontSize: 10,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Identity Gradient
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(16, 28, 16, 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.9)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  widget.profile.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.verified, color: Colors.cyanAccent, size: 16),
                              ],
                            ),
                            Text(
                              '${widget.profile.age} yrs • ${widget.profile.occupation}',
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                            ),
                          ],
                        ),
                        Text(
                          widget.profile.avatarEmoji,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Photo Gallery Thumbnails (if multiple photos)
            if (photos.length > 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(photos.length, (idx) {
                    final isSel = idx == _selectedPhotoIdx;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPhotoIdx = idx;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSel ? AppTheme.neonEmerald : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildPhotoWidget(photos[idx]),
                        ),
                      ),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoWidget(String photoUrl) {
    if (photoUrl.startsWith('data:image')) {
      final commaIdx = photoUrl.indexOf(',');
      final base64Str = commaIdx != -1 ? photoUrl.substring(commaIdx + 1) : photoUrl;
      return Image.memory(base64Decode(base64Str), fit: BoxFit.cover);
    } else if (photoUrl.startsWith('http')) {
      return Image.network(
        photoUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackPhoto(),
      );
    } else {
      try {
        final f = File(photoUrl);
        if (f.existsSync()) {
          return Image.file(f, fit: BoxFit.cover);
        }
      } catch (_) {}
    }
    return _buildFallbackPhoto();
  }

  Widget _buildFallbackPhoto() {
    return Container(
      color: const Color(0xFF1B2338),
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_user, color: AppTheme.neonEmerald, size: 28),
          SizedBox(height: 4),
          Text(
            'Verified Photo',
            style: TextStyle(color: Colors.white, fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
