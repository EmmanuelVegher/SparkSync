import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import 'checkout_screen.dart';

class InventoryScreen extends StatefulWidget {
  final GameState gameState;

  const InventoryScreen({super.key, required this.gameState});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Row(
          children: [
            Text('🎒', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text('My Bag & Shop', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.brandCoral,
          labelColor: AppTheme.brandCoral,
          unselectedLabelColor: AppTheme.textMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'My Bag 🎒'),
            Tab(text: 'Shop 🛍️'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBackpackTab(),
          _buildMallTab(),
        ],
      ),
    );
  }

  Widget _buildBackpackTab() {
    final inventory = widget.gameState.inventory;
    final allItems = widget.gameState.shopItems;

    if (inventory.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('📦', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 14),
              const Text(
                'Your Bag is Empty',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Visit the Shop to buy energy items or gifts for your matches!',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: () => _tabController.animateTo(1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.brandCoral,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Go to Shop 🛍️'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.darkShimmer,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.cardBorder),
          ),
          child: Row(
            children: [
              const Text('⚡', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stamina Pool: ${widget.gameState.user.energy} / ${widget.gameState.user.maxEnergy}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Chop food items below to instantly refill your stamina for dates & hustles.',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        ...inventory.entries.map((entry) {
          final itemId = entry.key;
          final count = entry.value;
          final item = allItems.firstWhere((i) => i.id == itemId);
          final isEquipped = widget.gameState.user.equippedItemIds.contains(item.id);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isEquipped ? AppTheme.lagosYellow : AppTheme.cardBorder,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.nightObsidian,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(item.emoji, style: const TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppTheme.brandCoral.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'x$count',
                              style: const TextStyle(
                                color: AppTheme.brandCoral,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.effectDescription,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.neonEmerald,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                if (item.category == ItemCategory.consumable) ...[
                  ElevatedButton(
                    onPressed: () {
                      final ok = widget.gameState.useConsumable(item);
                      if (ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppTheme.neonEmerald,
                            content: Text('Chopped ${item.name}! +${item.energyBoost} ⚡ Energy!'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.neonEmerald,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Chop 😋', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ] else if (item.category == ItemCategory.fashion || item.category == ItemCategory.profileFlair) ...[
                  OutlinedButton(
                    onPressed: () => widget.gameState.toggleEquipItem(item.id),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isEquipped ? AppTheme.lagosYellow : Colors.white,
                      side: BorderSide(
                        color: isEquipped ? AppTheme.lagosYellow : AppTheme.cardBorder,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(isEquipped ? 'Equipped ✨' : 'Equip'),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.darkShimmer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Ready to Gift',
                      style: TextStyle(fontSize: 10, color: AppTheme.lagosYellow),
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildMallTab() {
    final allItems = widget.gameState.shopItems;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: allItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = allItems[index];
        final canAfford = widget.gameState.user.walletBalance >= item.tokenCost;

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => CheckoutScreen(
                  item: item,
                  gameState: widget.gameState,
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.cardSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: item.category == ItemCategory.profileFlair
                    ? Colors.cyanAccent.withValues(alpha: 0.4)
                    : AppTheme.cardBorder,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.nightObsidian,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(item.emoji, style: const TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              item.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: AppTheme.electricPink.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.rarity,
                              style: const TextStyle(
                                color: AppTheme.electricPink,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.description,
                        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.effectDescription,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.neonEmerald,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${item.tokenCost} 🪙',
                      style: const TextStyle(
                        color: AppTheme.lagosYellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => CheckoutScreen(
                              item: item,
                              gameState: widget.gameState,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: canAfford ? AppTheme.brandCoral : Colors.grey.shade800,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(canAfford ? 'Buy' : 'Need 🪙'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
