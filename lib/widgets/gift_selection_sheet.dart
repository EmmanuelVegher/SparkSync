import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

class GiftSelectionSheet extends StatelessWidget {
  final MatchProfile match;
  final GameState gameState;

  const GiftSelectionSheet({
    super.key,
    required this.match,
    required this.gameState,
  });

  @override
  Widget build(BuildContext context) {
    final giftItems = gameState.shopItems
        .where((item) => item.category == ItemCategory.romanticGift)
        .toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Send Gift to ${match.name}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Stage: ${match.relationshipStage.displayName}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.brandCoral,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.darkShimmer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Text('🪙', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 4),
                      Text(
                        '${gameState.user.walletBalance}',
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
            const SizedBox(height: 16),
            const Text(
              'Sending gifts unlocks higher relationship stages, special couple titles, and exclusive chats!',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: giftItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final gift = giftItems[index];
                  final ownedCount = gameState.inventory[gift.id] ?? 0;
                  final canAfford = gameState.user.walletBalance >= gift.tokenCost || ownedCount > 0;

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.nightObsidian,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppTheme.cardSurface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(gift.emoji, style: const TextStyle(fontSize: 26)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                gift.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                gift.effectDescription,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.neonEmerald,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                ownedCount > 0
                                    ? 'In backpack: $ownedCount'
                                    : 'Cost: ${gift.tokenCost} 🪙',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: ownedCount > 0 ? AppTheme.skyCyan : AppTheme.lagosYellow,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: canAfford
                              ? () {
                                  final success = gameState.sendGiftToMatch(match, gift);
                                  Navigator.pop(context);
                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: AppTheme.brandCoral,
                                        content: Text('Sent ${gift.name} ${gift.emoji} to ${match.name}!'),
                                      ),
                                    );
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.brandCoral,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          ),
                          child: Text(ownedCount > 0 ? 'Send' : 'Buy & Send'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
