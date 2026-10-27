import 'dart:async';
import 'package:flutter/material.dart';
import '../services/game_state.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';
import 'credit_top_up_sheet.dart';
import 'performance_export_modal.dart';

/// The interactive Audience Voting Poll ("The Judgement Deck") that triggers at the end of a singer's turn
class AudienceVotingPollModal extends StatefulWidget {
  final GameState gameState;
  final String performerName;
  final String performerAvatar;
  final String performerRank;
  final String trackTitle;
  final String trackArtist;
  final bool isAcapella;
  final VoidCallback? onDismissed;

  const AudienceVotingPollModal({
    super.key,
    required this.gameState,
    required this.performerName,
    required this.performerAvatar,
    required this.performerRank,
    required this.trackTitle,
    required this.trackArtist,
    this.isAcapella = false,
    this.onDismissed,
  });

  @override
  State<AudienceVotingPollModal> createState() => _AudienceVotingPollModalState();
}

class _AudienceVotingPollModalState extends State<AudienceVotingPollModal> {
  int? _selectedOptionIndex;
  int _secondsLeft = 24;
  Timer? _countdownTimer;
  bool _hasGiftedBoost = false;

  // Real-time vote distributions
  late List<Map<String, dynamic>> _pollOptions;

  @override
  void initState() {
    super.initState();

    _pollOptions = [
      {
        'index': 0,
        'key': 'naira_spray',
        'label': '🔥 NAIRA SPRAY MATERIAL!',
        'count': 142,
        'percentage': 0.52,
        'color': AppTheme.lagosYellow,
      },
      {
        'index': 1,
        'key': 'good_vibe',
        'label': '🍃 Good Vibe, Clean Notes',
        'count': 93,
        'percentage': 0.34,
        'color': AppTheme.neonEmerald,
      },
      {
        'index': 2,
        'key': 'generator_cut',
        'label': '🔇 Generator Cut the Power',
        'count': 38,
        'percentage': 0.14,
        'color': Colors.redAccent,
      },
    ];

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft > 1) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _submitVote(int index) {
    if (_selectedOptionIndex != null) return; // Prevent double voting

    SoundService().playButtonTap();
    final chosen = _pollOptions[index];
    chosen['count'] = (chosen['count'] as int) + 1;

    // Recalculate percentages
    int total = _pollOptions.fold(0, (sum, o) => sum + (o['count'] as int));
    for (final opt in _pollOptions) {
      opt['percentage'] = (opt['count'] as int) / total;
    }

    setState(() {
      _selectedOptionIndex = index;
    });

    // Reward voter +15 XP
    widget.gameState.user.xp += 15;
    widget.gameState.notifyListeners();

    // Reward performer +25 XP & record vote
    widget.gameState.recordTournamentVote(
      performerName: widget.performerName,
      voteType: chosen['key'] as String,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: chosen['color'] as Color,
        content: Row(
          children: [
            const Text('⚡ ', style: TextStyle(fontSize: 16)),
            Expanded(
              child: Text(
                'Vote logged for "${chosen['label']}"! +15 Clout XP added to your card.',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 1800),
      ),
    );
  }

  void _boostWithCredits() {
    if (_hasGiftedBoost) return;
    if (widget.gameState.user.walletBalance < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: const Text('Not enough Spark Coins! Need at least 10 Coins.'),
          action: SnackBarAction(
            label: 'TOP UP ⚡',
            textColor: AppTheme.lagosYellow,
            onPressed: () => CreditTopUpSheet.show(context, widget.gameState),
          ),
        ),
      );
      return;
    }

    setState(() {
      _hasGiftedBoost = true;
    });

    // Deduct 10 coins, spray money
    widget.gameState.user.walletBalance -= 10;
    widget.gameState.user.xp += 50; // Bonus clout for generous gifter
    widget.gameState.sprayNairaForKaraoke(amount: 10);
    SoundService().playMoneySpray();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppTheme.lagosYellow,
        content: Text(
          '💸 10 Coins Gifted! Performer score boosted and 2x crowd clout awarded!',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  }

  void _openCloutExportStation() {
    Navigator.of(context).pop();
    final totalVotes = _pollOptions.fold<int>(0, (sum, o) => sum + (o['count'] as int));
    final Map<String, int> breakdown = {
      for (final opt in _pollOptions) opt['key'] as String: opt['count'] as int,
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PerformanceExportModal(
        gameState: widget.gameState,
        performerName: widget.performerName,
        performerAvatar: widget.performerAvatar,
        performerRank: widget.performerRank,
        trackTitle: widget.trackTitle,
        trackArtist: widget.trackArtist,
        totalVotes: totalVotes,
        xpEarned: totalVotes * 25,
        isAcapella: widget.isAcapella,
        voteBreakdown: breakdown,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasVoted = _selectedOptionIndex != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF16162A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: widget.isAcapella ? Colors.amberAccent : Colors.cyanAccent.withValues(alpha: 0.5),
            width: 1.8,
          ),
          boxShadow: [
            BoxShadow(
              color: (widget.isAcapella ? Colors.amberAccent : Colors.cyanAccent).withValues(alpha: 0.2),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar: Judgement Deck title + Countdown timer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('🗳️', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      widget.isAcapella ? 'ACAPELLA JUDGEMENT DECK' : 'THE JUDGEMENT DECK',
                      style: TextStyle(
                        color: widget.isAcapella ? Colors.amberAccent : Colors.cyanAccent,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.redAccent.withValues(alpha: 0.6)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer_outlined, color: Colors.redAccent, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '00:${_secondsLeft.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Performer Info Card
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F111E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF2E1A47),
                    child: Text(widget.performerAvatar, style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.performerName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.cyanAccent.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                widget.performerRank,
                                style: const TextStyle(
                                  color: Colors.cyanAccent,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.trackTitle} • ${widget.trackArtist}',
                          style: TextStyle(
                            color: widget.isAcapella ? Colors.amberAccent : Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            Text(
              hasVoted ? 'Current Room Voting Distribution:' : 'Select a Vibe Tier (+15 XP for Voting!):',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // Vibe Tier Voting Options
            ..._pollOptions.map((opt) {
              final idx = opt['index'] as int;
              final isMyChoice = _selectedOptionIndex == idx;
              final pct = (opt['percentage'] as num).toDouble();
              final Color optColor = opt['color'] as Color;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: InkWell(
                  onTap: () => _submitVote(idx),
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      // Base Background
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F0F1E),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isMyChoice
                                ? optColor
                                : Colors.white10,
                            width: isMyChoice ? 1.5 : 1.0,
                          ),
                        ),
                      ),
                      // Animated Bar Fill
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeOutCubic,
                        height: 48,
                        width: MediaQuery.of(context).size.width * (hasVoted ? pct : 0.0),
                        decoration: BoxDecoration(
                          color: optColor.withValues(alpha: isMyChoice ? 0.35 : 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      // Text Contents
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  if (isMyChoice) ...[
                                    Icon(Icons.check_circle, color: optColor, size: 14),
                                    const SizedBox(width: 6),
                                  ],
                                  Text(
                                    opt['label'] as String,
                                    style: TextStyle(
                                      color: isMyChoice ? optColor : Colors.white,
                                      fontSize: 11.5,
                                      fontWeight: isMyChoice ? FontWeight.w900 : FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              if (hasVoted)
                                Text(
                                  '${(pct * 100).toInt()}%',
                                  style: TextStyle(
                                    color: optColor,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 12),

            // Bonus Boost Button: Gift 10 Coins
            InkWell(
              onTap: _hasGiftedBoost ? null : _boostWithCredits,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.lagosYellow.withValues(alpha: _hasGiftedBoost ? 0.1 : 0.25),
                      const Color(0xFF1E1B4B),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.lagosYellow.withValues(alpha: _hasGiftedBoost ? 0.3 : 0.8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🎁', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(
                      _hasGiftedBoost
                          ? '✅ 10 COINS BOOST APPLIED! (2X SCORE)'
                          : 'GIFT 10 COINS TO PERFORMER 🪙',
                      style: TextStyle(
                        color: _hasGiftedBoost ? Colors.white70 : AppTheme.lagosYellow,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Bottom Buttons: Done / View Clout Export Station
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onDismissed?.call();
                    },
                    child: const Text('Back to Chat', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.share_rounded, size: 14),
                    label: const Text('Clout Export', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    onPressed: _openCloutExportStation,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
