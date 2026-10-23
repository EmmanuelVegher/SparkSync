import 'package:flutter/material.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

class DailyGachaDialog extends StatefulWidget {
  final GameState gameState;

  const DailyGachaDialog({super.key, required this.gameState});

  @override
  State<DailyGachaDialog> createState() => _DailyGachaDialogState();
}

class _DailyGachaDialogState extends State<DailyGachaDialog> {
  bool claimed = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.cardSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppTheme.lagosYellow, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎰', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 10),
            const Text(
              'Lagos Daily Hustle Stipend',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Every Lagos baller gets a daily allowance to fund their romantic dates and survive fuel expenses!',
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.nightObsidian,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Text('🪙', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 6),
                      Text(
                        '+120 Coins',
                        style: TextStyle(
                          color: AppTheme.lagosYellow,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text('⚡', style: TextStyle(fontSize: 20)),
                      SizedBox(width: 6),
                      Text(
                        '+35 Energy',
                        style: TextStyle(
                          color: AppTheme.neonEmerald,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: claimed
                    ? null
                    : () {
                        setState(() {
                          claimed = true;
                        });
                        widget.gameState.claimDailyGacha();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: AppTheme.neonEmerald,
                            content: Text('Claimed +120 Coins & +35 Energy! Go flex! 🍾'),
                          ),
                        );
                        Navigator.pop(context);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lagosYellow,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  claimed ? 'Claimed Today' : 'Claim Daily Bonus',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
