import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  // Supabase Configuration
  static const String defaultUrl = 'https://ngcbjbscuegjdhmrmlvc.supabase.co';
  static const String defaultAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5nY2JqYnNjdWVnamRobXJtbHZjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTI1Mzk5ODcsImV4cCI6MjEwODExNTk4N30.j4Ckmyx9cecl6SneDWIVBLjw2PoHgdZuBflfDE_u33A';

  // Web Client IDs for native Google Sign-In with ID Token
  static String? googleWebClientId =
      '1004650214828-579ge5r9qqds8dik89p01c1ahem0h5v2.apps.googleusercontent.com';
  static const String googleAltClientId =
      '1004650214828-qvhlka9vq0ejldj1untgg5eeqm2k1f03.apps.googleusercontent.com';

  bool _isInitialized = false;
  bool get isConfigured =>
      _isInitialized &&
      !defaultUrl.contains('your-project') &&
      defaultAnonKey.isNotEmpty;

  SupabaseClient? get client => _isInitialized ? Supabase.instance.client : null;

  Future<void> initialize({String? url, String? anonKey}) async {
    final targetUrl = url ?? defaultUrl;
    final targetKey = anonKey ?? defaultAnonKey;

    if (targetUrl.contains('your-project') || targetKey == 'your-anon-key') {
      debugPrint('[SupabaseService] Demo/Mock mode active. Real Supabase URL not configured.');
      _isInitialized = false;
      return;
    }

    try {
      await Supabase.initialize(
        url: targetUrl,
        anonKey: targetKey,
      );
      _isInitialized = true;
      debugPrint('[SupabaseService] Successfully connected to Supabase: $targetUrl');
    } catch (e) {
      debugPrint('[SupabaseService] Error initializing Supabase: $e');
      _isInitialized = false;
    }
  }

  // Authentication Methods
  User? get currentUser => client?.auth.currentUser;

  Future<AuthResponse?> signUpWithEmail({
    required String email,
    required String password,
    required String username,
    String neighborhood = 'Lekki Phase 1',
  }) async {
    if (!isConfigured) return null;
    try {
      final res = await client!.auth.signUp(
        email: email,
        password: password,
        data: {'username': username, 'neighborhood': neighborhood},
      );

      if (res.user != null) {
        try {
          // Create or update matching public profile
          await client!.from('profiles').upsert(
            {
              'id': res.user!.id,
              'username': username,
              'neighborhood': neighborhood,
              'wallet_balance': 0,
              'energy': 100,
              'level': 1,
            },
            onConflict: 'id',
          );
        } catch (profileErr) {
          debugPrint(
            '[SupabaseService] Profile upsert notice (handled by DB trigger or awaiting confirmation): $profileErr',
          );
          // Do not rethrow if auth.signUp succeeded, as profile trigger on auth.users handles creation
        }
      }
      return res;
    } catch (e) {
      debugPrint('[SupabaseService] Sign up error: $e');
      rethrow;
    }
  }

  Future<AuthResponse?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (!isConfigured) return null;
    try {
      final res = await client!.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return res;
    } catch (e) {
      debugPrint('[SupabaseService] Sign in error: $e');
      rethrow;
    }
  }

  // Native Google Sign-In with ID Token (No browser redirect)
  Future<AuthResponse?> signInWithGoogleNative({String? serverClientId}) async {
    if (!isConfigured) return null;
    try {
      final candidates = [
        serverClientId,
        googleWebClientId,
        googleAltClientId,
      ].whereType<String>().toSet().toList();

      for (final cid in candidates) {
        final GoogleSignIn googleSignIn = GoogleSignIn(
          serverClientId: cid,
          scopes: const ['email', 'profile'],
        );

        // Clear stale local token cache so Google Play Services requests fresh OpenID token
        try {
          await googleSignIn.signOut();
        } catch (_) {}

        final googleUser = await googleSignIn.signIn();
        if (googleUser == null) return null; // Cancelled by user

        final googleAuth = await googleUser.authentication;
        final idToken = googleAuth.idToken;
        final accessToken = googleAuth.accessToken;

        debugPrint('[SupabaseService] Testing serverClientId ($cid): idToken=${idToken != null ? "found (${idToken.length} chars)" : "null"}');

        if (idToken != null) {
          googleWebClientId = cid; // Save the working client ID
          final response = await client!.auth.signInWithIdToken(
            provider: OAuthProvider.google,
            idToken: idToken,
            accessToken: accessToken,
          );
          return response;
        }
      }

      throw Exception(
          'Google ID token returned null. Ensure an Android OAuth Client ID with package "com.terkage.sparksync" and SHA-1 is created in Google Cloud Console, and "Skip nonce checks" is enabled in Supabase.');
    } catch (e) {
      debugPrint('[SupabaseService] Native Google Sign-In error: $e');
      rethrow;
    }
  }

  // OAuth & Free Alternative Sign-In Methods (Web / Browser fallback)
  Future<bool> signInWithGoogle() async {
    if (!isConfigured) return false;
    try {
      final res = await client!.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'sparksync://login-callback',
      );
      return res;
    } catch (e) {
      debugPrint('[SupabaseService] Google sign-in error: $e');
      rethrow;
    }
  }

  Future<bool> signInWithGithub() async {
    if (!isConfigured) return false;
    try {
      final res = await client!.auth.signInWithOAuth(
        OAuthProvider.github,
        redirectTo: kIsWeb ? null : 'sparksync://login-callback',
      );
      return res;
    } catch (e) {
      debugPrint('[SupabaseService] GitHub sign-in error: $e');
      rethrow;
    }
  }

  Future<bool> signInWithDiscord() async {
    if (!isConfigured) return false;
    try {
      final res = await client!.auth.signInWithOAuth(
        OAuthProvider.discord,
        redirectTo: kIsWeb ? null : 'sparksync://login-callback',
      );
      return res;
    } catch (e) {
      debugPrint('[SupabaseService] Discord sign-in error: $e');
      rethrow;
    }
  }

  Future<User?> signInAnonymously({String? username, String? neighborhood}) async {
    if (!isConfigured) return null;
    try {
      final response = await client!.auth.signInAnonymously(
        data: {
          if (username != null) 'username': username,
          if (neighborhood != null) 'neighborhood': neighborhood,
        },
      );
      return response.user;
    } catch (e) {
      debugPrint('[SupabaseService] Anonymous auth error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    if (!isConfigured) return;
    try {
      await client!.auth.signOut();
      try {
        final googleSignIn = GoogleSignIn();
        if (await googleSignIn.isSignedIn()) {
          await googleSignIn.signOut();
        }
      } catch (_) {}
    } catch (e) {
      debugPrint('[SupabaseService] Sign out error: $e');
    }
  }

  // Profile Sync
  Future<Map<String, dynamic>?> fetchProfile(String userId) async {
    if (!isConfigured) return null;
    try {
      final res = await client!
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return res;
    } catch (e) {
      debugPrint('[SupabaseService] Fetch profile error: $e');
      return null;
    }
  }

  // Fetch live active user count from Supabase
  Future<int> fetchLiveActiveUserCount({String? city}) async {
    if (!isConfigured) return 1;
    try {
      var query = client!.from('profiles').select('id');
      if (city != null && city.isNotEmpty) {
        query = query.ilike('neighborhood', '%$city%');
      }
      final res = await query;
      final count = (res as List).length;
      return count == 0 ? 1 : count;
    } catch (e) {
      debugPrint('[SupabaseService] fetchLiveActiveUserCount error: $e');
      return 1;
    }
  }

  // Fetch real registered profiles from Supabase
  Future<List<Map<String, dynamic>>> fetchLiveProfiles({String? city}) async {
    if (!isConfigured) return [];
    try {
      final currentUserId = currentUser?.id;
      var query = client!.from('profiles').select();
      if (currentUserId != null) {
        query = query.neq('id', currentUserId);
      }
      final res = await query;
      return List<Map<String, dynamic>>.from(res as List);
    } catch (e) {
      debugPrint('[SupabaseService] fetchLiveProfiles error: $e');
      return [];
    }
  }

  // Atomic Hustle Completion via RPC
  Future<bool> completeHustleRPC({
    required String userId,
    required int energyCost,
    required int coinReward,
    required String jobId,
  }) async {
    if (!isConfigured) return true;
    try {
      final res = await client!.rpc('complete_hustle', params: {
        'p_user_id': userId,
        'p_energy_cost': energyCost,
        'p_coin_reward': coinReward,
        'p_job_id': jobId,
      });
      return res['success'] == true;
    } catch (e) {
      debugPrint('[SupabaseService] complete_hustle RPC error: $e');
      return false;
    }
  }

  // Atomic Gift Sending via RPC
  Future<Map<String, dynamic>?> sendGiftRPC({
    required String senderId,
    required String matchId,
    required String itemId,
  }) async {
    if (!isConfigured) return null;
    try {
      final res = await client!.rpc('send_gift_to_match', params: {
        'p_sender_id': senderId,
        'p_match_id': matchId,
        'p_item_id': itemId,
      });
      return Map<String, dynamic>.from(res);
    } catch (e) {
      debugPrint('[SupabaseService] send_gift_to_match RPC error: $e');
      return null;
    }
  }

  // Real-time Venue Messages Stream
  Stream<List<Map<String, dynamic>>> streamVenueMessages(String venueId) {
    if (!isConfigured) return const Stream.empty();
    return client!
        .from('venue_messages')
        .stream(primaryKey: ['id'])
        .eq('venue_id', venueId)
        .order('created_at', ascending: true);
  }

  // Real-time Direct Messages Stream
  Stream<List<Map<String, dynamic>>> streamMatchMessages(String matchId) {
    if (!isConfigured) return const Stream.empty();
    return client!
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('match_id', matchId)
        .order('created_at', ascending: true);
  }

  // Send Direct Message
  Future<bool> sendDirectMessage({
    required String matchId,
    required String senderId,
    required String content,
  }) async {
    if (!isConfigured) return true;
    try {
      await client!.from('messages').insert({
        'match_id': matchId,
        'sender_id': senderId,
        'content': content,
      });
      return true;
    } catch (e) {
      debugPrint('[SupabaseService] sendDirectMessage error: $e');
      return false;
    }
  }

  // SparkSync Mall Purchase Customization RPC
  Future<Map<String, dynamic>?> purchaseCustomizationRPC({
    required String userId,
    required String itemId,
    bool autoEquip = true,
  }) async {
    if (!isConfigured) return null;
    try {
      final res = await client!.rpc('purchase_customization_item', params: {
        'p_user_id': userId,
        'p_item_id': itemId,
        'p_auto_equip': autoEquip,
      });
      if (res is List && res.isNotEmpty) {
        return Map<String, dynamic>.from(res.first as Map);
      } else if (res is Map) {
        return Map<String, dynamic>.from(res);
      }
      return null;
    } catch (e) {
      debugPrint('[SupabaseService] purchase_customization_item RPC error: $e');
      return null;
    }
  }

  // Real-time SparkSync Room Messages Stream
  Stream<List<Map<String, dynamic>>> streamRoomMessages(String roomId) {
    if (!isConfigured) return const Stream.empty();
    return client!
        .from('room_messages')
        .stream(primaryKey: ['id'])
        .eq('room_id', roomId)
        .order('created_at', ascending: true);
  }

  // Send SparkSync Public Chatroom Message
  Future<bool> sendRoomMessage({
    required String roomId,
    required String senderId,
    required String senderName,
    required String senderAvatar,
    required String senderRank,
    required String text,
    bool hasNeonGlow = false,
    bool isAnnouncement = false,
  }) async {
    if (!isConfigured) return true;
    try {
      await client!.from('room_messages').insert({
        'room_id': roomId,
        'sender_id': senderId,
        'sender_name': senderName,
        'sender_avatar': senderAvatar,
        'sender_rank': senderRank,
        'content': text,
        'has_neon_glow': hasNeonGlow,
        'is_announcement': isAnnouncement,
      });
      return true;
    } catch (e) {
      debugPrint('[SupabaseService] sendRoomMessage error: $e');
      return false;
    }
  }

  // Sever Match Connection & Anti-Ghosting RPC
  Future<Map<String, dynamic>> severMatchConnectionRPC({
    required String userId,
    required String targetId,
    required String actionType, // 'unmatch' or 'block'
    String reason = 'general',
  }) async {
    if (!isConfigured) {
      return {'success': true, 'message': 'Severed locally (offline mode)'};
    }
    try {
      final res = await client!.rpc('sever_match_connection', params: {
        'p_user_id': userId,
        'p_target_id': targetId,
        'p_action_type': actionType,
        'p_reason': reason,
      });

      if (res is List && res.isNotEmpty) {
        return Map<String, dynamic>.from(res.first);
      } else if (res is Map) {
        return Map<String, dynamic>.from(res);
      }
      return {'success': true, 'message': 'Connection severed successfully'};
    } catch (e) {
      debugPrint('[SupabaseService] sever_match_connection RPC error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Fetch blacklisted profile IDs for current user
  Future<Set<String>> fetchBlacklistedIds(String userId) async {
    if (!isConfigured) return {};
    try {
      final res = await client!
          .from('profile_blacklist')
          .select('target_id')
          .eq('initiator_id', userId);
      return (res as List).map((r) => r['target_id'].toString()).toSet();
    } catch (e) {
      debugPrint('[SupabaseService] fetchBlacklistedIds error: $e');
      return {};
    }
  }

  // Daily Gacha Spin Transaction RPC
  Future<Map<String, dynamic>> spinDailyGachaBoxRPC(String userId) async {
    if (!isConfigured) {
      return {
        'success': false,
        'message': 'Supabase not configured (offline mode)',
      };
    }
    try {
      final res = await client!.rpc('spin_daily_gacha_box', params: {
        'p_user_id': userId,
      });

      if (res is List && res.isNotEmpty) {
        return Map<String, dynamic>.from(res.first);
      } else if (res is Map) {
        return Map<String, dynamic>.from(res);
      }
      return {'success': false, 'message': 'Empty response from RPC'};
    } catch (e) {
      debugPrint('[SupabaseService] spin_daily_gacha_box RPC error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Upload Biometric Portrait / Avatar to Supabase Storage
  Future<String?> uploadAvatarToStorage({
    required String userId,
    required Uint8List imageBytes,
    required String filename,
  }) async {
    if (!isConfigured || client == null) return null;
    try {
      final filePath = 'users/$userId/$filename';
      await client!.storage.from('avatars').uploadBinary(
            filePath,
            imageBytes,
            fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
          );
      final publicUrl = client!.storage.from('avatars').getPublicUrl(filePath);
      debugPrint('[SupabaseService] Uploaded avatar to Supabase Storage: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('[SupabaseService] uploadAvatarToStorage notice (using fallback): $e');
      return null;
    }
  }

  // Sync Verified Avatar & NVIDIA traits to Supabase Profile for multi-device parity
  Future<bool> syncVerifiedAvatar({
    required String userId,
    required String avatarEmoji,
    required String photoUrl,
    Map<String, dynamic>? avatarProfile,
    String? vibeTitle,
    int? xp,
    int? walletBalance,
  }) async {
    if (!isConfigured || client == null) return true;
    try {
      final updatePayload = <String, dynamic>{
        'is_verified': true,
        'avatar_emoji': avatarEmoji,
        'verified_photo_url': photoUrl,
        'verified_at': DateTime.now().toIso8601String(),
        if (xp != null) 'xp': xp,
        if (walletBalance != null) 'wallet_balance': walletBalance,
        if (avatarProfile != null) 'avatar_feature_profile': avatarProfile,
        if (vibeTitle != null && vibeTitle.isNotEmpty) 'title': vibeTitle,
      };
      await client!.from('profiles').update(updatePayload).eq('id', userId);
      debugPrint('[SupabaseService] Successfully synced verified avatar to Supabase');
      return true;
    } catch (e) {
      debugPrint('[SupabaseService] syncVerifiedAvatar error: $e');
      return false;
    }
  }
}
