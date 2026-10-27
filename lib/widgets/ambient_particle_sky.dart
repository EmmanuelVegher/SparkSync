import 'package:flutter/material.dart';

/// Minimalist Apple Ambient Background
/// Seamlessly shifts between Apple OLED pure black and crisp Apple light gray.
class AmbientParticleSky extends StatelessWidget {
  final Widget child;
  final int particleCount;
  final bool enableParticles;

  const AmbientParticleSky({
    super.key,
    required this.child,
    this.particleCount = 24,
    this.enableParticles = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? const Color(0xFF000000) : const Color(0xFFF5F5F7),
      child: child,
    );
  }
}
