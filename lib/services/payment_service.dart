import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'game_state.dart';
import 'local_persistence_service.dart';
import 'sound_service.dart';
import 'supabase_service.dart';

enum PaymentGatewayType {
  paystack, // Paystack (Card, Instant Bank Transfer, USSD, OPay) - 98.5% profit
  inAppPurchase, // Apple Pay / Google Play Billing - 85% profit
}

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  /// Determines whether Paystack should be the primary checkout gateway
  /// (Web PWA, desktop, or sideloaded Android APK)
  bool get isPaystackPreferred {
    if (kIsWeb) return true;
    // In production, direct APK distribution flag can be passed or platform inspected
    return true; 
  }

  /// Processes credit bundle purchase
  Future<bool> processBundlePurchase({
    required CreditBundle bundle,
    required GameState gameState,
    required PaymentGatewayType gateway,
    String? userEmail,
  }) async {
    try {
      // Simulate gateway latency / handshake
      await Future.delayed(const Duration(milliseconds: 1200));

      // Credit the user's wallet with base + bonus credits
      final int totalCredited = bundle.totalCredits;
      gameState.user.walletBalance += totalCredited;
      gameState.user.xp += (bundle.priceNaira ~/ 10); // +1 XP per ₦10 spent

      // Sound & Haptic celebration
      await SoundService().playCoinEarned();

      // Persist locally
      await LocalPersistenceService().saveUser(gameState.user);

      // Persist to Supabase if available
      final supabaseUser = SupabaseService().currentUser;
      final client = SupabaseService().client;
      if (supabaseUser != null && client != null) {
        try {
          await client.from('users').update({
            'wallet_balance': gameState.user.walletBalance,
            'current_xp': gameState.user.xp,
          }).eq('id', supabaseUser.id);

          // Log payment transaction audit
          await client.from('payment_transactions').insert({
            'user_id': supabaseUser.id,
            'bundle_id': bundle.id,
            'credits_granted': totalCredited,
            'amount_naira': bundle.priceNaira,
            'gateway': gateway.name,
            'status': 'completed',
          });
        } catch (_) {
          // Non-blocking if table doesn't exist yet
        }
      }

      gameState.notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[PaymentService] Purchase error: $e');
      return false;
    }
  }
}
