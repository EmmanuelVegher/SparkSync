import 'package:flutter/material.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/status_header.dart';
import 'dashboard_screen.dart';
import 'inventory_screen.dart';
import 'matches_screen.dart';
import 'two_go_rooms_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0; // Starts on SparkRooms
  final GameState _gameState = GameState();

  @override
  void initState() {
    super.initState();
    _gameState.syncWithSupabaseLive();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _gameState,
      builder: (context, _) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final screens = [
          TwoGoRoomsScreen(gameState: _gameState),
          MatchesScreen(gameState: _gameState),
          DashboardScreen(
            gameState: _gameState,
            onNavigateTab: (index) {
              if (index >= 0 && index < 3) {
                setState(() {
                  _currentIndex = index;
                });
              }
            },
          ),
        ];

        final safeIndex = _currentIndex.clamp(0, screens.length - 1);
        if (_currentIndex != safeIndex) {
          _currentIndex = safeIndex;
        }

        return Scaffold(
          backgroundColor: isDark ? AppTheme.nightObsidian : AppTheme.lightBg,
          body: Column(
            children: [
              // Top Persistent HUD
              StatusHeader(
                gameState: _gameState,
                onEnergyTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (ctx) => InventoryScreen(gameState: _gameState),
                    ),
                  );
                },
                onWalletTap: () {
                  setState(() {
                    _currentIndex = 2; // Switch to City Hub
                  });
                },
              ),

              // Active Screen
              Expanded(
                child: IndexedStack(
                  index: safeIndex,
                  children: screens,
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF121214) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? const Color(0xFF242426) : const Color(0xFFE5E5EA),
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              child: Theme(
                data: Theme.of(context).copyWith(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: BottomNavigationBar(
                  currentIndex: safeIndex,
                  onTap: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  selectedItemColor: AppTheme.brandCoral, // Apple Signature Blue
                  unselectedItemColor: const Color(0xFF8E8E93), // Apple SF Gray
                  selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 10, letterSpacing: -0.2),
                  unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 10, letterSpacing: -0.2),
                  items: [
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.chat_bubble_outline_rounded, size: 22),
                      activeIcon: Icon(Icons.chat_bubble_rounded, size: 22),
                      label: 'Rooms',
                    ),
                    BottomNavigationBarItem(
                      icon: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(Icons.people_outline_rounded, size: 23),
                          if (_gameState.matches.isNotEmpty)
                            Positioned(
                              top: -2,
                              right: -3,
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: AppTheme.neonEmerald,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      activeIcon: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(Icons.people_rounded, size: 23),
                          if (_gameState.matches.isNotEmpty)
                            Positioned(
                              top: -2,
                              right: -3,
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  color: AppTheme.neonEmerald,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      label: 'Matches',
                    ),
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.compass_calibration_outlined, size: 22),
                      activeIcon: Icon(Icons.compass_calibration_rounded, size: 22),
                      label: 'Discover',
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
