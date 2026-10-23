import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/game_state.dart';
import '../services/location_service.dart';
import '../services/sound_service.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import 'avatar_onboarding_screen.dart';
import 'main_shell.dart';

class AuthScreen extends StatefulWidget {
  final GameState gameState;

  const AuthScreen({super.key, required this.gameState});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  bool isLoading = false;
  bool isDetectingLocation = true;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late String _selectedHood;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _selectedHood = LocationService().activeConfig.neighborhoods.first;
    _runLocationDetection();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    if (SupabaseService().isConfigured) {
      _authSubscription = SupabaseService().client?.auth.onAuthStateChange.listen((data) {
        if (data.event == AuthChangeEvent.signedIn && mounted) {
          final user = data.session?.user;
          if (user != null) {
            final emailName = user.email?.split('@').first;
            final metaName = user.userMetadata?['username'] as String? ??
                user.userMetadata?['full_name'] as String? ??
                user.userMetadata?['name'] as String?;
            final chosen = metaName ?? emailName ?? 'Abuja Baller';
            widget.gameState.user.username = chosen;
            _proceedToApp();
          }
        }
      });
    }
  }

  Future<void> _runLocationDetection() async {
    setState(() => isDetectingLocation = true);
    await LocationService().detectLocationOnLaunch();
    if (mounted) {
      setState(() {
        isDetectingLocation = false;
        final config = LocationService().activeConfig;
        if (!config.neighborhoods.contains(_selectedHood)) {
          _selectedHood = config.neighborhoods.first;
        }
      });
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _proceedToApp() {
    final cityConfig = LocationService().activeConfig;
    widget.gameState.user.neighborhood = _selectedHood;
    widget.gameState.syncCity(cityConfig.cityName);

    if (!isLogin) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AvatarOnboardingScreen(gameState: widget.gameState),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    }
  }

  Future<void> _handleSubmit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final username = _usernameController.text.trim();
    final cityConfig = LocationService().activeConfig;

    if (email.isEmpty || password.isEmpty || (!isLogin && username.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.brandCoral,
          content: Text('Please fill in all required fields!'),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      if (isLogin) {
        await SupabaseService().signInWithEmail(email: email, password: password);
        widget.gameState.user.username = email.split('@').first;
      } else {
        await SupabaseService().signUpWithEmail(
          email: email,
          password: password,
          username: username,
          neighborhood: '$_selectedHood, ${cityConfig.cityName}',
        );
        widget.gameState.user.username = username;
        widget.gameState.user.neighborhood = _selectedHood;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.neonEmerald,
            content: Text(isLogin ? 'Welcome back!' : 'Welcome to ${cityConfig.cityName}!'),
          ),
        );
        _proceedToApp();
      }
    } catch (e) {
      if (!mounted) return;

      final errString = e.toString();
      final isRateLimit = errString.contains('over_email_send_rate_limit') ||
          errString.contains('rate limit') ||
          errString.contains('429');

      // 1. If rate limit was triggered, try logging in immediately (account may already be created)
      if (!isLogin && isRateLimit) {
        try {
          await SupabaseService().signInWithEmail(email: email, password: password);
          widget.gameState.user.username = username.isNotEmpty ? username : email.split('@').first;
          widget.gameState.user.neighborhood = _selectedHood;
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppTheme.neonEmerald,
                content: Text('Account recognized! Signed in to ${cityConfig.cityName}!'),
              ),
            );
            _proceedToApp();
            return;
          }
        } catch (_) {
          // If sign in fails, show helpful rate-limit guide dialog below
        }
      }

      if (!mounted) return;

      if (isRateLimit) {
        _showRateLimitDialog(email, username);
      } else {
        final errorMsg = errString.contains('Exception:')
            ? errString.split('Exception:').last.trim()
            : errString;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.brandCoral,
            content: Text(errorMsg),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showRateLimitDialog(String email, String username) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16162A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppTheme.brandCoral, width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.hourglass_top_rounded, color: Colors.orangeAccent),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Supabase Email Rate Limit',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Supabase free tier limits email confirmations to 3-4 per hour.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F1E),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: const Text(
                '💡 Fix in Dashboard:\n1. Open Supabase Dashboard\n2. Go to Authentication > Providers > Email\n3. Toggle OFF "Confirm email"\n4. Click Save',
                style: TextStyle(color: Colors.cyanAccent, fontSize: 11, height: 1.4),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() => isLogin = true);
            },
            child: const Text('Try Sign In', style: TextStyle(color: Colors.cyanAccent)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              widget.gameState.user.username = username.isNotEmpty ? username : email.split('@').first;
              widget.gameState.user.neighborhood = _selectedHood;
              _proceedToApp();
            },
            child: const Text('Continue (Dev Mode)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => isLoading = true);
    try {
      // Attempt Native Android 1-Tap Google Sign-In
      final nativeRes = await SupabaseService().signInWithGoogleNative();
      if (nativeRes?.user != null && mounted) {
        final user = nativeRes!.user!;
        final name = user.userMetadata?['full_name'] as String? ??
            user.userMetadata?['name'] as String? ??
            user.email?.split('@').first ??
            'Abuja Baller';
        widget.gameState.user.username = name;
        _proceedToApp();
        return;
      }

      // User cancelled native picker
      if (nativeRes == null) {
        return;
      }
    } catch (nativeError) {
      debugPrint('[AuthScreen] Native Google sign-in failed: $nativeError');
      if (mounted) {
        _showNativeGoogleErrorDialog(nativeError.toString());
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showNativeGoogleErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16162A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF4285F4), width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.g_mobiledata_rounded, color: Color(0xFF4285F4), size: 30),
            SizedBox(width: 8),
            Text(
              'Google Sign-In Setup',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Google account was selected, but Supabase rejected the ID token:',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: const Text(
                'Most common fix:\n1. Open Supabase > Authentication > Providers > Google\n2. Toggle "Skip nonce checks" to ON\n3. Ensure your Web Client ID is in "Client IDs"\n4. Click Save!',
                style: TextStyle(color: Colors.cyanAccent, fontSize: 12, height: 1.4),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Details: $error',
              style: const TextStyle(color: Colors.white38, fontSize: 10),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4285F4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                await SupabaseService().signInWithGoogle();
              } catch (_) {}
            },
            child: const Text('Use Web Browser Instead', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleGithubSignIn() async {
    setState(() => isLoading = true);
    try {
      final started = await SupabaseService().signInWithGithub();
      if (!started && mounted) {
        _showOAuthSetupGuide('GitHub');
      }
    } catch (e) {
      if (mounted) {
        _showOAuthSetupGuide('GitHub', error: e.toString());
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _handleDiscordSignIn() async {
    setState(() => isLoading = true);
    try {
      final started = await SupabaseService().signInWithDiscord();
      if (!started && mounted) {
        _showOAuthSetupGuide('Discord');
      }
    } catch (e) {
      if (mounted) {
        _showOAuthSetupGuide('Discord', error: e.toString());
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _handleGuestSignIn() async {
    setState(() => isLoading = true);
    try {
      final cityConfig = LocationService().activeConfig;
      final username = _usernameController.text.trim();
      final effectiveName = username.isNotEmpty ? username : 'Abuja Baller';

      await SupabaseService()
          .signInAnonymously(
            username: effectiveName,
            neighborhood: '$_selectedHood, ${cityConfig.cityName}',
          )
          .timeout(const Duration(milliseconds: 1500), onTimeout: () => null);
      widget.gameState.user.username = effectiveName;
      widget.gameState.user.neighborhood = _selectedHood;
      SoundService().playCoinEarned();
      _proceedToApp();
    } catch (e) {
      // Fallback local guest
      widget.gameState.user.username = _usernameController.text.trim().isNotEmpty
          ? _usernameController.text.trim()
          : 'Abuja Baller';
      widget.gameState.user.neighborhood = _selectedHood;
      SoundService().playCoinEarned();
      _proceedToApp();
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showOAuthSetupGuide(String provider, {String? error}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16162A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.cyanAccent, width: 1.5),
        ),
        title: Row(
          children: [
            const Icon(Icons.hub_rounded, color: Colors.cyanAccent),
            const SizedBox(width: 8),
            Text(
              '$provider Sign-In Setup',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To enable free $provider sign-in in your Supabase project:',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(
                '1. Go to Supabase Dashboard > Authentication > Providers\n2. Select $provider and toggle "Enable"\n3. Paste your free Client ID & Secret from $provider Developer Console\n4. Save changes!',
                style: const TextStyle(color: Colors.cyanAccent, fontSize: 12, height: 1.4),
              ),
            ),
            if (error != null) ...[
              const SizedBox(height: 10),
              Text(
                'Notice: $error',
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Got It', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _handleGuestSignIn();
            },
            child: const Text('Enter as Guest (Instant)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showCityPickerDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final cities = LocationService().supportedCities.keys.toList();
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('📍', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 8),
                    const Text(
                      'Choose Your City',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppTheme.textMuted),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'SparkSync dynamically connects you to singles, venues, and jobs in your city.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 16),
                ...cities.map((city) {
                  final isSelected = LocationService().currentCity == city;
                  final cfg = LocationService().supportedCities[city]!;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    tileColor: isSelected ? AppTheme.brandCoral.withValues(alpha: 0.18) : null,
                    leading: Icon(
                      Icons.location_city,
                      color: isSelected ? AppTheme.brandCoral : AppTheme.textMuted,
                    ),
                    title: Text(
                      city,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppTheme.brandCoral : Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      cfg.stateOrCountry,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: AppTheme.brandCoral)
                        : null,
                    onTap: () {
                      setState(() {
                        LocationService().switchCity(city);
                        _selectedHood = LocationService().activeConfig.neighborhoods.first;
                      });
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cityConfig = LocationService().activeConfig;
    final buttonText = isLogin ? cityConfig.enterButtonText : 'Join ${cityConfig.cityName} Singles';

    return Scaffold(
      backgroundColor: AppTheme.nightObsidian,
      body: Stack(
        children: [
          // Background ambient gradient orbs
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.brandCoral.withValues(alpha: 0.18),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.purpleRoyal.withValues(alpha: 0.16),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Top Live Location Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Pulsing live GPS indicator
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.cardSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.neonEmerald.withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.neonEmerald,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.neonEmerald.withValues(alpha: 0.6),
                                      blurRadius: 6,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'LIVE GPS ACTIVE',
                                style: TextStyle(
                                  color: AppTheme.neonEmerald,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // City Picker Pill
                        GestureDetector(
                          onTap: _showCityPickerDialog,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppTheme.cardSurface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppTheme.cardBorder),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_on, size: 13, color: AppTheme.brandCoral),
                                const SizedBox(width: 4),
                                Text(
                                  '${cityConfig.cityName} (Change ▾)',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // App Logo
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.skyCyan.withValues(alpha: 0.45),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                          BoxShadow(
                            color: AppTheme.lagosYellow.withValues(alpha: 0.25),
                            blurRadius: 36,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.asset(
                          'assets/images/app_logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    const Text(
                      'SparkSync',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${cityConfig.cityName} Dating & Life Simulator',
                      style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                    ),

                    const SizedBox(height: 28),

                    // Main Auth Form Card
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: AppTheme.cardSurface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppTheme.cardBorder),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Segmented Switcher: Sign In / Register
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: AppTheme.nightObsidian,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.cardBorder),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => isLogin = true),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 9),
                                      decoration: BoxDecoration(
                                        color: isLogin ? AppTheme.brandCoral : Colors.transparent,
                                        borderRadius: BorderRadius.circular(11),
                                      ),
                                      child: Text(
                                        'Sign In',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: isLogin ? Colors.white : AppTheme.textMuted,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => isLogin = false),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 9),
                                      decoration: BoxDecoration(
                                        color: !isLogin ? AppTheme.brandCoral : Colors.transparent,
                                        borderRadius: BorderRadius.circular(11),
                                      ),
                                      child: Text(
                                        'Register',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: !isLogin ? Colors.white : AppTheme.textMuted,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),

                          if (!isLogin) ...[
                            TextField(
                              controller: _usernameController,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              decoration: InputDecoration(
                                labelText: '${cityConfig.cityName} Alias / Username',
                                labelStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                                prefixIcon: const Icon(Icons.person, color: AppTheme.brandCoral, size: 20),
                                filled: true,
                                fillColor: AppTheme.nightObsidian,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedHood,
                              dropdownColor: AppTheme.nightObsidian,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              decoration: InputDecoration(
                                labelText: 'Your Neighborhood in ${cityConfig.cityName}',
                                labelStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                                prefixIcon: const Icon(Icons.location_on, color: AppTheme.brandCoral, size: 20),
                                filled: true,
                                fillColor: AppTheme.nightObsidian,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              items: cityConfig.neighborhoods
                                  .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                                  .toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedHood = val);
                              },
                            ),
                            const SizedBox(height: 12),
                          ],

                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              labelStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                              prefixIcon: const Icon(Icons.email, color: AppTheme.brandCoral, size: 20),
                              filled: true,
                              fillColor: AppTheme.nightObsidian,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                              prefixIcon: const Icon(Icons.lock, color: AppTheme.brandCoral, size: 20),
                              filled: true,
                              fillColor: AppTheme.nightObsidian,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Dynamic City Action Button (e.g. "Enter Abuja", "Enter Lagos")
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _handleSubmit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.brandCoral,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 6,
                                shadowColor: AppTheme.brandCoral.withValues(alpha: 0.5),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.explore_rounded, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          buttonText,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 15,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Modern Cyberpunk Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.15), thickness: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            'OR CONNECT INSTANTLY',
                            style: TextStyle(
                              color: AppTheme.textMuted.withValues(alpha: 0.8),
                              fontSize: 10,
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.15), thickness: 1)),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Free Social OAuth Methods (Google, GitHub, Discord)
                    Row(
                      children: [
                        // Google
                        Expanded(
                          child: _buildSocialButton(
                            label: 'Google',
                            icon: const _GoogleIcon(),
                            onTap: _handleGoogleSignIn,
                            accentColor: const Color(0xFF4285F4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // GitHub
                        Expanded(
                          child: _buildSocialButton(
                            label: 'GitHub',
                            icon: const Icon(Icons.terminal_rounded, color: Colors.white, size: 18),
                            onTap: _handleGithubSignIn,
                            accentColor: Colors.white70,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Discord
                        Expanded(
                          child: _buildSocialButton(
                            label: 'Discord',
                            icon: const Icon(Icons.sports_esports_rounded, color: Color(0xFF7289DA), size: 18),
                            onTap: _handleDiscordSignIn,
                            accentColor: const Color(0xFF7289DA),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // One-Tap Free Guest Access
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.lagosYellow.withValues(alpha: 0.15),
                            Colors.cyanAccent.withValues(alpha: 0.08),
                          ],
                        ),
                        border: Border.all(
                          color: AppTheme.lagosYellow.withValues(alpha: 0.35),
                          width: 1.2,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          key: const Key('guest_baller_btn'),
                          borderRadius: BorderRadius.circular(14),
                          onTap: _handleGuestSignIn,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.flash_on_rounded, color: AppTheme.lagosYellow, size: 18),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    '⚡ 1-Tap Free Guest Entry to ${cityConfig.cityName}',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppTheme.lagosYellow,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Real-Time Supabase Security Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shield_outlined, size: 12, color: AppTheme.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          'Powered by Supabase PostgreSQL • Live Cloud Sync',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.textMuted.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required Widget icon,
    required VoidCallback onTap,
    required Color accentColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: AppTheme.nightObsidian,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Text(
        'G',
        style: TextStyle(
          color: Color(0xFF4285F4),
          fontWeight: FontWeight.w900,
          fontSize: 12,
          fontFamily: 'sans-serif',
        ),
      ),
    );
  }
}
