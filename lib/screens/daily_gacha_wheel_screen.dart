import 'package:flutter/material.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

class DailyGachaWheelScreen extends StatefulWidget {
  final GameState gameState;

  const DailyGachaWheelScreen({super.key, required this.gameState});

  @override
  State<DailyGachaWheelScreen> createState() => _DailyGachaWheelScreenState();
}

class _DailyGachaWheelScreenState extends State<DailyGachaWheelScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  bool _isSpinning = false;
  bool _hasClaimed = false;
  String _rewardText = '';
  String _rewardTier = '';
  int _currentStreak = 0;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _hasClaimed = !widget.gameState.user.canClaimDailyGacha;
    _currentStreak = widget.gameState.user.currentStreakDays;
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _triggerGachaRoll() async {
    if (_isSpinning || _hasClaimed) return;

    setState(() {
      _isSpinning = true;
      _statusMessage = null;
    });

    // Start rotational spinning animation with deceleration curve
    _spinController.forward(from: 0.0);

    // Concurrently trigger backend RPC / local probability computation
    final spinFuture = widget.gameState.spinDailyGacha();
    final animFuture = Future.delayed(const Duration(seconds: 3));

    final results = await Future.wait([spinFuture, animFuture]);
    final spinResult = results[0] as Map<String, dynamic>;

    if (!mounted) return;

    if (spinResult['success'] == true) {
      setState(() {
        _isSpinning = false;
        _hasClaimed = true;
        _rewardTier = spinResult['tier'] as String? ?? 'Common';
        _rewardText = spinResult['title'] as String? ?? 'Daily Reward';
        _currentStreak = spinResult['streak'] as int? ?? widget.gameState.user.currentStreakDays;
      });
    } else {
      setState(() {
        _isSpinning = false;
        _hasClaimed = true;
        _statusMessage = spinResult['message'] as String? ?? 'Reward already claimed today!';
        _currentStreak = widget.gameState.user.currentStreakDays;
      });
    }
  }

  Color _getTierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'mythic':
        return const Color(0xFFFF007F); // Neon Magenta/Pink
      case 'rare':
        return Colors.amberAccent;
      case 'common':
      default:
        return Colors.cyanAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.gameState.user;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16162A),
        elevation: 0,
        titleSpacing: 0,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.stars_rounded, color: AppTheme.lagosYellow, size: 20),
            SizedBox(width: 6),
            Flexible(
              child: Text(
                'Daily Bonus',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black38,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.lagosYellow.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🔥', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 4),
                Text(
                  '${_currentStreak > 0 ? _currentStreak : user.currentStreakDays}d Streak',
                  style: const TextStyle(
                    color: AppTheme.lagosYellow,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            children: [
              const Text(
                'DAILY LUCKY REWARD',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tap below to spin for your free daily reward!',
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),

              // Animated Rotational Mystery Gift Box
              Center(
                child: RotationTransition(
                  turns: Tween<double>(begin: 0.0, end: 6.0).animate(
                    CurvedAnimation(
                      parent: _spinController,
                      curve: Curves.fastLinearToSlowEaseIn,
                    ),
                  ),
                  child: Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      color: const Color(0xFF16162A),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isSpinning
                            ? const Color(0xFFFF007F)
                            : (_hasClaimed ? Colors.greenAccent : Colors.cyanAccent),
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_isSpinning
                                  ? const Color(0xFFFF007F)
                                  : (_hasClaimed ? Colors.greenAccent : Colors.cyanAccent))
                              .withValues(alpha: _isSpinning ? 0.6 : 0.25),
                          blurRadius: _isSpinning ? 35 : 20,
                          spreadRadius: _isSpinning ? 4 : 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        _hasClaimed ? Icons.lock_open_rounded : Icons.card_giftcard_rounded,
                        size: 72,
                        color: _hasClaimed ? Colors.greenAccent : Colors.cyanAccent,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Reward Result Card Display
              if (_hasClaimed && _rewardText.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16162A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getTierColor(_rewardTier),
                      width: 1.8,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _getTierColor(_rewardTier).withValues(alpha: 0.25),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getTierColor(_rewardTier).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'TIER: ${_rewardTier.toUpperCase()}',
                          style: TextStyle(
                            color: _getTierColor(_rewardTier),
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _rewardText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '🔥 Login Streak: $_currentStreak days active!',
                        style: const TextStyle(color: Colors.white60, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ] else if (_statusMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16162A),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: Colors.greenAccent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _statusMessage!,
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Spin Action Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hasClaimed
                        ? const Color(0xFF252538)
                        : const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: _hasClaimed ? 0 : 4,
                  ),
                  onPressed: (_isSpinning || _hasClaimed) ? null : _triggerGachaRoll,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isSpinning) ...[
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Flexible(
                        child: Text(
                          _isSpinning
                              ? 'SPINNING FOR PRIZE...'
                              : (_hasClaimed ? 'CLAIMED TODAY • COME BACK TOMORROW' : 'TAP TO SPIN FOR PRIZE 🎁'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: _hasClaimed ? Colors.white38 : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Possible Rewards and Chances
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF141426),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.casino_outlined, color: Colors.white70, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Prizes & Chances',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildProbabilityRow('Standard', '🪙 20 Coins', '50%', Colors.cyanAccent),
                    const Divider(color: Colors.white10, height: 16),
                    _buildProbabilityRow('Standard', '🧃 Chilled Malt (+10 ⚡)', '30%', Colors.cyanAccent),
                    const Divider(color: Colors.white10, height: 16),
                    _buildProbabilityRow('Special', '🪙 150 Coins Jackpot', '13%', Colors.amberAccent),
                    const Divider(color: Colors.white10, height: 16),
                    _buildProbabilityRow('Special', '🍲 Party Jollof (+50 ⚡)', '5%', Colors.amberAccent),
                    const Divider(color: Colors.white10, height: 16),
                    _buildProbabilityRow('Jackpot', '✨ Neon Chat Glow (24h)', '2%', const Color(0xFFFF007F)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProbabilityRow(String tier, String name, String rate, Color color) {
    return Row(
      children: [
        Container(
          width: 65,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            tier,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            name,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
        Text(
          rate,
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }
}
