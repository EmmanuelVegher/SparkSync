import 'package:flutter/foundation.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// Finds the best YouTube KARAOKE version for a song (no API key needed).
///
/// Strategy (in priority order):
///   1. Search "[title] [artist] karaoke" — finds karaoke versions with beat + lyrics on screen
///   2. Search "[title] [artist] lyrics video" — finds official lyric videos
///   3. Search "[title] [artist]" — general fallback
///
/// Within each search, prefers results whose title explicitly contains "karaoke".
class YoutubeService {
  static final YoutubeService _instance = YoutubeService._internal();
  factory YoutubeService() => _instance;
  YoutubeService._internal();

  final YoutubeExplode _yt = YoutubeExplode();

  // In-process cache: "title|artist" -> videoId
  final Map<String, String> _cache = {};

  // Track video IDs that have failed with Error 150/101 (embedding disabled by owner)
  final Set<String> _restrictedVideoIds = {};

  /// Marks a video ID as restricted by its owner (Error 150/101) so it won't be returned again
  void markVideoRestricted(String title, String artist, String videoId) {
    _restrictedVideoIds.add(videoId);
    final cacheKey = '$title|$artist';
    if (_cache[cacheKey] == videoId) {
      _cache.remove(cacheKey);
    }
    debugPrint('[YoutubeService] 🚫 Marked video $videoId as restricted for "$title - $artist"');
  }

  /// Returns the best YouTube karaoke/lyric video ID for the given song.
  /// Skips any known restricted video IDs.
  Future<String?> findKaraokeVideoId(String title, String artist, {String? excludeVideoId}) async {
    final cacheKey = '$title|$artist';
    if (excludeVideoId != null) {
      _restrictedVideoIds.add(excludeVideoId);
      _cache.remove(cacheKey);
    }

    if (_cache.containsKey(cacheKey) && !_restrictedVideoIds.contains(_cache[cacheKey])) {
      return _cache[cacheKey];
    }

    // Try queries from most-specific to broadest
    final queries = [
      '$title $artist lyrics video',      // Official lyrics video (most consistently embeddable!)
      '$title $artist karaoke',           // Karaoke version with beat + lyrics
      '$title $artist instrumental lyrics',
      '$title $artist karaoke version',
      '$title $artist official lyrics',
      '$title $artist',                   // Broadest fallback
    ];

    for (final query in queries) {
      final id = await _searchForBestMatch(query, wantKaraoke: query.contains('karaoke'));
      if (id != null && !_restrictedVideoIds.contains(id)) {
        _cache[cacheKey] = id;
        debugPrint('[YoutubeService] ✅ Resolved "$title - $artist" -> $id (query: "$query")');
        return id;
      }
    }

    debugPrint('[YoutubeService] ❌ Could not find any embeddable video for "$title - $artist"');
    return null;
  }

  Future<String?> _searchForBestMatch(String query, {bool wantKaraoke = false}) async {
    try {
      final results = await _yt.search.search(query);
      if (results.isEmpty) return null;

      // Filter out unwanted categories and known restricted IDs
      for (final video in results) {
        final id = video.id.value;
        if (_restrictedVideoIds.contains(id)) continue;
        final vtl = video.title.toLowerCase();
        if (!_isUnwanted(vtl)) {
          return id;
        }
      }

      // If wantKaraoke was requested, also try any candidate not restricted
      for (final video in results) {
        final id = video.id.value;
        if (!_restrictedVideoIds.contains(id)) {
          return id;
        }
      }

      return null;
    } catch (e) {
      debugPrint('[YoutubeService] Search error for "$query": $e');
      return null;
    }
  }

  /// Videos we don't want: live reactions, dance covers, tutorials
  bool _isUnwanted(String title) {
    const unwanted = [
      'reaction', 'reacts to', 'dance challenge', 'dance cover',
      'how to', 'tutorial', 'lesson', 'learn', 'tiktok compilation',
      'first time', 'producers react', 'teachers react',
    ];
    return unwanted.any((w) => title.contains(w));
  }

  void dispose() {
    _yt.close();
  }
}
