import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

class CoopTriviaSheet extends StatefulWidget {
  final MatchProfile match;
  final GameState gameState;

  const CoopTriviaSheet({
    super.key,
    required this.match,
    required this.gameState,
  });

  @override
  State<CoopTriviaSheet> createState() => _CoopTriviaSheetState();
}

class _CoopTriviaSheetState extends State<CoopTriviaSheet> {
  int currentQuestionIndex = 0;
  int score = 0;
  bool isFinished = false;

  final List<Map<String, dynamic>> questions = [
    {
      'question': 'Friday Night Date in Lagos: What is the move?',
      'options': [
        '🍾 Quilox VIP Table popping champagne till dawn',
        '🥩 Midnight Spicy Suya & cold drinks in Ikoyi',
        '🎬 Quiet Netflix & chilled wine in Lekki Phase 1',
      ],
      'idealMatchAnswer': 1,
    },
    {
      'question': 'Jollof Rice Battle: The eternal question!',
      'options': [
        '🇳🇬 Nigerian Party Jollof (Smoky, spicy, undisputed)',
        '🇬🇭 Ghanaian Jollof (Respectfully questionable)',
        '🍚 White Rice & Designer Stew',
      ],
      'idealMatchAnswer': 0,
    },
    {
      'question': 'NEPA takes light in the middle of dinner! What do you do?',
      'options': [
        '🕯️ Light romantic candles and pretend it was planned',
        '🤬 Complain bitterly about the national grid for 1 hour',
        '⛽ Go outside and pull the generator recoil string with full chest',
      ],
      'idealMatchAnswer': 0,
    },
  ];

  void _answer(int selectedOption) {
    if (selectedOption == questions[currentQuestionIndex]['idealMatchAnswer']) {
      score++;
    }

    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      setState(() {
        isFinished = true;
      });
      widget.gameState.recordTriviaResults(widget.match, score);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: const BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                const Text('🎯', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lagos Couple Sync Quiz',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Testing chemistry with ${widget.match.name}',
                        style: const TextStyle(fontSize: 12, color: AppTheme.brandCoral),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppTheme.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (!isFinished) ...[
              // Progress indicator
              Row(
                children: List.generate(questions.length, (index) {
                  return Expanded(
                    child: Container(
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: index <= currentQuestionIndex
                            ? AppTheme.brandCoral
                            : AppTheme.darkShimmer,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              // Question text
              Text(
                'Question ${currentQuestionIndex + 1} of ${questions.length}',
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 8),
              Text(
                questions[currentQuestionIndex]['question'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // Options
              ...((questions[currentQuestionIndex]['options'] as List<String>).asMap().entries.map(
                (entry) {
                  final idx = entry.key;
                  final text = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _answer(idx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.nightObsidian,
                        foregroundColor: AppTheme.textLight,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppTheme.cardBorder),
                        ),
                        alignment: Alignment.centerLeft,
                      ),
                      child: Text(text, style: const TextStyle(fontSize: 13)),
                    ),
                  );
                },
              )),
            ] else ...[
              // Result Screen
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.nightObsidian,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.neonEmerald.withValues(alpha: 0.4)),
                ),
                child: Column(
                  children: [
                    const Text('🎉', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 8),
                    Text(
                      'Sync Score: ${(score / questions.length * 100).toInt()}%!',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.neonEmerald,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      score >= 2
                          ? 'Certified Lagos Match! Your vibes are perfectly aligned!'
                          : 'Opposites attract! There is plenty to discuss on your next date!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: AppTheme.textLight),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.darkShimmer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🎁 Earned: ', style: TextStyle(color: AppTheme.textMuted)),
                          Text(
                            '+${score * 20} 🪙 & +${score * 15} XP',
                            style: const TextStyle(
                              color: AppTheme.lagosYellow,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.brandCoral,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Back to Chat', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
