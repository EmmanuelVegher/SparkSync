import 'dart:math';
import 'package:flutter/material.dart';

class MatchAlertPopup extends StatefulWidget {
  final Map<String, dynamic> matchData;
  final VoidCallback? onOpenDm;

  const MatchAlertPopup({
    super.key,
    required this.matchData,
    this.onOpenDm,
  });

  @override
  State<MatchAlertPopup> createState() => _MatchAlertPopupState();
}

class _MatchAlertPopupState extends State<MatchAlertPopup>
    with TickerProviderStateMixin {
  late AnimationController _flightController;
  late Animation<double> _flightAnimation;
  late AnimationController _flashController;
  late Animation<double> _flashAnimation;
  late AnimationController _sparkController;

  static const Color neonMagenta = Color(0xFFFF007F);
  static const Color neonCyan = Color(0xFF00E5FF);

  final List<_SparkParticle> _sparks = [];
  final Random _rnd = Random();

  @override
  void initState() {
    super.initState();

    // 1. Dual Flying Avatars Inbound Controller (Elastic collision in center)
    _flightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _flightAnimation = CurvedAnimation(
      parent: _flightController,
      curve: Curves.elasticOut,
    );

    // 2. Cinematic Flash Controller (Flashes on impact)
    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _flashAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _flashController, curve: Curves.easeOut),
    );

    // 3. Continuous Sparks & Lightning Controller
    _sparkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    for (int i = 0; i < 30; i++) {
      _sparks.add(_SparkParticle.random(_rnd));
    }

    _flightController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _flashController.forward();
      }
    });
  }

  @override
  void dispose() {
    _flightController.dispose();
    _flashController.dispose();
    _sparkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final partnerName = widget.matchData['user_two_name']?.toString() ??
        widget.matchData['username']?.toString() ??
        'Your New Match';

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.92),
      body: Stack(
        children: [
          // Lightning Bolts & Electric Shockwave Canvas Painter
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _sparkController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _ShockwaveSparksPainter(
                    sparks: _sparks,
                    progress: _sparkController.value,
                    flashVal: _flashAnimation.value,
                  ),
                );
              },
            ),
          ),

          // Cinematic Flash Overlay
          AnimatedBuilder(
            animation: _flashAnimation,
            builder: (context, _) {
              if (_flashAnimation.value <= 0.01) {
                return const SizedBox.shrink();
              }
              return Container(
                color: Colors.white.withValues(
                  alpha: _flashAnimation.value * 0.7,
                ),
              );
            },
          ),

          // Central Main Interaction Deck
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Retro Arcade Sparksync Typography
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: neonCyan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: neonCyan.withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                    ),
                    child: const Text(
                      "⚡ MUTUAL SPARK DETECTED ⚡",
                      style: TextStyle(
                        color: neonCyan,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "IT'S A MATCH!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      shadows: [
                        Shadow(
                          color: neonMagenta,
                          blurRadius: 15,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "You and $partnerName both sparked each other! The connection is 100% mutual.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Dual Avatars Flying In & Colliding with Elastic Bounce
                  AnimatedBuilder(
                    animation: _flightAnimation,
                    builder: (context, _) {
                      final travel = (1.0 - _flightAnimation.value) * (size.width * 0.45);
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Left User Avatar (Flies from Left)
                          Transform.translate(
                            offset: Offset(-travel, 0),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: neonMagenta.withValues(alpha: 0.7),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 52,
                                backgroundColor: neonMagenta,
                                child: const CircleAvatar(
                                  radius: 48,
                                  backgroundColor: Color(0xFF1E1B4B),
                                  child: Icon(
                                    Icons.person,
                                    size: 42,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Electric Spark Collision Beacon in Center
                          Transform.scale(
                            scale: _flightAnimation.value,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Icon(
                                Icons.bolt,
                                color: Colors.amberAccent,
                                size: 36,
                              ),
                            ),
                          ),

                          // Right Match Avatar (Flies from Right)
                          Transform.translate(
                            offset: Offset(travel, 0),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: neonCyan.withValues(alpha: 0.7),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 52,
                                backgroundColor: neonCyan,
                                child: const CircleAvatar(
                                  radius: 48,
                                  backgroundColor: Color(0xFF1E1B4B),
                                  child: Icon(
                                    Icons.favorite,
                                    size: 38,
                                    color: Color(0xFFFF007F),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 48),

                  // Action Buttons
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 8,
                        shadowColor: const Color(0xFF6C63FF).withValues(alpha: 0.5),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (widget.onOpenDm != null) {
                          widget.onOpenDm!();
                        }
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_bubble_rounded,
                              size: 18, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            "OPEN PRIVATE DM NOW",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white38),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        "KEEP SWIPING",
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SparkParticle {
  double angle;
  double distance;
  double speed;
  double radius;
  Color color;

  _SparkParticle({
    required this.angle,
    required this.distance,
    required this.speed,
    required this.radius,
    required this.color,
  });

  factory _SparkParticle.random(Random rnd) {
    final colors = [
      const Color(0xFF00E5FF),
      const Color(0xFFFF007F),
      Colors.amberAccent,
      Colors.white,
    ];
    return _SparkParticle(
      angle: rnd.nextDouble() * 2 * pi,
      distance: rnd.nextDouble() * 160 + 20,
      speed: rnd.nextDouble() * 0.8 + 0.3,
      radius: rnd.nextDouble() * 2.5 + 1.0,
      color: colors[rnd.nextInt(colors.length)],
    );
  }
}

class _ShockwaveSparksPainter extends CustomPainter {
  final List<_SparkParticle> sparks;
  final double progress;
  final double flashVal;

  _ShockwaveSparksPainter({
    required this.sparks,
    required this.progress,
    required this.flashVal,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    // Expanding shockwave ripple rings
    final rippleRadius = (progress * 220) % 220;
    final rippleOpacity = (1.0 - (rippleRadius / 220)).clamp(0.0, 1.0) * 0.4;
    final ringPaint = Paint()
      ..color = const Color(0xFF00E5FF).withValues(alpha: rippleOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, rippleRadius, ringPaint);

    // Radiating electric spark dots
    for (final s in sparks) {
      final currentDist = (s.distance + (progress * 80 * s.speed)) % 240;
      final x = center.dx + cos(s.angle) * currentDist;
      final y = center.dy + sin(s.angle) * currentDist;

      paint.color = s.color.withValues(
        alpha: (1.0 - (currentDist / 240)).clamp(0.0, 1.0),
      );
      canvas.drawCircle(Offset(x, y), s.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ShockwaveSparksPainter oldDelegate) => true;
}
