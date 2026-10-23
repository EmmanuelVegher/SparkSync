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
          backgroundColor: AppTheme.nightObsidian,
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
            decoration: const BoxDecoration(
              color: AppTheme.cardSurface,
              border: Border(top: BorderSide(color: AppTheme.cardBorder, width: 1)),
            ),
            child: SafeArea(
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
                selectedItemColor: AppTheme.brandCoral,
                unselectedItemColor: AppTheme.textMuted,
                selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                unselectedLabelStyle: const TextStyle(fontSize: 10),
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.forum_outlined),
                    activeIcon: Icon(Icons.forum_rounded),
                    label: 'Rooms',
                  ),
                  BottomNavigationBarItem(
                    icon: Stack(
                      children: [
                        const Icon(Icons.chat_bubble_outline_rounded),
                        if (_gameState.matches.isNotEmpty)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppTheme.neonEmerald,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                    activeIcon: Stack(
                      children: [
                        const Icon(Icons.chat_bubble_rounded),
                        if (_gameState.matches.isNotEmpty)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 8,
                              height: 8,
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
                    icon: Icon(Icons.explore_outlined),
                    activeIcon: Icon(Icons.explore_rounded),
                    label: 'City Hub',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
