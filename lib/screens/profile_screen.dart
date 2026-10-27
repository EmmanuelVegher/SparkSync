import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../models/models.dart';
import '../services/game_state.dart';
import '../services/local_persistence_service.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import '../widgets/credit_top_up_sheet.dart';
import '../widgets/human_avatar_widget.dart';
import '../widgets/performance_export_modal.dart';
import '../widgets/two_go_presence_sheet.dart';
import '../widgets/two_go_star_ladder_sheet.dart';
import '../services/supabase_service.dart';
import 'auth_screen.dart';
import 'selfie_liveness_screen.dart';

class ProfileScreen extends StatefulWidget {
  final GameState gameState;

  const ProfileScreen({super.key, required this.gameState});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _openSelfieVerification() async {
    final verified = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => SelfieLivenessScreen(
          gameState: widget.gameState,
          isModal: true,
        ),
      ),
    );

    if (verified == true && mounted) {
      SoundService().playSparkMatch();
      setState(() {});
    }
  }

  void _showEditStatusDialog() {
    final controller = TextEditingController(text: widget.gameState.user.statusText);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Edit Status Message',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
        ),
        content: TextField(
          controller: controller,
          maxLength: 80,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'What\'s on your mind?',
            hintStyle: const TextStyle(color: AppTheme.textMuted),
            counterStyle: const TextStyle(color: AppTheme.textMuted),
            filled: true,
            fillColor: AppTheme.nightObsidian,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.cardBorder),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.brandCoral,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              final newText = controller.text.trim();
              if (newText.isNotEmpty) {
                widget.gameState.updateStatusText(newText);
                setState(() {});
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _openMyPhotoVaultModal(UserStats user) {
    final photos = user.effectiveVaultPhotos;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF131926),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.lock_rounded, color: Colors.orangeAccent, size: 18),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MY ENCRYPTED VAULT',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Text(
                              'Held in High-Security Server Bucket',
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted, size: 22),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Privacy explanation banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2335),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_rounded, color: Colors.cyanAccent, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Public lounges & discovery decks ONLY see your 2D Stylized Human Avatar. These real photos remain locked here until you reach Tier 3 (Good Vibe 🍃) in private DM!',
                          style: const TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.35),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'VAULT PHOTOS (3-5 REVEALABLE ASSETS)',
                  style: TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),

                // Photos Grid
                SizedBox(
                  height: 110,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: photos.length + 1,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (ctx, idx) {
                      if (idx == photos.length) {
                        return GestureDetector(
                          onTap: () async {
                            try {
                              final picker = ImagePicker();
                              final picked = await picker.pickImage(
                                source: ImageSource.gallery,
                                maxWidth: 1920,
                                maxHeight: 1920,
                                imageQuality: 88,
                              );
                              if (picked != null) {
                                final bytes = await picked.readAsBytes();
                                final base64Str = base64Encode(bytes);
                                final dataUri = 'data:image/jpeg;base64,$base64Str';
                                user.vaultPhotos.add(dataUri);
                                await LocalPersistenceService().saveUser(user);
                                if (ctx.mounted) {
                                  Navigator.pop(ctx);
                                  _openMyPhotoVaultModal(user);
                                }
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      backgroundColor: AppTheme.neonEmerald,
                                      content: Text('🔒 New personal photo securely encrypted and stored in your Vault!'),
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              debugPrint('Error picking vault photo: $e');
                            }
                          },
                          child: Container(
                            width: 85,
                            height: 110,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E2638),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white24, style: BorderStyle.solid),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_rounded, color: AppTheme.textMuted, size: 24),
                                SizedBox(height: 4),
                                Text(
                                  '+ Add Photo',
                                  style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      final pUrl = photos[idx];
                      final isSelfie = idx == 0;
                      return Stack(
                        children: [
                          Container(
                            width: 85,
                            height: 110,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelfie ? AppTheme.neonEmerald : Colors.orangeAccent.withValues(alpha: 0.5),
                                width: 1.5,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: _buildVaultPhotoWidget(pUrl),
                            ),
                          ),
                          Positioned(
                            bottom: 4,
                            left: 4,
                            right: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.75),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isSelfie ? 'Selfie ✅' : 'Vault 🔒',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSelfie ? AppTheme.neonEmerald : Colors.orangeAccent,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.lock_rounded, size: 16),
                    label: const Text('Vault Security Active • Protected', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVaultPhotoWidget(String photoUrl) {
    if (photoUrl.startsWith('data:image')) {
      final commaIdx = photoUrl.indexOf(',');
      final base64Str = commaIdx != -1 ? photoUrl.substring(commaIdx + 1) : photoUrl;
      return Image.memory(base64Decode(base64Str), fit: BoxFit.cover);
    } else if (photoUrl.startsWith('http')) {
      return Image.network(
        photoUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.photo, color: Colors.white54)),
      );
    } else if (File(photoUrl).existsSync()) {
      return Image.file(File(photoUrl), fit: BoxFit.cover);
    }
    return const Center(child: Icon(Icons.photo, color: Colors.white54));
  }

  Widget _buildAvatarContent(UserStats user) {
    // Pure on-device 2D Stylized Human Avatar:
    // Transforms the user's real selfie into a 2D stylized cartoon avatar offline with zero network!
    return HumanAvatarWidget(
      user: user,
      size: 104,
      showBorder: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.gameState,
      builder: (context, _) {
        final user = widget.gameState.user;
        final rankColor = AppTheme.getRankColor(user.starRank.rankName);
        final nextRank = user.starRank.nextRank;
        final progress = user.starRank.progressToNext(user.xp);

        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: isDark ? AppTheme.nightObsidian : AppTheme.lightBg,
          appBar: AppBar(
            backgroundColor: isDark ? AppTheme.cardSurface : Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark ? Colors.white : AppTheme.textDark,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'My Profile',
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.textDark,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            actions: [
              IconButton(
                tooltip: isDark ? 'Switch to Light Theme' : 'Switch to Dark Theme',
                icon: Icon(
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: isDark ? const Color(0xFFFFD60A) : const Color(0xFF1D1D1F),
                  size: 22,
                ),
                onPressed: () => widget.gameState.toggleTheme(),
              ),
              IconButton(
                tooltip: 'Edit Status',
                icon: Icon(
                  Icons.edit_note_rounded,
                  color: isDark ? Colors.white70 : AppTheme.textMuted,
                  size: 24,
                ),
                onPressed: _showEditStatusDialog,
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                // Hero Profile Photo & Avatar (VoteGuard style biometric portrait display)
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // Outer Glow Container & Avatar
                      GestureDetector(
                        onTap: user.isVerified
                            ? () => showAvatarCustomizerModal(context, widget.gameState)
                            : _openSelfieVerification,
                        child: Container(
                          width: 104,
                          height: 104,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF131926),
                            border: Border.all(
                              color: user.isVerified ? AppTheme.neonEmerald : rankColor,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (user.isVerified ? AppTheme.neonEmerald : rankColor).withValues(alpha: 0.35),
                                blurRadius: 18,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: _buildAvatarContent(user),
                          ),
                        ),
                      ),

                      // Overlaid Encrypted Vault Lock Badge
                      if (user.isVerified)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: GestureDetector(
                            onTap: () => _openMyPhotoVaultModal(user),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.orangeAccent, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orangeAccent.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.lock_rounded,
                                color: Colors.orangeAccent,
                                size: 16,
                              ),
                            ),
                          ),
                        ),

                      // Camera update badge
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _openSelfieVerification,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: user.isVerified ? AppTheme.neonEmerald : AppTheme.brandCoral,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.nightObsidian, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: (user.isVerified ? AppTheme.neonEmerald : AppTheme.brandCoral)
                                      .withValues(alpha: 0.5),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Icon(
                              user.isVerified ? Icons.camera_front_rounded : Icons.camera_alt_rounded,
                              size: 16,
                              color: user.isVerified ? Colors.black : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            const SizedBox(height: 14),

            // Username with Verified Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user.username,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getTextColor(isDark),
                  ),
                ),
                if (user.isVerified) ...[
                  const SizedBox(width: 6),
                  const Tooltip(
                    message: 'Verified Identity',
                    child: Icon(
                      Icons.verified_rounded,
                      color: Colors.cyanAccent,
                      size: 22,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),

            // Title & Location
            Text(
              '${user.title} • ${user.neighborhood}',
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.getSubtextColor(isDark),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),

            // Vault Teaser chip
            GestureDetector(
              onTap: () => _openMyPhotoVaultModal(user),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withValues(alpha: isDark ? 0.12 : 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_rounded, color: Colors.orangeAccent, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      'Encrypted Vault: ${user.effectiveVaultPhotos.length} Photos (Reveals at Tier 3 🍃)',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.orangeAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Football Loyalty & Certified Pundit Flair
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (user.supportedClub != null && user.supportedClub!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF182236) : const Color(0xFFE8F2FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.skyCyan.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '🛡️ ${user.supportedClub}',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white : const Color(0xFF0071E3),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (user.isCertifiedPundit)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD027), Color(0xFFFF9100)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD027).withValues(alpha: 0.3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Text(
                      '🏆 Certified Pundit ⚽',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Status message quote
            GestureDetector(
              onTap: _showEditStatusDialog,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.getCardSurface(isDark),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.getCardBorder(isDark), width: 0.5),
                  boxShadow: AppTheme.getCardShadow(isDark),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        '"${user.statusText}"',
                        style: TextStyle(
                          color: AppTheme.getTextColor(isDark),
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(Icons.edit, size: 12, color: AppTheme.getSubtextColor(isDark)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),

            // VERIFICATION STATUS CARD
            if (!user.isVerified) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF281C10), Color(0xFF131926)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.lagosYellow.withValues(alpha: 0.6)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.lagosYellow.withValues(alpha: 0.15),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.lagosYellow.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.shield_outlined,
                            color: AppTheme.lagosYellow,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Profile Not Verified',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Missed selfie setup during onboarding?',
                                style: TextStyle(
                                  color: AppTheme.lagosYellow,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.neonEmerald.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.neonEmerald.withValues(alpha: 0.5)),
                          ),
                          child: const Text(
                            '+150 XP & +150 🪙',
                            style: TextStyle(
                              color: AppTheme.neonEmerald,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Take a quick real selfie now. Our AI scans your photo to vectorize your face, generates your custom AI Avatar, and awards +150 XP and +150 Spark Coins!',
                      style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.lagosYellow,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.camera_front_rounded, size: 20, color: Colors.black),
                        label: const Text(
                          'Verify with Selfie Now (+150 🪙)',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                        ),
                        onPressed: _openSelfieVerification,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F261F), Color(0xFF131926)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.neonEmerald.withValues(alpha: 0.6)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.neonEmerald.withValues(alpha: 0.15),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.verified_rounded, color: Colors.cyanAccent, size: 24),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Identity Verified ✅',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Official Anti-Catfish Protected Member',
                                style: TextStyle(
                                  color: AppTheme.neonEmerald,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Your identity is confirmed with biometric selfie landmarks. You have higher trust and priority matches across SparkSync.',
                      style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                    ),
                    const SizedBox(height: 14),

                    // AI Synthesized Avatar Showcase Card
                    GestureDetector(
                      onTap: () => showAvatarCustomizerModal(context, widget.gameState),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF090E17),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.35)),
                        ),
                        child: Row(
                          children: [
                            HumanAvatarWidget(
                              user: user,
                              size: 52,
                              showBorder: true,
                              borderColor: Colors.cyanAccent,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      const Text(
                                        '2D HUMAN AVATAR',
                                        style: TextStyle(
                                          color: Colors.cyanAccent,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.6,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: AppTheme.neonEmerald.withValues(alpha: 0.25),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: AppTheme.neonEmerald.withValues(alpha: 0.6)),
                                        ),
                                        child: const Text(
                                          'OFFLINE',
                                          style: TextStyle(color: AppTheme.neonEmerald, fontSize: 8, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    user.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                  Text(
                                    '${user.avatarHasGlasses ? "👓 Glasses" : "No Glasses"} • ${user.avatarHasBeard ? "🧔 Full Beard" : "Clean Shaven"} • 💈 ${user.avatarHairStyle.toUpperCase()}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: AppTheme.neonEmerald, fontSize: 11, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.tune_rounded, color: Colors.cyanAccent, size: 20),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Pure on-device offline 2D avatar customizer button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: AppTheme.neonEmerald,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.palette_rounded, size: 18),
                        label: const Text(
                          '🎨 Customize 2D Avatar (Glasses, Beard, Hair, Skin)',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => showAvatarCustomizerModal(context, widget.gameState),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(color: Colors.orangeAccent.withValues(alpha: 0.6)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                            ),
                            icon: const Icon(Icons.lock_rounded, size: 16, color: Colors.orangeAccent),
                            label: const Text(
                              'My Vault (🔒)',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () => _openMyPhotoVaultModal(user),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: BorderSide(color: AppTheme.neonEmerald.withValues(alpha: 0.6)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                            ),
                            icon: const Icon(Icons.refresh_rounded, size: 16, color: Colors.cyanAccent),
                            label: const Text(
                              'Retake Selfie',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            onPressed: _openSelfieVerification,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),

            // Active Presence Quick Switcher
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.getCardSurface(isDark),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.getCardBorder(isDark), width: 0.5),
                boxShadow: AppTheme.getCardShadow(isDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ACTIVE STATUS',
                        style: TextStyle(
                          color: AppTheme.getSubtextColor(isDark),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (ctx) => TwoGoPresenceSheet(gameState: widget.gameState),
                          ).then((_) => setState(() {}));
                        },
                        child: const Text(
                          'More Presets →',
                          style: TextStyle(color: AppTheme.skyCyan, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: TwoGoPresence.values.map((presence) {
                      final isSelected = user.presence == presence;
                      Color pColor;
                      switch (presence) {
                        case TwoGoPresence.online:
                          pColor = AppTheme.neonEmerald;
                          break;
                        case TwoGoPresence.busy:
                          pColor = const Color(0xFFFF3B30);
                          break;
                        case TwoGoPresence.away:
                          pColor = AppTheme.lagosYellow;
                          break;
                        case TwoGoPresence.offline:
                          pColor = AppTheme.textMuted;
                          break;
                      }

                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3.0),
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              widget.gameState.updateUserPresence(presence);
                              setState(() {});
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? pColor.withValues(alpha: isDark ? 0.2 : 0.12)
                                    : (isDark ? AppTheme.nightObsidian : const Color(0xFFF2F2F7)),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? pColor
                                      : (isDark ? AppTheme.cardBorder : const Color(0xFFE5E5EA)),
                                  width: isSelected ? 1.5 : 0.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(presence.indicatorEmoji, style: const TextStyle(fontSize: 10)),
                                  const SizedBox(height: 4),
                                  Text(
                                    presence.label,
                                    style: TextStyle(
                                      color: isSelected
                                          ? pColor
                                          : (isDark ? Colors.white70 : const Color(0xFF48484A)),
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      fontSize: 10,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Star Rank Progression Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.getCardSurface(isDark),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: rankColor.withValues(alpha: isDark ? 0.5 : 0.4),
                  width: 0.5,
                ),
                boxShadow: AppTheme.getCardShadow(isDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: rankColor.withValues(alpha: isDark ? 0.2 : 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: rankColor.withValues(alpha: 0.6)),
                            ),
                            child: Text(
                              user.starRank.badgeTitle,
                              style: TextStyle(
                                color: rankColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Level ${user.level}',
                            style: TextStyle(
                              color: AppTheme.getTextColor(isDark),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (ctx) => TwoGoStarLadderSheet(gameState: widget.gameState),
                          );
                        },
                        child: const Text('View Ladder →', style: TextStyle(color: AppTheme.skyCyan, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${user.xp} Total XP',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : const Color(0xFF3A3A3C),
                          fontSize: 12,
                        ),
                      ),
                      if (nextRank != null)
                        Text(
                          'Next: ${nextRank.badgeTitle} (${nextRank.requiredXp} XP)',
                          style: TextStyle(
                            color: AppTheme.getSubtextColor(isDark),
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: isDark ? Colors.black45 : const Color(0xFFE5E5EA),
                      valueColor: AlwaysStoppedAnimation<Color>(rankColor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Key Stats Grid
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => CreditTopUpSheet.show(context, widget.gameState),
                    borderRadius: BorderRadius.circular(16),
                    child: _buildStatItem('🪙 Coins (Top Up +)', '${user.walletBalance}', AppTheme.lagosYellow),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem('⚡ Energy', '${user.energy}%', AppTheme.neonEmerald),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('🔥 Streak', '${user.currentStreakDays} Days', Colors.orangeAccent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem('🎁 Gifts', '${user.totalGiftsSent} Sent', Colors.pinkAccent),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // SAVED KARAOKE & ACAPELLA SHOWCASE
            _buildPerformancesShowcase(user),

            const SizedBox(height: 24),

            // Apple Minimalist Log Out Action
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.cardSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppTheme.cardBorder : AppTheme.lightCardBorder,
                  width: 0.5,
                ),
              ),
              child: InkWell(
                onTap: _showLogOutConfirmationDialog,
                borderRadius: BorderRadius.circular(16),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        color: Color(0xFFFF3B30), // Apple System Red
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Log Out',
                        style: TextStyle(
                          color: Color(0xFFFF3B30), // Apple System Red
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Subtle Version & Session info
            Center(
              child: Text(
                'SparkSync v1.0.0 • Signed in as ${user.username}',
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                  letterSpacing: -0.1,
                ),
              ),
            ),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  },
);
}

  void _showLogOutConfirmationDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E5EA),
            width: 0.5,
          ),
        ),
        title: Text(
          'Log Out',
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 17,
            letterSpacing: -0.3,
          ),
        ),
        content: Text(
          'Are you sure you want to log out of SparkSync?',
          style: TextStyle(
            color: isDark ? const Color(0xFFEBEBF5) : const Color(0xFF3C3C43),
            fontSize: 13.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF86868B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _performSignOut();
            },
            child: const Text(
              'Log Out',
              style: TextStyle(
                color: Color(0xFFFF3B30),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _performSignOut() async {
    try {
      await SupabaseService().signOut();
    } catch (e) {
      debugPrint('[ProfileScreen] SignOut error: $e');
    }

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => AuthScreen(gameState: widget.gameState)),
        (route) => false,
      );
    }
  }

  Widget _buildPerformancesShowcase(UserStats user) {
    final list = user.savedPerformances;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.purpleAccent.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('🎤', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text(
                    'SAVED SHOWCASE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.purpleAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${list.length} Saved Clips',
                  style: const TextStyle(
                    color: Colors.purpleAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Your recorded Karaoke sets & Saturday Acapella Arena performances. Re-share to WhatsApp, TikTok, or Stories anytime!',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 14),

          if (list.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F111E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: const Column(
                children: [
                  Text('🎶', style: TextStyle(fontSize: 28)),
                  SizedBox(height: 8),
                  Text(
                    'No saved performances yet!',
                    style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Hop on the Lounge mic during Karaoke Nights or Saturday Showdowns to record and save your sets here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final perf = list[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F111E),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: perf.isAcapella
                          ? Colors.amberAccent.withValues(alpha: 0.4)
                          : const Color(0xFF6C63FF).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: perf.isAcapella
                              ? Colors.amberAccent.withValues(alpha: 0.15)
                              : const Color(0xFF6C63FF).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Text(perf.isAcapella ? '🏆' : '🎤', style: const TextStyle(fontSize: 18)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    perf.trackTitle,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: perf.isAcapella
                                        ? Colors.amberAccent.withValues(alpha: 0.2)
                                        : const Color(0xFF6C63FF).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    perf.isAcapella ? 'ACAPELLA' : 'KARAOKE',
                                    style: TextStyle(
                                      color: perf.isAcapella ? Colors.amberAccent : const Color(0xFF818CF8),
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              perf.trackArtist,
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 10.5),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '🗳️ ${perf.totalVotes} Votes • +${perf.xpEarned} XP Earned',
                              style: const TextStyle(color: AppTheme.lagosYellow, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.share_rounded, color: Colors.cyanAccent, size: 20),
                        tooltip: 'Share clip to socials',
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => PerformanceExportModal(
                              gameState: widget.gameState,
                              performerName: perf.username,
                              performerAvatar: perf.userAvatar,
                              performerRank: perf.rankTitle,
                              trackTitle: perf.trackTitle,
                              trackArtist: perf.trackArtist,
                              totalVotes: perf.totalVotes,
                              xpEarned: perf.xpEarned,
                              isAcapella: perf.isAcapella,
                              voteBreakdown: perf.voteBreakdown,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.getCardSurface(isDark),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.getCardBorder(isDark), width: 0.5),
        boxShadow: AppTheme.getCardShadow(isDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: AppTheme.getSubtextColor(isDark), fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
