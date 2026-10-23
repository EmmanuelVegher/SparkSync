import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/game_state.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';

class CheckoutScreen extends StatefulWidget {
  final ShopItem item;
  final GameState gameState;

  const CheckoutScreen({
    super.key,
    required this.item,
    required this.gameState,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _autoEquip = true;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final user = widget.gameState.user;
    final int userWalletBalance = user.walletBalance;
    final int itemPrice = widget.item.tokenCost;
    final int remainingBalance = userWalletBalance - itemPrice;
    final bool canAfford = remainingBalance >= 0;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E), // Deep Cyber Midnight Space
      appBar: AppBar(
        backgroundColor: const Color(0xFF16162A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'SHOP CHECKOUT',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF252545),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.lagosYellow.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Text('🪙 ', style: TextStyle(fontSize: 14)),
                  Text(
                    '$userWalletBalance Coins',
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '🛒 CONFIRM YOUR PURCHASE',
              style: TextStyle(
                color: Colors.grey,
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),

            // 3D/2D Animated Visual Preview Box
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8A2387), Color(0xFFE94057), Color(0xFFF27121)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withValues(alpha: 0.35),
                    blurRadius: 24,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 18),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.item.emoji, style: const TextStyle(fontSize: 38)),
                      const SizedBox(height: 8),
                      Text(
                        '⭐ ${widget.item.name.toUpperCase()} ⭐',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          letterSpacing: 0.8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),

            Text(
              widget.item.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              '${widget.item.category.name.toUpperCase()} • ${widget.item.rarity}',
              style: const TextStyle(
                color: AppTheme.electricPink,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 20),
            const Divider(color: Color(0xFF252545)),
            const SizedBox(height: 10),

            // Description Area
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'ITEM DESCRIPTION',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.item.description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ),
            if (widget.item.effectDescription.isNotEmpty) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '⚡ Effect: ${widget.item.effectDescription}',
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),
            const Divider(color: Color(0xFF252545)),
            const SizedBox(height: 10),

            // Financial Breakdown Ledger Widget
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF16162A),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF252545)),
              ),
              child: Column(
                children: [
                  _buildLedgerRow('Current Balance', '$userWalletBalance 🪙', Colors.white),
                  const SizedBox(height: 10),
                  _buildLedgerRow('Item Price', '-$itemPrice 🪙', Colors.redAccent),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(color: Color(0xFF252545)),
                  ),
                  _buildLedgerRow(
                    'Remaining Balance',
                    '$remainingBalance 🪙',
                    canAfford ? Colors.greenAccent : Colors.red,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Auto-Equip Switch Toggle Feature
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Auto-Equip After Purchase',
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Immediately show this item in your profile and chat',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
              ),
              value: _autoEquip,
              activeThumbColor: Colors.cyanAccent,
              inactiveTrackColor: Colors.grey.shade800,
              onChanged: (bool value) {
                setState(() {
                  _autoEquip = value;
                });
              },
            ),
            const SizedBox(height: 24),

            // Execution Transaction Button Logic
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: canAfford ? const Color(0xFF6C63FF) : Colors.grey.shade800,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade900,
                  disabledForegroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: canAfford ? 6 : 0,
                  shadowColor: const Color(0xFF6C63FF).withValues(alpha: 0.5),
                ),
                onPressed: (!canAfford || _isProcessing)
                    ? null
                    : () async {
                        setState(() {
                          _isProcessing = true;
                        });
                        final ok = await widget.gameState.purchaseCustomizationItem(
                          widget.item,
                          autoEquip: _autoEquip,
                        );
                        setState(() {
                          _isProcessing = false;
                        });

                        if (!context.mounted) return;

                        if (ok) {
                          SoundService().playCoinEarned();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppTheme.neonEmerald,
                              duration: const Duration(seconds: 3),
                              content: Text(
                                '🎉 Unlocked "${widget.item.name}"! +100 XP added to your Rank.',
                                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                          Navigator.of(context).pop();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.redAccent,
                              content: Text('Transaction failed. Check your balance.'),
                            ),
                          );
                        }
                      },
                child: _isProcessing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        canAfford ? 'CONFIRM & DEDUCT $itemPrice CREDITS' : 'INSUFFICIENT CREDITS',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 12),

            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_rounded, size: 14, color: AppTheme.textMuted),
                SizedBox(width: 6),
                Text(
                  'Secured via Sparksync Vault (PostgreSQL RPC)',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLedgerRow(String title, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }
}
