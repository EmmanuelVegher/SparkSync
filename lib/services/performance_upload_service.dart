import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import 'supabase_service.dart';

/// Handles uploading performance clips to Supabase Storage bucket ('performance_clips')
/// and writing rows to 'profile_saved_performances' or local profile state.
class PerformanceUploadService {
  static final PerformanceUploadService _instance = PerformanceUploadService._internal();
  factory PerformanceUploadService() => _instance;
  PerformanceUploadService._internal();

  /// Saves a performance to Supabase and returns a ProfileSavedPerformance object
  Future<ProfileSavedPerformance?> saveClipToUserProfile({
    String? localCachedFilePath,
    required String userId,
    required String username,
    required String userAvatar,
    required String trackTitle,
    required String trackArtist,
    required int totalVotes,
    required int xpEarned,
    required String rankTitle,
    bool isAcapella = false,
    Map<String, int>? voteBreakdown,
  }) async {
    String? publicUrl;

    // Check if Supabase client is configured and authenticated
    if (SupabaseService().isConfigured) {
      try {
        final client = Supabase.instance.client;
        final currentUser = client.auth.currentUser;

        if (currentUser != null && localCachedFilePath != null && localCachedFilePath.isNotEmpty) {
          final file = File(localCachedFilePath);
          if (await file.exists()) {
            final timestampId = DateTime.now().millisecondsSinceEpoch;
            final targetStoragePath = '${currentUser.id}/clip_$timestampId.mp4';

            // Upload file to 'performance_clips' bucket
            await client.storage.from('performance_clips').upload(
                  targetStoragePath,
                  file,
                  fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
                );

            publicUrl = client.storage.from('performance_clips').getPublicUrl(targetStoragePath);
          }
        }

        // Write row into 'profile_saved_performances'
        if (currentUser != null) {
          await client.from('profile_saved_performances').insert({
            'user_id': currentUser.id,
            'track_title': trackTitle,
            'track_artist': trackArtist,
            'video_storage_url': publicUrl ?? '',
            'received_votes_count': totalVotes,
            'is_acapella': isAcapella,
          });
        }
      } catch (e) {
        debugPrint('[PerformanceUploadService] Supabase upload warning: $e');
      }
    }

    final performance = ProfileSavedPerformance(
      id: 'perf_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      username: username,
      userAvatar: userAvatar,
      trackTitle: trackTitle,
      trackArtist: trackArtist,
      videoStorageUrl: publicUrl,
      localFilePath: localCachedFilePath,
      totalVotes: totalVotes,
      xpEarned: xpEarned,
      rankTitle: rankTitle,
      isAcapella: isAcapella,
      voteBreakdown: voteBreakdown,
      recordedAt: DateTime.now(),
    );

    return performance;
  }
}
