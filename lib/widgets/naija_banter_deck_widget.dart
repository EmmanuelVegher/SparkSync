import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/football_service.dart';
import '../services/game_state.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';

class NaijaBanterDeckWidget extends StatefulWidget {
  final GameState gameState;
  final String roomId;

  const NaijaBanterDeckWidget({
    super.key,
    required this.gameState,
    required this.roomId,
  });

  @override
  State<NaijaBanterDeckWidget> createState() => _NaijaBanterDeckWidgetState();
}

class _NaijaBanterDeckWidgetState extends State<NaijaBanterDeckWidget> with SingleTickerProviderStateMixin {
  final List<_FloatingParticle> _particles = [];
  String _activeTab = 'predictions'; // 'predictions' or 'soundboard'
  String? _selectedOutcome; // '1', 'X', or '2'
  String _selectedLeagueId = '4328'; // Premier League by default
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _fetchLiveMatch();
  }

  Future<void> _fetchLiveMatch() async {
    setState(() => _isRefreshing = true);
    await widget.gameState.refreshLiveMatchPool(leagueId: _selectedLeagueId);
    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  void _onSelectLeague(String leagueId) {
    if (_selectedLeagueId == leagueId && !_isRefreshing) return;
    setState(() {
      _selectedLeagueId = leagueId;
      _selectedOutcome = null;
    });
    _fetchLiveMatch();
  }

  static const List<Map<String, String>> _availableClubs = [
    {'name': 'Arsenal 🔴', 'league': 'EPL'},
    {'name': 'Chelsea 🔵', 'league': 'EPL'},
    {'name': 'Man United 🔴', 'league': 'EPL'},
    {'name': 'Liverpool 🔴', 'league': 'EPL'},
    {'name': 'Man City 🩵', 'league': 'EPL'},
    {'name': 'Tottenham ⚪', 'league': 'EPL'},
    {'name': 'Real Madrid ⚪', 'league': 'La Liga'},
    {'name': 'Barcelona 🔵🔴', 'league': 'La Liga'},
    {'name': 'Atletico Madrid 🔴⚪', 'league': 'La Liga'},
    {'name': 'Juventus ⚪⚫', 'league': 'Serie A'},
    {'name': 'Inter Milan 🔵⚫', 'league': 'Serie A'},
    {'name': 'AC Milan 🔴⚫', 'league': 'Serie A'},
    {'name': 'Napoli 🩵', 'league': 'Serie A'},
    {'name': 'Bayern Munich 🔴', 'league': 'Bundesliga'},
    {'name': 'Dortmund 🟡⚫', 'league': 'Bundesliga'},
    {'name': 'Bayer Leverkusen 🔴⚫', 'league': 'Bundesliga'},
    {'name': 'PSG 🔵🔴', 'league': 'Ligue 1'},
  ];

  static const List<Map<String, dynamic>> _soundPads = [
    {
      'id': 'whistle',
      'label': 'VAR / Whistle',
      'emoji': '🚨',
      'color': Color(0xFFFF5252),
      'subtitle': 'Referee Check',
    },
    {
      'id': 'vuvuzela',
      'label': 'Vuvuzela',
      'emoji': '🎺',
      'color': Color(0xFF00E676),
      'subtitle': 'Stadium Horn',
    },
    {
      'id': 'goal',
      'label': 'Goal Cheer',
      'emoji': '⚽',
      'color': Color(0xFFFFD027),
      'subtitle': 'Stadium Roar',
    },
    {
      'id': 'airhorn',
      'label': 'Airhorn',
      'emoji': '📯',
      'color': Color(0xFFFF9100),
      'subtitle': 'Derby Siren',
    },
    {
      'id': 'sheesh',
      'label': 'God Quando!',
      'emoji': '😱',
      'color': Color(0xFFFF1B6B),
      'subtitle': 'E Choke!',
    },
    {
      'id': 'scratch',
      'label': 'Wotowoto!',
      'emoji': '💨',
      'color': Color(0xFFE040FB),
      'subtitle': 'Red Card Foul',
    },
  ];

  void _spawnParticle(String emoji) {
    if (!mounted) return;
    setState(() {
      _particles.add(
        _FloatingParticle(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          emoji: emoji,
          startX: 0.15 + math.Random().nextDouble() * 0.70,
        ),
      );
      if (_particles.length > 14) {
        _particles.removeAt(0);
      }
    });

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() {
          _particles.removeWhere((p) => DateTime.now().difference(p.created).inMilliseconds > 1300);
        });
      }
    });
  }

  void _onSoundPadTapped(String padId, String emoji) {
    final err = widget.gameState.triggerBanterSoundPad(padId);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(err, style: const TextStyle(fontWeight: FontWeight.bold)),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      _spawnParticle(emoji);
    }
  }

  void _onStakePool(String outcome) {
    final pool = widget.gameState.activePredictionPool;
    final err = widget.gameState.submitMatchPrediction(
      poolId: pool.id,
      outcome: outcome,
    );
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(err, style: const TextStyle(fontWeight: FontWeight.bold)),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      _spawnParticle('⚽');
      _spawnParticle('🏆');
      _spawnParticle('🪙');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.neonEmerald,
          content: const Text(
            '⚽ 10 Credits Staked! You earned +50 XP and unlocked the Certified Pundit 🏆 badge!',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _openClubPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131926),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '🛡️ Choose Your Club Loyalty',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white60, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Display your team badge in the Banter Lounge and spark rival conversations!',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableClubs.map((club) {
                    final isSelected = widget.gameState.user.supportedClub == club['name'];
                    return ChoiceChip(
                      label: Text(
                        club['name']!,
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppTheme.lagosYellow,
                      backgroundColor: const Color(0xFF1E283A),
                      onSelected: (_) {
                        widget.gameState.setSupportedClub(club['name']!);
                        _spawnParticle('🛡️');
                        Navigator.pop(ctx);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openRivalCocktailSheet() {
    final rivals = [
      {'name': 'Amaka (Chelsea 🔵)', 'club': 'Chelsea 🔵', 'avatar': '👩🏾'},
      {'name': 'Chinedu (Arsenal 🔴)', 'club': 'Arsenal 🔴', 'avatar': '👨🏾'},
      {'name': 'Blessing (Man United 🔴)', 'club': 'Man United 🔴', 'avatar': '👩🏽'},
      {'name': 'Tunde (Real Madrid ⚪)', 'club': 'Real Madrid ⚪', 'avatar': '👨🏿'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131926),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '🍹 Send Matchday Rivalry Cocktail',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white60, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Break the ice with a rival fan! Send a 50 🪙 drink: "May the best team win, but drinks on me 😉" (+40 XP)',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 14),
                ...rivals.map((rival) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2234),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: [
                        Text(rival['avatar']!, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rival['name']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const Text(
                                'Active in Banter Lounge',
                                style: TextStyle(color: AppTheme.neonEmerald, fontSize: 10.5),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            final err = widget.gameState.sendMatchdayCocktail(
                              recipientName: rival['name']!,
                              rivalClub: rival['club']!,
                            );
                            if (err != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.redAccent,
                                  content: Text(err),
                                ),
                              );
                            } else {
                              _spawnParticle('🍹');
                              _spawnParticle('❤️');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: AppTheme.electricPink,
                                  content: Text('🍹 Rivalry cocktail sent to ${rival['name']}! Smooth icebreaker!'),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.brandCoral,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            minimumSize: Size.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text(
                            'Send 50 🪙',
                            style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
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
    return ListenableBuilder(
      listenable: widget.gameState,
      builder: (context, _) {
        final gs = widget.gameState;
        final pool = gs.activePredictionPool;
        final hasPredicted = pool.userPrediction != null;
        final currentClub = gs.user.supportedClub ?? 'My Club 🛡️';

        return Stack(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(10, 4, 10, 4),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1522),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF23314B)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. TOP HEADER: CLUB ALLEGIANCE & PUNDIT BADGE & RIVAL COCKTAIL
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141C2D),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                      border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.07))),
                    ),
                    child: Row(
                      children: [
                        // Club Loyalty Chip
                        InkWell(
                          onTap: _openClubPicker,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E283E),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppTheme.skyCyan.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🛡️ ', style: TextStyle(fontSize: 11)),
                                Text(
                                  currentClub,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                const Icon(Icons.arrow_drop_down, color: AppTheme.skyCyan, size: 14),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Certified Pundit Badge
                        if (gs.user.isCertifiedPundit) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD027), Color(0xFFFF9100)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('🏆 ', style: TextStyle(fontSize: 10)),
                                Text(
                                  'PUNDIT',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const Spacer(),

                        // Send Rival Drink Button
                        InkWell(
                          onTap: _openRivalCocktailSheet,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF1B6B), Color(0xFFFF4D6D)],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.brandCoral.withValues(alpha: 0.3),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('🍹 ', style: TextStyle(fontSize: 11)),
                                Text(
                                  'Rival Drink',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. TAB SWITCHER: PREDICTIONS POOL VS BANTER SOUNDBOARD
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _activeTab = 'predictions'),
                            borderRadius: BorderRadius.circular(8),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: _activeTab == 'predictions'
                                    ? AppTheme.lagosYellow.withValues(alpha: 0.18)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _activeTab == 'predictions'
                                      ? AppTheme.lagosYellow
                                      : Colors.white12,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('⚽ ', style: TextStyle(fontSize: 12)),
                                  Text(
                                    'PREDICTIONS POOL',
                                    style: TextStyle(
                                      color: _activeTab == 'predictions'
                                          ? AppTheme.lagosYellow
                                          : AppTheme.textMuted,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _activeTab = 'soundboard'),
                            borderRadius: BorderRadius.circular(8),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                color: _activeTab == 'soundboard'
                                    ? AppTheme.neonEmerald.withValues(alpha: 0.18)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _activeTab == 'soundboard'
                                      ? AppTheme.neonEmerald
                                      : Colors.white12,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('📢 ', style: TextStyle(fontSize: 12)),
                                  Text(
                                    'BANTER SOUNDBOARD',
                                    style: TextStyle(
                                      color: _activeTab == 'soundboard'
                                          ? AppTheme.neonEmerald
                                          : AppTheme.textMuted,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3. TAB CONTENT
                  if (_activeTab == 'predictions') ...[
                    _buildPredictionsArena(context, pool, hasPredicted),
                  ] else ...[
                    _buildSoundboard(context, gs),
                  ],
                ],
              ),
            ),

            // FLOATING CELEBRATION PARTICLES
            ..._particles.map(
              (p) => Positioned(
                bottom: 20 + p.progress * 150,
                left: MediaQuery.of(context).size.width * p.startX,
                child: Opacity(
                  opacity: (1.0 - p.progress).clamp(0.0, 1.0),
                  child: Text(
                    p.emoji,
                    style: TextStyle(fontSize: 22 + p.progress * 8),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPredictionsArena(BuildContext context, MatchPredictionPool pool, bool hasPredicted) {
    final homeStakes = pool.predictionsCount['1'] ?? 0;
    final drawStakes = pool.predictionsCount['X'] ?? 0;
    final awayStakes = pool.predictionsCount['2'] ?? 0;
    final totalStakes = homeStakes + drawStakes + awayStakes;
    final effectiveTotal = totalStakes == 0 ? 1 : totalStakes;

    final homePercent = (homeStakes / effectiveTotal * 100).toInt();
    final drawPercent = (drawStakes / effectiveTotal * 100).toInt();
    final awayPercent = 100 - homePercent - drawPercent;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
      child: Column(
        children: [
          // Dynamic League Selector Pills (EPL, UCL, La Liga, Serie A, Bundesliga, Ligue 1)
          SizedBox(
            height: 28,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: FootballService.supportedLeagues.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final league = FootballService.supportedLeagues[index];
                final isSelected = league.id == _selectedLeagueId;
                return InkWell(
                  onTap: () => _onSelectLeague(league.id),
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF0071E3) : const Color(0xFF161618),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF0071E3) : const Color(0xFF2C2C2E),
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(league.flag, style: const TextStyle(fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(
                          league.shortName,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Match Fixture Header Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF141B2B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              pool.league.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppTheme.skyCyan,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: AppTheme.neonEmerald.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('🔴 ', style: TextStyle(fontSize: 7)),
                                Text(
                                  'LIVE',
                                  style: TextStyle(
                                    color: AppTheme.neonEmerald,
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          pool.matchTime,
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: _isRefreshing ? null : _fetchLiveMatch,
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: _isRefreshing
                                ? const SizedBox(
                                    width: 10,
                                    height: 10,
                                    child: CircularProgressIndicator(strokeWidth: 1.5, color: AppTheme.skyCyan),
                                  )
                                : const Icon(Icons.refresh_rounded, size: 14, color: AppTheme.textMuted),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Teams Clash Row
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(pool.homeBadge, style: const TextStyle(fontSize: 16)),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              pool.homeTeam,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'VS',
                        style: TextStyle(
                          color: AppTheme.lagosYellow,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              pool.awayTeam,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.end,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(pool.awayBadge, style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Live Pool Total Pot Counter
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🪙 Total Pool: ', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                    Text(
                      '${pool.totalPoolCredits} Credits',
                      style: const TextStyle(
                        color: AppTheme.lagosYellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppTheme.neonEmerald.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '$totalStakes Stakes',
                        style: const TextStyle(color: AppTheme.neonEmerald, fontSize: 9.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Odds Distribution Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Row(
              children: [
                Expanded(
                  flex: homePercent.clamp(1, 100),
                  child: Container(
                    height: 5,
                    color: const Color(0xFFFF4D4D),
                  ),
                ),
                Expanded(
                  flex: drawPercent.clamp(1, 100),
                  child: Container(
                    height: 5,
                    color: Colors.white54,
                  ),
                ),
                Expanded(
                  flex: awayPercent.clamp(1, 100),
                  child: Container(
                    height: 5,
                    color: const Color(0xFF2979FF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 3 STAKE OUTCOME BUTTONS (Dynamically labeled based on real fixture)
          if (!hasPredicted) ...[
            Row(
              children: [
                Expanded(
                  child: _buildOutcomeCard(
                    title: '1 (${FootballService.getShortTeamName(pool.homeTeam)})',
                    count: homeStakes,
                    percent: homePercent,
                    outcomeKey: '1',
                    color: const Color(0xFFFF5252),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildOutcomeCard(
                    title: 'X (Draw)',
                    count: drawStakes,
                    percent: drawPercent,
                    outcomeKey: 'X',
                    color: const Color(0xFFB0BEC5),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildOutcomeCard(
                    title: '2 (${FootballService.getShortTeamName(pool.awayTeam)})',
                    count: awayStakes,
                    percent: awayPercent,
                    outcomeKey: '2',
                    color: const Color(0xFF448AFF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Confirm Stake Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedOutcome == null
                    ? null
                    : () => _onStakePool(_selectedOutcome!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lagosYellow,
                  disabledBackgroundColor: Colors.white12,
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  _selectedOutcome == null
                      ? 'Select an outcome to stake 10 🪙'
                      : 'Stake 10 🪙 on ${_selectedOutcome == "1" ? pool.homeTeam : _selectedOutcome == "2" ? pool.awayTeam : "Draw"} (+50 XP)',
                  style: TextStyle(
                    color: _selectedOutcome == null ? Colors.white38 : Colors.black,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ] else ...[
            // Already Staked Status Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.neonEmerald.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.neonEmerald.withValues(alpha: 0.35)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppTheme.neonEmerald, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'You staked 10 🪙 on ${pool.userPrediction == "1" ? pool.homeTeam : pool.userPrediction == "2" ? pool.awayTeam : "Draw"}!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const Text(
                          '🏆 Certified Pundit Unlocked • Winner pool will be paid after FT',
                          style: TextStyle(color: AppTheme.neonEmerald, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOutcomeCard({
    required String title,
    required int count,
    required int percent,
    required String outcomeKey,
    required Color color,
  }) {
    final isSelected = _selectedOutcome == outcomeKey;
    return InkWell(
      onTap: () {
        SoundService().playButtonTap();
        setState(() => _selectedOutcome = outcomeKey);
      },
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.22) : const Color(0xFF141C2E),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.white10,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : AppTheme.textMuted,
                fontWeight: FontWeight.bold,
                fontSize: 10.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              '$percent%',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontSize: 13,
              ),
            ),
            Text(
              '$count stakes',
              style: const TextStyle(color: Colors.white38, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundboard(BuildContext context, GameState gs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 4, 10, 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('📢 ', style: TextStyle(fontSize: 11)),
                  Text(
                    'TAP TO BLAST STADIUM FX & BANTER:',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
              Text(
                '🪙 ${gs.user.walletBalance} Credits',
                style: const TextStyle(
                  color: AppTheme.lagosYellow,
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 1.85,
            ),
            itemCount: _soundPads.length,
            itemBuilder: (context, i) {
              final pad = _soundPads[i];
              final padColor = pad['color'] as Color;
              return InkWell(
                onTap: () => _onSoundPadTapped(pad['id'], pad['emoji']),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141C2E),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: padColor.withValues(alpha: 0.4)),
                    gradient: LinearGradient(
                      colors: [
                        padColor.withValues(alpha: 0.15),
                        const Color(0xFF141C2E),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(pad['emoji'], style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              pad['label'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '2 🪙',
                              style: TextStyle(
                                color: padColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FloatingParticle {
  final String id;
  final String emoji;
  final double startX;
  final DateTime created;

  _FloatingParticle({
    required this.id,
    required this.emoji,
    required this.startX,
  }) : created = DateTime.now();

  double get progress {
    final ms = DateTime.now().difference(created).inMilliseconds;
    return (ms / 1300.0).clamp(0.0, 1.0);
  }
}
