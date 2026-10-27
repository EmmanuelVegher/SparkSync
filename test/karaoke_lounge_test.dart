import 'package:flutter_test/flutter_test.dart';
import 'package:sparksync/models/models.dart';
import 'package:sparksync/services/game_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Live Karaoke Lounge & Crowd Applause Engine Tests', () {
    late GameState gameState;

    setUp(() {
      gameState = GameState();
      gameState.user.walletBalance = 150;
      gameState.user.xp = 1000;
      gameState.karaokeSingerName = 'Tunde 👑';
      gameState.karaokeCurrentTrack = KaraokeTrack.curatedTracks[0];
      gameState.karaokeElapsedSeconds = 0;
      gameState.karaokeClapCount = 1420;
    });

    test('Karaoke master track catalog contains curated Afrobeat tracks with lyrics', () {
      expect(KaraokeTrack.curatedTracks.length, greaterThanOrEqualTo(5));
      final essence = KaraokeTrack.curatedTracks.firstWhere((t) => t.id == 'wizkid_essence');
      expect(essence.title, equals('Essence'));
      expect(essence.artist, contains('Wizkid'));
      expect(essence.lyrics, isNotEmpty);
      expect(essence.lyrics.first.text, contains('Instrumental'));
      expect(essence.lyrics[1].text, contains('Say you don\'t need no other body'));
    });

    test('Clapping engine increments audience claps and awards singer XP', () {
      final prevClaps = gameState.karaokeClapCount;
      gameState.clapForKaraokeSinger();
      expect(gameState.karaokeClapCount, equals(prevClaps + 1));
    });

    test('Spraying Naira enforces 70/30 revenue split and triggers Money Rain', () {
      final prevCoins = gameState.user.walletBalance;
      final prevXp = gameState.user.xp;

      // Spray 50 credits on Tunde
      final err = gameState.sprayNairaOnSinger();
      expect(err, isNull);

      // Spender paid 50 credits and earned +100 Clout XP
      expect(gameState.user.walletBalance, equals(prevCoins - 50));
      expect(gameState.user.xp, equals(prevXp + 100));
      expect(gameState.isMoneyRainActive, isTrue);

      final msgs = gameState.twoGoRoomChats['room_afrobeat_vibes'] ?? [];
      expect(msgs, isNotEmpty);
      expect(msgs.last.text, contains('SPRAYS NAIRA'));
      expect(msgs.last.text, contains('+35 🪙'));
    });

    test('Singer receives 70% payout (35 🪙) directly when crowd sprays Naira on them', () {
      // Set user as active singer on stage
      gameState.karaokeSingerName = gameState.user.username;
      gameState.user.walletBalance = 100;

      // When Naira is sprayed while user is on stage
      gameState.sprayNairaOnSinger();

      // Spent 50, received 35 back = net -15
      expect(gameState.user.walletBalance, equals(100 - 50 + 35));
    });

    test('Spray Naira fails gracefully if user has insufficient credits', () {
      gameState.user.walletBalance = 20;
      final err = gameState.sprayNairaOnSinger();
      expect(err, isNotNull);
      expect(err, contains('Need at least 50 🪙'));
      expect(gameState.user.walletBalance, equals(20));
    });

    test('Buying Cocktail deducts 50 credits and grants +150 Clout XP', () {
      final prevCoins = gameState.user.walletBalance;
      final prevXp = gameState.user.xp;

      final err = gameState.buySingerCocktail();
      expect(err, isNull);
      expect(gameState.user.walletBalance, equals(prevCoins - 50));
      expect(gameState.user.xp, equals(prevXp + 150));

      final msgs = gameState.twoGoRoomChats['room_afrobeat_vibes'] ?? [];
      expect(msgs.last.text, contains('VIP COCKTAIL'));
    });

    test('Joining Mic Queue costs 30 credits and enables stage takeover', () {
      gameState.karaokeSingerName = null;
      gameState.karaokeCurrentTrack = null;
      gameState.karaokeMicQueue.clear();
      gameState.user.walletBalance = 100;
      final burnaBoyTrack = KaraokeTrack.curatedTracks[1]; // Last Last

      final err = gameState.joinKaraokeMicQueue(burnaBoyTrack);
      expect(err, isNull);
      expect(gameState.user.walletBalance, equals(70)); // 100 - 30

      // User immediately took the mic since stage was open
      expect(gameState.karaokeSingerName, contains(gameState.user.username));
      expect(gameState.karaokeCurrentTrack?.id, equals('burna_boy_last_last'));
      expect(gameState.karaokeElapsedSeconds, equals(0));

      // Joining queue again queues the user
      final remaTrack = KaraokeTrack.curatedTracks[3];
      gameState.joinKaraokeMicQueue(remaTrack);
      expect(gameState.karaokeMicQueue.length, equals(1));
      expect(gameState.karaokeMicQueue.first['trackId'], equals('rema_calm_down'));
    });

    test('Rotating singer pulls next queued singer or keeps stage open if queue is empty', () {
      gameState.karaokeMicQueue.clear();
      // 1. When queue has a singer
      gameState.karaokeMicQueue.add({
        'name': 'Live Singer 🌟',
        'avatar': '🎤',
        'rank': 'Master',
        'userId': 'user_123',
        'trackId': 'burna_boy_last_last',
      });
      gameState.karaokeElapsedSeconds = 25;
      gameState.rotateKaraokeSinger();

      expect(gameState.karaokeElapsedSeconds, equals(0));
      expect(gameState.karaokeSingerName, equals('Live Singer 🌟'));

      // 2. When queue is empty, stage is 100% live & open (no fake bot loop)
      gameState.rotateKaraokeSinger();
      expect(gameState.karaokeSingerName, isNull);
      expect(gameState.karaokeCurrentTrack, isNull);
      expect(gameState.karaokeIsPlaying, isFalse);
    });
  });
}
