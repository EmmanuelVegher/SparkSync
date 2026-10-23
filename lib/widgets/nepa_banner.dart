import 'package:flutter/material.dart';
import '../services/game_state.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';

class NepaBanner extends StatelessWidget {
  final GameState gameState;

  const NepaBanner({super.key, required this.gameState});

  @override
  Widget build(BuildContext context) {
    final event = gameState.activeEvent;
    if (event == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: event.isReward
            ? AppTheme.neonEmerald.withOpacity(0.15)
            : AppTheme.brandCoral.withOpacity(0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: event.isReward
              ? AppTheme.neonEmerald.withOpacity(0.5)
              : AppTheme.brandCoral.withOpacity(0.6),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(event.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  event.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: event.isReward ? AppTheme.neonEmerald : AppTheme.lagosYellow,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18, color: AppTheme.textMuted),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => gameState.resolveActiveEvent(false),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            event.description,
            style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (event.id == 'nepa_drop') {
                      SoundService().playNepaOn();
                    } else if (event.isReward) {
                      SoundService().playCoinEarned();
                    }
                    gameState.resolveActiveEvent(true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: event.isReward ? AppTheme.neonEmerald : AppTheme.brandCoral,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    event.actionText,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => gameState.resolveActiveEvent(false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textMuted,
                  side: const BorderSide(color: AppTheme.cardBorder),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Ignore', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
