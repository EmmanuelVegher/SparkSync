import 'dart:math';
import 'package:flutter/material.dart';

class AmbientParticleSky extends StatefulWidget {
  final Widget child;
  final int particleCount;
  final bool enableParticles;

  const AmbientParticleSky({
    super.key,
    required this.child,
    this.particleCount = 24,
    this.enableParticles = true,
  });

  @override
  State<AmbientParticleSky> createState() => _AmbientParticleSkyState();
}

class _AmbientParticleSkyState extends State<AmbientParticleSky>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final List<_Particle> _particles = [];
  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    for (int i = 0; i < widget.particleCount; i++) {
      _particles.add(_Particle.random(_rnd));
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  List<Color> _getTimeOfDayGradient() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) {
      // Morning Dawn
      return const [
        Color(0xFF0F172A),
        Color(0xFF1E1B4B),
        Color(0xFF2E1065),
      ];
    } else if (hour >= 12 && hour < 17) {
      // Afternoon Sun
      return const [
        Color(0xFF0C1427),
        Color(0xFF131D38),
        Color(0xFF1E293B),
      ];
    } else if (hour >= 17 && hour < 20) {
      // Golden Hour / Afro Sunset
      return const [
        Color(0xFF1A0B2E),
        Color(0xFF2D124D),
        Color(0xFF3B0764),
      ];
    } else {
      // Midnight Cyber Obsidian
      return const [
        Color(0xFF090913),
        Color(0xFF0F0F1E),
        Color(0xFF16162A),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _getTimeOfDayGradient(),
        ),
      ),
      child: Stack(
        children: [
          if (widget.enableParticles)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _ParticlePainter(
                      particles: _particles,
                      progress: _animController.value,
                    ),
                  );
                },
              ),
            ),
          widget.child,
        ],
      ),
    );
  }
}

class _Particle {
  double x;
  double y;
  final double radius;
  final double speed;
  final double opacity;
  final Color color;

  _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.opacity,
    required this.color,
  });

  factory _Particle.random(Random rnd) {
    final colors = [
      const Color(0xFF00E5FF), // Cyan
      const Color(0xFFFF007F), // Neon Magenta
      const Color(0xFF10B981), // Emerald
      const Color(0xFFFBBF24), // Amber Gold
      Colors.white,
    ];
    return _Particle(
      x: rnd.nextDouble(),
      y: rnd.nextDouble(),
      radius: rnd.nextDouble() * 2.5 + 1.0,
      speed: rnd.nextDouble() * 0.08 + 0.02,
      opacity: rnd.nextDouble() * 0.4 + 0.15,
      color: colors[rnd.nextInt(colors.length)],
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      // Calculate dynamic drifting position
      final currentY = (p.y - (progress * p.speed)) % 1.0;
      final waveOffset = sin((progress * 2 * pi) + (p.x * 10)) * 0.015;
      final currentX = (p.x + waveOffset).clamp(0.0, 1.0);

      final dx = currentX * size.width;
      final dy = currentY * size.height;

      paint.color = p.color.withValues(alpha: p.opacity);
      canvas.drawCircle(Offset(dx, dy), p.radius, paint);

      // Subtle glow ring
      paint.color = p.color.withValues(alpha: p.opacity * 0.3);
      canvas.drawCircle(Offset(dx, dy), p.radius * 2.2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
