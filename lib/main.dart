import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';
import 'services/game_state.dart';
import 'services/supabase_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Supabase Backend Service
  await SupabaseService().initialize();

  runApp(const SparkSyncApp());
}

class SparkSyncApp extends StatelessWidget {
  const SparkSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GameState(),
      builder: (context, _) {
        return MaterialApp(
          title: 'SparkSync — Dating & Life Sim',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: GameState().themeMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}
