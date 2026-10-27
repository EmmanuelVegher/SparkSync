import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/game_state.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import 'auth_screen.dart';
import 'main_shell.dart';

/// Apple-Minimalist Splash Screen
/// Pure OLED black, clean typography, refined smooth fade, zero noisy clutter.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final GameState _gameState = GameState();
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    // Pure Apple immersive UI overlay
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF000000),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    // Apple smooth organic fade & micro-scale entrance
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _startTransitionTimer();
  }

  Future<void> _startTransitionTimer() async {
    // Background sync if logged in
    try {
      if (SupabaseService().currentUser != null) {
        await _gameState.syncWithSupabaseLive();
      }
    } catch (_) {}

    // Apple-style calm, brief holding duration (1.5s total)
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
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
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curve = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
          return FadeTransition(opacity: curve, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Apple OLED pure black
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Stack(
              children: [
                // Minimalist Center Hero (Clean Icon + Pure Apple Typography)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Apple-style squircle brand mark
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: const Color(0xFF161618),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: const Color(0xFF2C2C2E),
                            width: 0.5,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Center(
                          child: Image.asset(
                            'assets/images/app_logo.png',
                            width: 58,
                            height: 58,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.electric_bolt_rounded,
                              size: 40,
                              color: AppTheme.brandCoral,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Apple Title
                      const Text(
                        'SparkSync',
                        style: TextStyle(
                          color: Color(0xFFF5F5F7),
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Apple Subtitle
                      const Text(
                        'Connect. Chat. Meet.',
                        style: TextStyle(
                          color: Color(0xFF86868B),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),

                // Apple Minimalist Activity Indicator at Bottom
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 32,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            const Color(0xFF86868B).withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
