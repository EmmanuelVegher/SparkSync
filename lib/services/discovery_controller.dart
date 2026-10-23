import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DiscoveryProfileCard {
  final String id;
  final String username;
  final String avatarUrl;
  final String rankTitle;
  final int currentLevel;
  final String statusText;
  final double distanceKm;

  DiscoveryProfileCard({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.rankTitle,
    required this.currentLevel,
    required this.statusText,
    required this.distanceKm,
  });

  factory DiscoveryProfileCard.fromMap(Map<String, dynamic> map) {
    return DiscoveryProfileCard(
      id: map['candidate_id']?.toString() ?? '',
      username: map['username']?.toString() ?? 'Anonymous',
      avatarUrl: map['avatar_url']?.toString() ?? '😎',
      rankTitle: map['rank_title']?.toString() ?? 'Novice',
      currentLevel: (map['current_level'] as num?)?.toInt() ?? 1,
      statusText: map['status_text']?.toString() ?? 'Vibe with me!',
      distanceKm: (map['distance_km'] as num?)?.toDouble() ?? 2.5,
    );
  }
}

class DiscoveryController with ChangeNotifier {
  SupabaseClient? _client;
  List<DiscoveryProfileCard> swipeDeck = [];
  bool isLoading = false;

  DiscoveryController() {
    try {
      _client = Supabase.instance.client;
    } catch (_) {
      _client = null;
    }
  }

  /// Pulls ordered profile lists from the algorithmic stored procedure
  Future<void> loadDiscoveryDeck({
    required double userLat,
    required double userLng,
    required String targetGender,
  }) async {
    isLoading = true;
    notifyListeners();

    if (_client == null) {
      // Local fallback profiles if offline or unconfigured
      swipeDeck = [
        DiscoveryProfileCard(
          id: 'mock_1',
          username: 'Amaka_Vibes',
          avatarUrl: '✨',
          rankTitle: 'Senior',
          currentLevel: 3,
          statusText: 'Catch me at Landmark or vibe over Suya 🍢',
          distanceKm: 3.2,
        ),
        DiscoveryProfileCard(
          id: 'mock_2',
          username: 'Tunde_Dev',
          avatarUrl: '💻',
          rankTitle: 'Professional',
          currentLevel: 5,
          statusText: 'Building fintech by day, club DJ by night 🎧',
          distanceKm: 4.8,
        ),
      ];
      isLoading = false;
      notifyListeners();
      return;
    }

    try {
      final user = _client!.auth.currentUser;
      final viewerId = user?.id ?? '00000000-0000-0000-0000-000000000000';

      // Make API call to the algorithm stored procedure
      final List<dynamic> response = await _client!.rpc(
        'get_discovery_swipe_deck',
        params: {
          'p_viewer_id': viewerId,
          'p_viewer_gender': 'male',
          'p_target_gender': targetGender,
          'p_viewer_lat': userLat,
          'p_viewer_lng': userLng,
          'p_max_distance_km': 30.0,
        },
      );

      swipeDeck =
          response.map((data) => DiscoveryProfileCard.fromMap(data)).toList();
    } catch (e) {
      debugPrint("Discovery routine exception raised: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Processes active swipe interaction logs down to data rows
  Future<void> submitSwipeAction(String targetUserId, String action) async {
    // Action parameter strings passed: 'liked' or 'passed'
    if (swipeDeck.isNotEmpty) {
      swipeDeck.removeAt(0);
      notifyListeners();
    }

    if (_client == null) return;

    try {
      final user = _client!.auth.currentUser;
      if (user == null) return;

      // Upsert transaction interaction states safely inside database matrix
      await _client!.from('matches').insert({
        'user_one_id': user.id,
        'user_two_id': targetUserId,
        'interaction_status': action,
      });
    } catch (e) {
      debugPrint("Error writing swipe row payload context parameters: $e");
    }
  }
}
