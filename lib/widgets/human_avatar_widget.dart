import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

/// A pure Flutter widget that displays a stylized 2D human avatar of the user.
/// Works 100% offline with zero network required!
/// 
/// Privacy Guarantee:
/// The user's real raw camera photo is strictly kept inside their private Encrypted Vault.
/// This widget ALWAYS renders a stylized 2D Human Avatar (or on-device comic/cartoon PNG)
/// so that the user's face is never exposed as a raw camera photo in public.
class HumanAvatarWidget extends StatelessWidget {
  final UserStats? user;
  final String? photoUrl;
  final String? avatarEmoji;
  final double size;
  final bool showBorder;
  final Color? borderColor;
  final bool? hasGlasses;
  final bool? hasBeard;
  final String? skinTone;
  final String? hairStyle;
  final String? outfit;

  const HumanAvatarWidget({
    super.key,
    this.user,
    this.photoUrl,
    this.avatarEmoji,
    this.size = 104,
    this.showBorder = true,
    this.borderColor,
    this.hasGlasses,
    this.hasBeard,
    this.skinTone,
    this.hairStyle,
    this.outfit,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorder = borderColor ?? AppTheme.neonEmerald;

    // ALWAYS render the 100% offline 2D Humanoid Vector Avatar as the public avatar representation!
    // The user's real camera photo is strictly kept in their private encrypted Vault for privacy.
    final avatarCore = HumanoidVectorAvatar(
      size: size,
      user: user,
      skinTone: skinTone ?? user?.avatarSkinTone,
      hairStyle: hairStyle ?? user?.avatarHairStyle,
      hasGlasses: hasGlasses ?? user?.avatarHasGlasses ?? true,
      hasBeard: hasBeard ?? user?.avatarHasBeard ?? true,
      outfit: outfit ?? user?.avatarOutfit,
    );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(color: effectiveBorder, width: size > 80 ? 3 : 2)
            : null,
        boxShadow: showBorder
            ? [
                BoxShadow(
                  color: effectiveBorder.withValues(alpha: 0.35),
                  blurRadius: size > 80 ? 16 : 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: ClipOval(
        child: avatarCore,
      ),
    );
  }
}

/// A 100% offline 2D illustrated human vector avatar painted directly with Flutter CustomPainter.
/// Parametric and customizable: renders human skin tone, glasses, beard, crisp haircut, and attire.
class HumanoidVectorAvatar extends StatelessWidget {
  final double size;
  final UserStats? user;
  final String? skinTone;
  final String? hairStyle;
  final bool hasGlasses;
  final bool hasBeard;
  final String? outfit;

  const HumanoidVectorAvatar({
    super.key,
    this.size = 104,
    this.user,
    this.skinTone,
    this.hairStyle,
    this.hasGlasses = true,
    this.hasBeard = true,
    this.outfit,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSkin = skinTone ?? user?.avatarSkinTone ?? 'warm_brown';
    final effectiveHair = hairStyle ?? user?.avatarHairStyle ?? 'fade';
    final effectiveGlasses = hasGlasses;
    final effectiveBeard = hasBeard;
    final effectiveOutfit = outfit ?? user?.avatarOutfit ?? 'executive';

    return CustomPaint(
      size: Size(size, size),
      painter: _HumanoidAvatarPainter(
        skinTone: effectiveSkin,
        hairStyle: effectiveHair,
        hasGlasses: effectiveGlasses,
        hasBeard: effectiveBeard,
        outfit: effectiveOutfit,
      ),
    );
  }
}

class _HumanoidAvatarPainter extends CustomPainter {
  final String skinTone;
  final String hairStyle;
  final bool hasGlasses;
  final bool hasBeard;
  final String outfit;

  _HumanoidAvatarPainter({
    required this.skinTone,
    required this.hairStyle,
    required this.hasGlasses,
    required this.hasBeard,
    required this.outfit,
  });

  Color get _faceSkinColor {
    switch (skinTone) {
      case 'dark_rich':
        return const Color(0xFF5A3214);
      case 'golden':
        return const Color(0xFFB57A42);
      case 'fair':
        return const Color(0xFFD49B6A);
      case 'warm_brown':
      default:
        return const Color(0xFF8D5524);
    }
  }

  Color get _neckSkinColor {
    switch (skinTone) {
      case 'dark_rich':
        return const Color(0xFF472710);
      case 'golden':
        return const Color(0xFF9E6532);
      case 'fair':
        return const Color(0xFFBA8454);
      case 'warm_brown':
      default:
        return const Color(0xFF7A4B29);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    // 1. Background studio circle
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF1E283E), Color(0xFF0F172A)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawCircle(center, w / 2, bgPaint);

    // 2. Torso / Shirt & Collar based on outfit
    Color suitColor = const Color(0xFF0F261F);
    Color lapelColor = const Color(0xFF00E5FF).withValues(alpha: 0.85);
    Color shirtColor = Colors.white;

    if (outfit == 'founder') {
      suitColor = const Color(0xFF131926);
      lapelColor = const Color(0xFFFFD700).withValues(alpha: 0.9);
    } else if (outfit == 'casual') {
      suitColor = const Color(0xFF1E293B);
      lapelColor = const Color(0xFF38BDF8).withValues(alpha: 0.6);
      shirtColor = const Color(0xFF0F172A);
    }

    final shirtPaint = Paint()..color = suitColor;
    final collarPaint = Paint()..color = lapelColor;
    final innerShirtPaint = Paint()..color = shirtColor;

    final torsoPath = Path()
      ..moveTo(w * 0.15, h)
      ..quadraticBezierTo(w * 0.22, h * 0.78, w * 0.38, h * 0.78)
      ..lineTo(w * 0.62, h * 0.78)
      ..quadraticBezierTo(w * 0.78, h * 0.78, w * 0.85, h)
      ..close();
    canvas.drawPath(torsoPath, shirtPaint);

    // V-neck shirt / tie
    final vNeck = Path()
      ..moveTo(w * 0.42, h * 0.78)
      ..lineTo(w * 0.50, h * 0.89)
      ..lineTo(w * 0.58, h * 0.78)
      ..close();
    canvas.drawPath(vNeck, innerShirtPaint);

    // Jacket Lapels
    final lapelLeft = Path()
      ..moveTo(w * 0.32, h * 0.78)
      ..lineTo(w * 0.44, h * 0.94)
      ..lineTo(w * 0.38, h)
      ..close();
    canvas.drawPath(lapelLeft, collarPaint);

    final lapelRight = Path()
      ..moveTo(w * 0.68, h * 0.78)
      ..lineTo(w * 0.56, h * 0.94)
      ..lineTo(w * 0.62, h)
      ..close();
    canvas.drawPath(lapelRight, collarPaint);

    // 3. Neck
    final neckPaint = Paint()..color = _neckSkinColor;
    final neckRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.70), width: w * 0.22, height: h * 0.20),
      const Radius.circular(8),
    );
    canvas.drawRRect(neckRect, neckPaint);

    // 4. Head & Face
    final skinPaint = Paint()..color = _faceSkinColor;
    final faceRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.46), width: w * 0.46, height: h * 0.52),
      Radius.circular(w * 0.22),
    );
    canvas.drawRRect(faceRect, skinPaint);

    // 5. Hair (based on hairStyle)
    final hairPaint = Paint()..color = const Color(0xFF141416);
    if (hairStyle != 'bald') {
      if (hairStyle == 'afro') {
        // High top / rounded afro
        final afroPath = Path()
          ..moveTo(w * 0.22, h * 0.44)
          ..quadraticBezierTo(w * 0.18, h * 0.14, w * 0.50, h * 0.12)
          ..quadraticBezierTo(w * 0.82, h * 0.14, w * 0.78, h * 0.44)
          ..quadraticBezierTo(w * 0.72, h * 0.22, w * 0.50, h * 0.20)
          ..quadraticBezierTo(w * 0.28, h * 0.22, w * 0.22, h * 0.44)
          ..close();
        canvas.drawPath(afroPath, hairPaint);
      } else if (hairStyle == 'buzz') {
        // Short close crop
        final buzzPath = Path()
          ..moveTo(w * 0.26, h * 0.38)
          ..quadraticBezierTo(w * 0.25, h * 0.22, w * 0.50, h * 0.20)
          ..quadraticBezierTo(w * 0.75, h * 0.22, w * 0.74, h * 0.38)
          ..quadraticBezierTo(w * 0.70, h * 0.25, w * 0.50, h * 0.24)
          ..quadraticBezierTo(w * 0.30, h * 0.25, w * 0.26, h * 0.38)
          ..close();
        canvas.drawPath(buzzPath, hairPaint);
      } else {
        // Crisp clean fade (Default)
        final hairPath = Path()
          ..moveTo(w * 0.26, h * 0.42)
          ..quadraticBezierTo(w * 0.25, h * 0.20, w * 0.50, h * 0.18)
          ..quadraticBezierTo(w * 0.75, h * 0.20, w * 0.74, h * 0.42)
          ..quadraticBezierTo(w * 0.70, h * 0.24, w * 0.50, h * 0.23)
          ..quadraticBezierTo(w * 0.30, h * 0.24, w * 0.26, h * 0.42)
          ..close();
        canvas.drawPath(hairPath, hairPaint);
      }
    }

    // 6. Ears
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.26, h * 0.48), width: w * 0.08, height: h * 0.12),
      skinPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.74, h * 0.48), width: w * 0.08, height: h * 0.12),
      skinPaint,
    );

    // 7. Facial Hair (Full Trimmed Beard & Goatee if enabled)
    if (hasBeard) {
      final beardPaint = Paint()..color = const Color(0xFF18181A);
      final beardPath = Path()
        ..moveTo(w * 0.28, h * 0.50)
        ..quadraticBezierTo(w * 0.30, h * 0.70, w * 0.50, h * 0.73)
        ..quadraticBezierTo(w * 0.70, h * 0.70, w * 0.72, h * 0.50)
        ..quadraticBezierTo(w * 0.66, h * 0.64, w * 0.50, h * 0.65)
        ..quadraticBezierTo(w * 0.34, h * 0.64, w * 0.28, h * 0.50)
        ..close();
      canvas.drawPath(beardPath, beardPaint);

      // Mustache
      final mustachePath = Path()
        ..moveTo(w * 0.40, h * 0.54)
        ..quadraticBezierTo(w * 0.50, h * 0.52, w * 0.60, h * 0.54)
        ..quadraticBezierTo(w * 0.50, h * 0.56, w * 0.40, h * 0.54)
        ..close();
      canvas.drawPath(mustachePath, beardPaint);
    }

    // 8. Eyes & Confident Eyebrows
    final featurePaint = Paint()
      ..color = const Color(0xFF1E1E20)
      ..style = PaintingStyle.fill;

    // Eyebrows
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.41, h * 0.37), width: w * 0.11, height: h * 0.025),
        const Radius.circular(2),
      ),
      featurePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.59, h * 0.37), width: w * 0.11, height: h * 0.025),
        const Radius.circular(2),
      ),
      featurePaint,
    );

    // Eyes
    canvas.drawCircle(Offset(w * 0.41, h * 0.42), w * 0.025, featurePaint);
    canvas.drawCircle(Offset(w * 0.59, h * 0.42), w * 0.025, featurePaint);

    // Eye catchlights
    final catchlightPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.42, h * 0.415), w * 0.008, catchlightPaint);
    canvas.drawCircle(Offset(w * 0.60, h * 0.415), w * 0.008, catchlightPaint);

    // 9. Stylish Executive Eyeglasses (if enabled)
    if (hasGlasses) {
      final glassFramePaint = Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.024;
      final glassLensPaint = Paint()
        ..color = Colors.cyanAccent.withValues(alpha: 0.12)
        ..style = PaintingStyle.fill;

      // Left lens & frame
      final leftLensRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.41, h * 0.42), width: w * 0.16, height: h * 0.11),
        Radius.circular(w * 0.04),
      );
      canvas.drawRRect(leftLensRect, glassLensPaint);
      canvas.drawRRect(leftLensRect, glassFramePaint);

      // Right lens & frame
      final rightLensRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.59, h * 0.42), width: w * 0.16, height: h * 0.11),
        Radius.circular(w * 0.04),
      );
      canvas.drawRRect(rightLensRect, glassLensPaint);
      canvas.drawRRect(rightLensRect, glassFramePaint);

      // Bridge between lenses
      final bridgePaint = Paint()
        ..color = const Color(0xFF0F172A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.02;
      canvas.drawLine(
        Offset(w * 0.49, h * 0.41),
        Offset(w * 0.51, h * 0.41),
        bridgePaint,
      );
    }

    // 10. Warm Smile
    final smilePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final smilePath = Path()
      ..moveTo(w * 0.44, h * 0.58)
      ..quadraticBezierTo(w * 0.50, h * 0.62, w * 0.56, h * 0.58)
      ..close();
    canvas.drawPath(smilePath, smilePaint);
  }

  @override
  bool shouldRepaint(covariant _HumanoidAvatarPainter oldDelegate) {
    return oldDelegate.skinTone != skinTone ||
        oldDelegate.hairStyle != hairStyle ||
        oldDelegate.hasGlasses != hasGlasses ||
        oldDelegate.hasBeard != hasBeard ||
        oldDelegate.outfit != outfit;
  }
}

/// Interactive 2D Avatar Customizer Modal
/// Allows the user to toggle glasses, beard, skin tone, haircut, and attire in real time!
void showAvatarCustomizerModal(BuildContext context, GameState gameState) {
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF0D121D),
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return StatefulBuilder(
        builder: (modalCtx, setModalState) {
          final user = gameState.user;

          void updateTrait({
            bool? glasses,
            bool? beard,
            String? skin,
            String? hair,
            String? outfit,
          }) {
            gameState.updateAvatarTraits(
              glasses: glasses,
              beard: beard,
              skin: skin,
              hair: hair,
              outfit: outfit,
            );
            setModalState(() {});
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    '🎨 Customize 2D Human Avatar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '100% Offline • Pure Flutter Vector Engine • Zero Network',
                    style: TextStyle(
                      color: AppTheme.neonEmerald,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Big Live Avatar Preview
                  HumanAvatarWidget(
                    user: user,
                    size: 112,
                    showBorder: true,
                    borderColor: AppTheme.neonEmerald,
                  ),
                  const SizedBox(height: 20),

                  // 1. Eyeglasses Selector
                  _buildSectionHeader('👓 Eyeglasses'),
                  Row(
                    children: [
                      Expanded(
                        child: _buildChoiceChip(
                          label: 'Glasses On 👓',
                          isSelected: user.avatarHasGlasses,
                          onTap: () => updateTrait(glasses: true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildChoiceChip(
                          label: 'No Glasses',
                          isSelected: !user.avatarHasGlasses,
                          onTap: () => updateTrait(glasses: false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 2. Facial Hair Selector
                  _buildSectionHeader('🧔 Facial Hair'),
                  Row(
                    children: [
                      Expanded(
                        child: _buildChoiceChip(
                          label: 'Full Beard 🧔',
                          isSelected: user.avatarHasBeard,
                          onTap: () => updateTrait(beard: true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildChoiceChip(
                          label: 'Clean Shaven 🪒',
                          isSelected: !user.avatarHasBeard,
                          onTap: () => updateTrait(beard: false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 3. Haircut Selector
                  _buildSectionHeader('💈 Haircut & Style'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChoiceChip(
                        label: 'Crisp Fade 💈',
                        isSelected: user.avatarHairStyle == 'fade',
                        onTap: () => updateTrait(hair: 'fade'),
                      ),
                      _buildChoiceChip(
                        label: 'Buzz Cut ✂️',
                        isSelected: user.avatarHairStyle == 'buzz',
                        onTap: () => updateTrait(hair: 'buzz'),
                      ),
                      _buildChoiceChip(
                        label: 'Afro Volume 🦱',
                        isSelected: user.avatarHairStyle == 'afro',
                        onTap: () => updateTrait(hair: 'afro'),
                      ),
                      _buildChoiceChip(
                        label: 'Clean Shave 🧑🏾‍🦲',
                        isSelected: user.avatarHairStyle == 'bald',
                        onTap: () => updateTrait(hair: 'bald'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 4. Skin Tone Selector
                  _buildSectionHeader('🎨 Skin Tone'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChoiceChip(
                        label: 'Dark Rich 🏿',
                        isSelected: user.avatarSkinTone == 'dark_rich',
                        onTap: () => updateTrait(skin: 'dark_rich'),
                      ),
                      _buildChoiceChip(
                        label: 'Warm Brown 🏾',
                        isSelected: user.avatarSkinTone == 'warm_brown',
                        onTap: () => updateTrait(skin: 'warm_brown'),
                      ),
                      _buildChoiceChip(
                        label: 'Golden Bronze 🏽',
                        isSelected: user.avatarSkinTone == 'golden',
                        onTap: () => updateTrait(skin: 'golden'),
                      ),
                      _buildChoiceChip(
                        label: 'Fair Caramel 🏼',
                        isSelected: user.avatarSkinTone == 'fair',
                        onTap: () => updateTrait(skin: 'fair'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 5. Attire Selector
                  _buildSectionHeader('👔 Executive Attire'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildChoiceChip(
                        label: 'Maitama VIP (Emerald)',
                        isSelected: user.avatarOutfit == 'executive',
                        onTap: () => updateTrait(outfit: 'executive'),
                      ),
                      _buildChoiceChip(
                        label: 'Tech Founder (Gold)',
                        isSelected: user.avatarOutfit == 'founder',
                        onTap: () => updateTrait(outfit: 'founder'),
                      ),
                      _buildChoiceChip(
                        label: 'Cyber Crewneck (Casual)',
                        isSelected: user.avatarOutfit == 'casual',
                        onTap: () => updateTrait(outfit: 'casual'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Done Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.neonEmerald,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text(
                        'Save & Apply 2D Avatar',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
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

Widget _buildSectionHeader(String title) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    ),
  );
}

Widget _buildChoiceChip({
  required String label,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.neonEmerald.withValues(alpha: 0.22) : const Color(0xFF161F30),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected ? AppTheme.neonEmerald : Colors.white12,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.neonEmerald : Colors.white70,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    ),
  );
}
