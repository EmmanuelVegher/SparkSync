import 'package:flutter_test/flutter_test.dart';
import 'package:sparksync/models/models.dart';
import 'package:sparksync/services/game_state.dart';
import 'package:sparksync/services/song_search_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SongSearchService - LRC & Lyrics Parsing Tests', () {
    final service = SongSearchService();

    test('parseLrcLyrics parses timestamped .lrc text with accurate seconds', () {
      const lrc = '''
[00:04.25] You don't need no other body
[00:09.50] Only you fit hold my body
[00:15.80] Tell me say your love na medicine
[00:22.10] Loving every day, loving every night
''';

      final result = service.parseLrcLyrics(lrc);
      expect(result.isNotEmpty, isTrue);
      // First item should be normalized with an intro or reasonable starting second
      expect(result.any((l) => l.text.contains("You don't need no other body")), isTrue);
      expect(result.any((l) => l.text.contains("Only you fit hold my body")), isTrue);

      final secondLine = result.firstWhere((l) => l.text.contains("You don't need no other body"));
      expect(secondLine.nextHint, contains("Only you fit hold my body"));
    });

    test('parsePlainLyrics creates evenly spaced lyric prompts across duration', () {
      const plain = '''
I'm unavailable, dem no dey see me
Shey you dey hear me now?
I'm only human, make nobody para o
I can't talk cause owo ni koko
''';

      final result = service.parsePlainLyrics(plain, 30);
      expect(result.isNotEmpty, isTrue);
      expect(result.first.text, contains('Instrumental intro'));
      expect(result.any((l) => l.text.contains('unavailable')), isTrue);
      expect(result.last.seconds, lessThanOrEqualTo(30));
    });

    test('generateSynthesizedLyrics produces complete timed sing-along prompts spanning performance', () {
      final lyrics = service.generateSynthesizedLyrics('Unavailable', 'Davido', 50);
      expect(lyrics.length, greaterThanOrEqualTo(12));
      expect(lyrics[0].text, contains('Unavailable'));
      expect(lyrics[1].text, contains('Davido'));
      expect(lyrics.any((l) => l.text.contains('Chorus')), isTrue);
      expect(lyrics.last.seconds, greaterThanOrEqualTo(45));
    });

    test('searchOfflineTracks returns accurate matches by title, artist, or genre', () {
      final davidoMatches = service.searchOfflineTracks('Davido');
      expect(davidoMatches.isNotEmpty, isTrue);
      expect(davidoMatches.any((t) => t.artist.contains('Davido')), isTrue);

      final bugaMatches = service.searchOfflineTracks('Buga');
      expect(bugaMatches.isNotEmpty, isTrue);
      expect(bugaMatches.first.title, contains('Buga'));

      final amapianoMatches = service.searchOfflineTracks('Amapiano');
      expect(amapianoMatches.isNotEmpty, isTrue);
    });

    test('getOfflineTrendingTracks contains curated tracks with working audio previews and rich lyrics', () {
      final tracks = service.getOfflineTrendingTracks();
      expect(tracks.length, greaterThanOrEqualTo(10));
      expect(tracks.any((t) => t.title == 'Essence'), isTrue);
      expect(tracks.any((t) => t.title == 'UNAVAILABLE'), isTrue);
      expect(tracks.any((t) => t.title.contains('Buga')), isTrue);

      // Verify tracks have real audio preview streams and >= 10 lyric lines
      final essence = tracks.firstWhere((t) => t.title == 'Essence');
      expect(essence.audioPreviewUrl, isNotNull);
      expect(essence.audioPreviewUrl, contains('itunes.apple.com'));
      expect(essence.lyrics.length, greaterThanOrEqualTo(12));
    });
  });

  group('Karaoke Online Song Integration with GameState', () {
    test('Requesting a custom searched track registers it into karaokeAvailableTracks', () {
      final gs = GameState();
      gs.user.walletBalance = 100;

      const customTrack = KaraokeTrack(
        id: 'track_custom_davido_feel',
        title: 'Feel',
        artist: 'Davido',
        emoji: '🔥',
        durationSeconds: 30,
        artworkUrl: 'https://example.com/davido_feel.jpg',
        genre: 'Afrobeats',
        lyrics: [
          KaraokeLyricLine(seconds: 0, text: '✨ Feel instrumental intro... ✨', nextHint: 'Now I am feeling...'),
          KaraokeLyricLine(seconds: 5, text: '🎤 "Now I am feeling good, feeling nice!"', nextHint: 'Lounge cheers'),
        ],
      );

      final error = gs.joinKaraokeMicQueue(customTrack);
      expect(error, isNull);

      // Verify custom track was dynamically added to available tracks
      expect(gs.karaokeAvailableTracks.any((t) => t.id == 'track_custom_davido_feel'), isTrue);

      // If stage was open, custom track took over the stage immediately
      if (gs.karaokeSingerName != null && gs.karaokeSingerName!.contains(gs.user.username)) {
        expect(gs.karaokeCurrentTrack?.id, equals('track_custom_davido_feel'));
        expect(gs.karaokeCurrentTrack?.artist, equals('Davido'));
      }
    });

    test('rotateKaraokeSinger plays the queued custom track with lyrics and artwork', () {
      final gs = GameState();
      gs.user.walletBalance = 100;

      // Force queue a song
      gs.karaokeSingerName = 'OtherSinger 👑';
      gs.karaokeMicQueue.clear();

      const customTrack = KaraokeTrack(
        id: 'track_asake_basquiat',
        title: 'Basquiat',
        artist: 'Asake',
        emoji: '🪵',
        durationSeconds: 28,
        artworkUrl: 'https://example.com/asake_basquiat.jpg',
        lyrics: [
          KaraokeLyricLine(seconds: 0, text: '🪵 Walking like Basquiat... 🪵', nextHint: 'I am walking...'),
          KaraokeLyricLine(seconds: 6, text: '🎤 "I am walking, jumping, dancing!"', nextHint: 'Outro'),
        ],
      );

      gs.joinKaraokeMicQueue(customTrack);
      expect(gs.karaokeMicQueue.isNotEmpty, isTrue);
      expect(gs.karaokeMicQueue.last['trackId'], equals('track_asake_basquiat'));

      // Rotate singer to trigger queue pop
      gs.rotateKaraokeSinger();

      expect(gs.karaokeCurrentTrack?.id, equals('track_asake_basquiat'));
      expect(gs.karaokeCurrentTrack?.title, equals('Basquiat'));
      expect(gs.karaokeCurrentTrack?.artworkUrl, equals('https://example.com/asake_basquiat.jpg'));
      expect(gs.karaokeElapsedSeconds, equals(0));
    });

    test('restartKaraokeTrack resets elapsed prompter seconds to 0 synchronously', () {
      final gs = GameState();
      gs.karaokeElapsedSeconds = 48;
      expect(gs.karaokeElapsedSeconds, equals(48));

      gs.restartKaraokeTrack();
      expect(gs.karaokeElapsedSeconds, equals(0));
    });

    test('Trending tracks have full duration and lyrics spanning full performance without 50s cutoff', () {
      final tracks = SongSearchService().getOfflineTrendingTracks();
      for (final t in tracks) {
        expect(t.durationSeconds, greaterThanOrEqualTo(180));
        expect(t.lyrics.last.seconds, greaterThanOrEqualTo(170));
      }
    });

    test('Songs up to 5 minutes or more dynamically keep full duration and complete lyrics', () {
      final service = SongSearchService();
      const longLrc = '''
[00:10.00] Intro vibe
[01:30.00] First Verse deep into performance
[03:15.00] Chorus in full swing past three minutes
[05:25.00] Climax guitar solo past five minutes
''';

      // Parse with 360 seconds (6 minutes)
      final parsed = service.parseLrcLyrics(longLrc, durationSeconds: 360);
      expect(parsed.any((l) => l.seconds == 325), isTrue); // 5m 25s = 325s
      expect(parsed.last.seconds, greaterThanOrEqualTo(330));

      // Test plain lyrics spanning 360s (6 min)
      final plainLong = service.parsePlainLyrics('Line 1\nLine 2\nLine 3\nLine 4', 360);
      expect(plainLong.last.seconds, equals(357));

      // Test dynamic queue adoption of 5+ min track
      final gs = GameState();
      gs.karaokeSingerName = null;
      gs.karaokeMicQueue.clear();
      gs.user.walletBalance = 100;
      final longTrack = KaraokeTrack(
        id: 'track_fela_zombie',
        title: 'Zombie',
        artist: 'Fela Kuti',
        emoji: '🎷',
        durationSeconds: 180, // initial estimate
        lyrics: parsed, // has lines past 325s (5m 25s)
      );

      gs.joinKaraokeMicQueue(longTrack);
      expect(gs.karaokeCurrentTrack?.durationSeconds, greaterThanOrEqualTo(330));
    });
  });
}
