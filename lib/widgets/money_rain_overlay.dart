import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class MoneyParticleModel {
  double x;
  double y;
  double speed;
  double angle;
  double spinSpeed;
  double scale;
  double opacity;
  String emoji;

  MoneyParticleModel({
    required this.x,
    required this.y,
    required this.speed,
    required this.angle,
    required this.spinSpeed,
    required this.scale,
    this.opacity = 1.0,
    this.emoji = '💵',
  });
}

class MoneyRainOverlay extends StatefulWidget {
  final bool triggerAnimation;
  final VoidCallback onFinished;

  const MoneyRainOverlay({
    super.key,
    required this.triggerAnimation,
    required this.onFinished,
  });

  @override
  State<MoneyRainOverlay> createState() => _MoneyRainOverlayState();
}

class _MoneyRainOverlayState extends State<MoneyRainOverlay> with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  final List<MoneyParticleModel> _particles = [];
  final Random _random = Random();
  double _screenHeight = 0;
  double _screenWidth = 0;
  int _frameCount = 0;

  static const List<String> _cashEmojis = ['💵', '💸', '💰', '🪙', '💵'];

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_updateParticles)..start();
  }

  void _spawnCashParticle() {
    if (_particles.length > 70) return; // Cap density bounds to protect mobile CPU thresholds
    final emoji = _cashEmojis[_random.nextInt(_cashEmojis.length)];
    _particles.add(
      MoneyParticleModel(
        x: _random.nextDouble() * (_screenWidth > 0 ? _screenWidth : 400),
        y: -30, // Drop from just above screen bounds
        speed: (_random.nextDouble() * 4.5) + 3.5,
        angle: _random.nextDouble() * pi,
        spinSpeed: (_random.nextDouble() * 0.12) - 0.06,
        scale: (_random.nextDouble() * 0.45) + 0.65,
        emoji: emoji,
      ),
    );
  }

  void _updateParticles(Duration duration) {
    if (!mounted) return;

    setState(() {
      if (widget.triggerAnimation && _frameCount % 2 == 0) {
        _spawnCashParticle();
        _spawnCashParticle();
      }
      _frameCount++;

      for (int i = _particles.length - 1; i >= 0; i--) {
        final p = _particles[i];
        p.y += p.speed;
        p.angle += p.spinSpeed;

        // Gradually fade out cash as it approaches bottom half
        if (p.y > _screenHeight * 0.65) {
          p.opacity = (p.opacity - 0.035).clamp(0.0, 1.0);
        }

        // Clean out dead elements from memory
        if (p.y > _screenHeight || p.opacity <= 0.0) {
          _particles.removeAt(i);
        }
      }

      if (!widget.triggerAnimation && _particles.isEmpty && _frameCount > 30) {
        widget.onFinished();
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _screenHeight = MediaQuery.of(context).size.height;
    _screenWidth = MediaQuery.of(context).size.width;

    if (_particles.isEmpty && !widget.triggerAnimation) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: CustomPaint(
        size: Size(_screenWidth, _screenHeight),
        painter: MoneyCanvasPainter(particlesList: _particles),
      ),
    );
  }
}

class MoneyCanvasPainter extends CustomPainter {
  final List<MoneyParticleModel> particlesList;

  MoneyCanvasPainter({required this.particlesList});

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (final p in particlesList) {
      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.angle);
      canvas.scale(p.scale);

      textPainter.text = TextSpan(
        text: p.emoji,
        style: TextStyle(
          fontSize: 26,
          color: Colors.greenAccent.withValues(alpha: p.opacity),
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
