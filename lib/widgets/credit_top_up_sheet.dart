import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/game_state.dart';
import '../services/payment_service.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';

/// Modal bottom sheet allowing users to top up Spark Credits (🪙)
/// Supports Paystack (Bank Transfer / USSD / Card) and In-App Purchase
class CreditTopUpSheet extends StatefulWidget {
  final GameState gameState;

  const CreditTopUpSheet({
    super.key,
    required this.gameState,
  });

  /// Convenient static helper to show the top-up sheet anywhere in the app
  static Future<void> show(BuildContext context, GameState gameState) {
    SoundService().playButtonTap();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CreditTopUpSheet(gameState: gameState),
    );
  }

  @override
  State<CreditTopUpSheet> createState() => _CreditTopUpSheetState();
}

class _CreditTopUpSheetState extends State<CreditTopUpSheet> {
  CreditBundle _selectedBundle = CreditBundle.defaultBundles[1]; // Default to Flexer (Popular)
  PaymentGatewayType _selectedGateway = PaymentGatewayType.paystack;
  bool _isProcessing = false;

  Future<void> _handleBuy() async {
    if (_isProcessing) return;

    SoundService().playButtonTap();
    setState(() {
      _isProcessing = true;
    });

    final success = await PaymentService().processBundlePurchase(
      bundle: _selectedBundle,
      gameState: widget.gameState,
      gateway: _selectedGateway,
    );

    if (!mounted) return;
    setState(() {
      _isProcessing = false;
    });

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.neonEmerald,
          content: Row(
            children: [
              const Text('🎉 ', style: TextStyle(fontSize: 18)),
              Expanded(
                child: Text(
                  'Success! +${_selectedBundle.totalCredits} Spark Credits added to your wallet! (Now: ${widget.gameState.user.walletBalance} 🪙)',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Payment failed or cancelled. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.gameState.user;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF161618),
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(
          top: BorderSide(color: Color(0xFF2C2C2E), width: 0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.lagosYellow.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text('🪙', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TOP UP SPARK CREDITS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                        Text(
                          'Current Balance: ${user.walletBalance} 🪙',
                          style: const TextStyle(
                            color: AppTheme.neonEmerald,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Web Bonus Callout Banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.electricPink.withValues(alpha: 0.15),
                          AppTheme.purpleRoyal.withValues(alpha: 0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.electricPink.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Text('🌐', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'PAYSTACK WEB TOP-UP ADVANTAGE',
                                style: TextStyle(
                                  color: AppTheme.electricPink,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Get up to 25% MORE bonus credits using Paystack direct bank transfer & USSD instead of high app store fees!',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                  const Text(
                    'SELECT CREDIT BUNDLE',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Bundles Grid
                  ...CreditBundle.defaultBundles.map((bundle) {
                    final isSelected = _selectedBundle.id == bundle.id;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF242426)
                            : const Color(0xFF1C1C1E),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.brandCoral
                              : const Color(0xFF2C2C2E),
                          width: isSelected ? 1.5 : 0.5,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          SoundService().playButtonTap();
                          setState(() {
                            _selectedBundle = bundle;
                          });
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              // Icon badge
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.lagosYellow.withValues(alpha: 0.2)
                                      : const Color(0xFF242E46),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    bundle.icon,
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),

                              // Title & credits count
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      spacing: 6,
                                      runSpacing: 2,
                                      children: [
                                        Text(
                                          bundle.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        if (bundle.isPopular || bundle.isBestValue)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: bundle.isPopular
                                                  ? Colors.amber.withValues(alpha: 0.25)
                                                  : AppTheme.neonEmerald.withValues(alpha: 0.25),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(
                                                color: bundle.isPopular
                                                    ? AppTheme.lagosYellow
                                                    : AppTheme.neonEmerald,
                                                width: 0.8,
                                              ),
                                            ),
                                            child: Text(
                                              bundle.tag,
                                              style: TextStyle(
                                                color: bundle.isPopular
                                                    ? AppTheme.lagosYellow
                                                    : AppTheme.neonEmerald,
                                                fontSize: 9,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Wrap(
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      spacing: 6,
                                      runSpacing: 2,
                                      children: [
                                        Text(
                                          '🪙 ${bundle.baseCredits} Credits',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (bundle.bonusCredits > 0)
                                          Text(
                                            '+${bundle.bonusCredits} BONUS',
                                            style: const TextStyle(
                                              color: AppTheme.neonEmerald,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Price button
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.lagosYellow
                                      : const Color(0xFF242E46),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  bundle.formattedNaira,
                                  style: TextStyle(
                                    color: isSelected ? Colors.black : Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 16),
                  const Text(
                    'PAYMENT METHOD',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Gateway option 1: Paystack
                  _gatewayOption(
                    gateway: PaymentGatewayType.paystack,
                    title: 'Paystack (Recommended ⚡)',
                    subtitle: 'Instant Bank Transfer, USSD (*737#, *901#), Debit Card, OPay',
                    tag: 'Lowest 1.5% Fee',
                    icon: '🏦',
                  ),

                  const SizedBox(height: 8),

                  // Gateway option 2: App Store
                  _gatewayOption(
                    gateway: PaymentGatewayType.inAppPurchase,
                    title: 'Google Play / Apple Pay',
                    subtitle: 'Standard in-app store billing',
                    tag: 'App Store',
                    icon: '📱',
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Bottom Action Bar (Apple Pay style pill button)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
              color: Color(0xFF161618),
              border: Border(top: BorderSide(color: Color(0xFF2C2C2E), width: 0.5)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _handleBuy,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.brandCoral, // Apple Signature Blue
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('⚡ ', style: TextStyle(fontSize: 16)),
                          Text(
                            'CONFIRM & BUY ${_selectedBundle.totalCredits} CREDITS (${_selectedBundle.formattedNaira})',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gatewayOption({
    required PaymentGatewayType gateway,
    required String title,
    required String subtitle,
    required String tag,
    required String icon,
  }) {
    final isSelected = _selectedGateway == gateway;

    return InkWell(
      onTap: () {
        SoundService().playButtonTap();
        setState(() {
          _selectedGateway = gateway;
        });
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E2A44) : const Color(0xFF131826),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.neonEmerald : const Color(0xFF242E46),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 2,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.neonEmerald.withValues(alpha: 0.2)
                              : Colors.white10,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: isSelected ? AppTheme.neonEmerald : Colors.white60,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppTheme.neonEmerald : Colors.white24,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
