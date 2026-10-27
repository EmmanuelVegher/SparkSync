import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

/// Service that handles cross-platform viral social sharing for Sparksync karaoke & acapella performances
class SocialShareService {
  static final SocialShareService _instance = SocialShareService._internal();
  factory SocialShareService() => _instance;
  SocialShareService._internal();

  /// Launches the native OS share sheet (WhatsApp Status, TikTok, Instagram Stories, etc.)
  Future<bool> sharePerformance({
    String? localVideoPath,
    required String performerName,
    required String trackTitle,
    required String trackArtist,
    required String rankName,
    required int totalVotes,
    required int xpEarned,
    bool isAcapella = false,
  }) async {
    final modeLabel = isAcapella ? 'Saturday Acapella Showdown' : 'Live Karaoke Lounge';

    final shareCaptionText = '''
Yo! I just went live on Sparksync for the $modeLabel! 🎤💥

Track: $trackTitle - $trackArtist
Rank: $rankName • Received 🗳️ $totalVotes audience votes (+$xpEarned XP)!

Download Sparksync to join the lounge, catch my sets, and vote for me next Saturday! ⚡
'''.trim();

    try {
      if (localVideoPath != null && localVideoPath.isNotEmpty) {
        final file = File(localVideoPath);
        if (await file.exists()) {
          final result = await Share.shareXFiles(
            [XFile(file.path)],
            text: shareCaptionText,
            subject: 'Sparksync Performance Challenge Showcase: $trackTitle',
          );
          return result.status == ShareResultStatus.success;
        }
      }

      // Fallback: share rich text and link if file path isn't local on disk
      final result = await Share.share(
        shareCaptionText,
        subject: 'Sparksync Performance Showcase: $trackTitle',
      );
      return result.status == ShareResultStatus.success;
    } catch (e) {
      debugPrint('[SocialShareService] Error sharing performance: $e');
      return false;
    }
  }

  /// Copies viral WhatsApp Status caption to clipboard
  String generateWhatsAppStatusCaption({
    required String performerName,
    required String trackTitle,
    required int totalVotes,
    required String rankName,
  }) {
    return '🔥 Just hit the Sparksync Lounge mic singing "$trackTitle"! Got $totalVotes audience votes on the Judgement Deck! 👑 Rank: $rankName. Tap in: sparksync.app/lounge ⚡';
  }
}
