import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/game_state.dart';
import '../services/sound_service.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import 'auth_screen.dart';
import 'main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  late AnimationController _pulseController;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseOpacity;

  late AnimationController _textController;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;

  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  final GameState _gameState = GameState();
  String _statusText = 'Tuning into Lagos Night Frequency...';
  bool _hasNavigated = false;

  final List<String> _loadingMessages = [
    'Welcome to SparkSync...',
    'Opening chat rooms...',
    'Finding hangout spots near you...',
    'Connecting with people around you...',
    'Ready! Let\'s go ✨',
  ];

  @override
  void initState() {
    super.initState();

    // Set immersive navigation
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: AppTheme.nightObsidian,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    // 1. Logo entrance animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    );
    _logoOpacity = CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
    );

    // 2. Continuous neon heart pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 0.95, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseOpacity = Tween<double>(begin: 0.25, end: 0.65).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 3. Text entrance animation
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _textFade = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic));

    // 4. Progress bar animation
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOutCubic,
    );

    _startSplashScreenSequence();
  }

  Future<void> _startSplashScreenSequence() async {
    _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _textController.forward();

    // Start progress & update status messages
    _progressController.forward();

    for (int i = 0; i < _loadingMessages.length; i++) {
      if (!mounted) return;
      setState(() {
        _statusText = _loadingMessages[i];
      });
      await Future.delayed(const Duration(milliseconds: 600));
    }

    // Attempt backend sync in background if user exists
    try {
      if (SupabaseService().currentUser != null) {
        await _gameState.syncWithSupabaseLive();
      }
    } catch (_) {}

    // Complete splash chime & transition
    if (mounted) {
      SoundService().playSparkMatch();
      await Future.delayed(const Duration(milliseconds: 300));
      _navigateToNextScreen();
    }
  }

  void _navigateToNextScreen() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    final hasUser = SupabaseService().currentUser != null;
    final destination = hasUser
        ? const MainShell()
        : AuthScreen(gameState: _gameState);

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curve = CurvedAnimation(parent: animation, curve: Curves.easeInOutQuart);
          return FadeTransition(
            opacity: curve,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1.0).animate(curve),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _pulseController.dispose();
    _textController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.nightObsidian,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Lagos Skyline Background Image with Cinematic Overlay
          Image.asset(
            'assets/images/splash_bg.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const SizedBox(),
          ),

          // 2. Deep Obsidian Gradient & Vignette (for high-contrast luxury look)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.nightObsidian.withValues(alpha: 0.82),
                  AppTheme.nightObsidian.withValues(alpha: 0.70),
                  AppTheme.nightObsidian.withValues(alpha: 0.94),
                  AppTheme.nightObsidian,
                ],
                stops: const [0.0, 0.35, 0.75, 1.0],
              ),
            ),
          ),

          // 3. Skip Button (Top Right)
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
                child: TextButton(
                  onPressed: _navigateToNextScreen,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Skip',
                        style: TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios, size: 10, color: AppTheme.textMuted),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 4. Centered Hero Logo & Animated Glow
          Center(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Glowing Pulse Aura + SparkSync Emblem
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Animated Glowing Ring Aura
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, _) {
                              return Transform.scale(
                                scale: _pulseScale.value,
                                child: Container(
                                  width: 170,
                                  height: 170,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        AppTheme.skyCyan.withValues(alpha: _pulseOpacity.value),
                                        AppTheme.lagosYellow.withValues(alpha: _pulseOpacity.value * 0.7),
                                        AppTheme.neonEmerald.withValues(alpha: _pulseOpacity.value * 0.3),
                                        Colors.transparent,
                                      ],
                                      stops: const [0.2, 0.5, 0.75, 1.0],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                          // Brand Logo Emblem with Scale & Opacity
                          AnimatedBuilder(
                            animation: _logoController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _logoScale.value,
                                child: Opacity(
                                  opacity: _logoOpacity.value,
                                  child: child,
                                ),
                              );
                            },
                            child: Hero(
                              tag: 'app_brand_logo',
                              child: Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(32),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.skyCyan.withValues(alpha: 0.55),
                                      blurRadius: 36,
                                      spreadRadius: 4,
                                    ),
                                    BoxShadow(
                                      color: AppTheme.lagosYellow.withValues(alpha: 0.35),
                                      blurRadius: 50,
                                      spreadRadius: 8,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(32),
                                  child: Image.asset(
                                    'assets/images/app_logo.png',
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: AppTheme.cardSurface,
                                      child: const Icon(
                                        Icons.flash_on_rounded,
                                        size: 64,
                                        color: AppTheme.skyCyan,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // App Title & Tagline with Slide/Fade Transition
                    AnimatedBuilder(
                      animation: _textController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _textFade.value,
                          child: SlideTransition(
                            position: _textSlide,
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          // Gradient SparkSync Title
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                Color(0xFFFF5E7E),
                                Color(0xFFFFD027),
                                Color(0xFF00E676),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: const Text(
                              'SparkSync',
                              style: TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Subtitle Badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.cardSurface.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppTheme.brandCoral.withValues(alpha: 0.35),
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              'LAGOS DATING & LIFE SIMULATOR',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.lagosYellow,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Feature highlights pill
                          Text(
                            'Chat Rooms • Hangout Spots • Meet People',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMuted.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 5. Bottom Loading Bar & City Frequency Status
          Positioned(
            left: 36,
            right: 36,
            bottom: 46,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Live Status Message
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _statusText,
                    key: ValueKey<String>(_statusText),
                    style: const TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 14),

                // Sleek Gradient Progress Bar
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, _) {
                      return FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _progressAnimation.value.clamp(0.05, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              colors: [
                                AppTheme.brandCoral,
                                AppTheme.electricPink,
                                AppTheme.lagosYellow,
                                AppTheme.neonEmerald,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.brandCoral.withValues(alpha: 0.6),
                                blurRadius: 10,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 14),

                // Version & City
                Text(
                  'SparkSync • Lagos & Nigeria',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
