import 'dart:math';
import 'package:flutter/material.dart';

class FluidNeonCapsuleBar extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final double height;
  final String? label;
  final Color primaryColor;
  final Color secondaryColor;

  const FluidNeonCapsuleBar({
    super.key,
    required this.progress,
    this.height = 28.0,
    this.label,
    this.primaryColor = const Color(0xFF00E5FF), // Cyan
    this.secondaryColor = const Color(0xFFFF007F), // Neon Magenta
  });

  @override
  State<FluidNeonCapsuleBar> createState() => _FluidNeonCapsuleBarState();
}

class _FluidNeonCapsuleBarState extends State<FluidNeonCapsuleBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  final List<_Bubble> _bubbles = [];
  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    for (int i = 0; i < 12; i++) {
      _bubbles.add(_Bubble.random(_rnd));
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clampedProgress = widget.progress.clamp(0.0, 1.0);

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D1A),
        borderRadius: BorderRadius.circular(widget.height / 2),
        border: Border.all(
          color: widget.primaryColor.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.primaryColor.withValues(alpha: 0.25),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.height / 2),
        child: Stack(
          children: [
            // Animated Liquid Painter
            AnimatedBuilder(
              animation: _waveController,
              builder: (context, _) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: _LiquidPainter(
                    progress: clampedProgress,
                    wavePhase: _waveController.value * 2 * pi,
                    bubbles: _bubbles,
                    primaryColor: widget.primaryColor,
                    secondaryColor: widget.secondaryColor,
                  ),
                );
              },
            ),

            // Center Label (e.g., Progress or Remaining Seconds)
            if (widget.label != null)
              Center(
                child: Text(
                  widget.label!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Bubble {
  double x; // 0.0 to 1.0 along progress width
  double y; // 0.0 (top) to 1.0 (bottom)
  final double radius;
  final double speed;

  _Bubble({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
  });

  factory _Bubble.random(Random rnd) {
    return _Bubble(
      x: rnd.nextDouble(),
      y: rnd.nextDouble(),
      radius: rnd.nextDouble() * 2.0 + 1.2,
      speed: rnd.nextDouble() * 0.4 + 0.2,
    );
  }
}

class _LiquidPainter extends CustomPainter {
  final double progress;
  final double wavePhase;
  final List<_Bubble> bubbles;
  final Color primaryColor;
  final Color secondaryColor;

  _LiquidPainter({
    required this.progress,
    required this.wavePhase,
    required this.bubbles,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0.0) return;

    final fillWidth = size.width * progress;

    // Draw liquid gradient body
    final rect = Rect.fromLTWH(0, 0, fillWidth, size.height);
    final gradient = LinearGradient(
      colors: [primaryColor, secondaryColor],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    // Draw wavy fluid crest path
    final path = Path();
    path.moveTo(0, 0);

    const waveHeight = 2.5;
    final waveLength = max(fillWidth, 40.0);

    for (double x = 0; x <= fillWidth; x += 4) {
      final y = sin((x / waveLength * 2 * pi) + wavePhase) * waveHeight;
      path.lineTo(x, y.clamp(0, size.height));
    }

    path.lineTo(fillWidth, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Draw ascending neon bubbles
    final bubblePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;

    for (final b in bubbles) {
      if (b.x <= progress) {
        final currentY = ((b.y - (wavePhase / (2 * pi) * b.speed)) % 1.0);
        final bx = b.x * size.width;
        final by = currentY * size.height;

        canvas.drawCircle(Offset(bx, by), b.radius, bubblePaint);
      }
    }

    // Top glossy reflection highlight
    final glossPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    final glossRect = Rect.fromLTWH(4, 2, max(fillWidth - 8, 0), size.height * 0.35);
    canvas.drawRRect(
      RRect.fromRectAndRadius(glossRect, const Radius.circular(8)),
      glossPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _LiquidPainter oldDelegate) => true;
}
