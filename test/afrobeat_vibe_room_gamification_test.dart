import 'package:flutter_test/flutter_test.dart';
import 'package:sparksync/models/models.dart';
import 'package:sparksync/services/game_state.dart';
import 'package:sparksync/services/sound_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Afrobeat Vibe Room Gamification & Live DJ Deck', () {
    late GameState gameState;

    setUp(() {
      gameState = GameState();
      // Ensure user has sufficient coins for tests
      gameState.user.walletBalance = 100;
      gameState.user.xp = 500;
    });

    test('Room room_afrobeat_vibes is configured for open entry and live music', () {
      final afrobeatRoom = gameState.twoGoRooms.firstWhere(
        (r) => r.id == 'room_afrobeat_vibes',
      );

      expect(afrobeatRoom.name, equals('The Afrobeat Vibe Room'));
      expect(afrobeatRoom.minStarRank, equals(TwoGoStarRank.novice));
      expect(afrobeatRoom.description, contains('Live DJ Deck'));
      expect(afrobeatRoom.category, equals('vibe'));
    });

    test('Initial DJ Deck state is active with resident DJ and hype meter', () {
      expect(gameState.afrobeatDjName, contains('DJ'));
      expect(gameState.afrobeatHypeProgress, greaterThan(0.5));
      expect(gameState.afrobeatPartyGoers, greaterThan(100));
      expect(gameState.afrobeatTrackTitle, isNotEmpty);
    });

    test('Afrobeat Drum Pad triggers deduct micro-credits, award XP, and post room messages', () {
      final initialCoins = gameState.user.walletBalance;
      final initialXp = gameState.user.xp;

      // 1. Drop Heavy Kick / Log Drum (Cost: 1 Credit)
      final kickErr = gameState.triggerAfrobeatPad('kick');
      expect(kickErr, isNull);
      expect(gameState.user.walletBalance, equals(initialCoins - 1));
      expect(gameState.user.xp, equals(initialXp + 5));

      final msgs = gameState.twoGoRoomChats['room_afrobeat_vibes'] ?? [];
      expect(msgs, isNotEmpty);
      expect(msgs.last.text, contains('HEAVY LOG DRUM'));

      // 2. Drop Club Airhorn (Cost: 5 Credits)
      final airhornErr = gameState.triggerAfrobeatPad('airhorn');
      expect(airhornErr, isNull);
      expect(gameState.user.walletBalance, equals(initialCoins - 6));
      expect(gameState.twoGoRoomChats['room_afrobeat_vibes']!.last.text, contains('AIRHORN'));

      // 3. Drop Conga, Sheesh, Sax, Bell
      expect(gameState.triggerAfrobeatPad('conga'), isNull);
      expect(gameState.triggerAfrobeatPad('sheesh'), isNull);
      expect(gameState.triggerAfrobeatPad('sax'), isNull);
      expect(gameState.triggerAfrobeatPad('bell'), isNull);
    });

    test('Afrobeat Drum Pad prevents trigger when user has insufficient credits', () {
      gameState.user.walletBalance = 0;
      final err = gameState.triggerAfrobeatPad('airhorn');
      expect(err, isNotNull);
      expect(err, contains('Need 5 🪙'));
      expect(gameState.user.walletBalance, equals(0));
    });

    test('Crowd 🔥 HYPE button increases hype meter and awards user and DJ XP', () {
      final prevHype = gameState.afrobeatHypeProgress;
      final prevCount = gameState.afrobeatHypeCount;

      gameState.hypeAfrobeatDj();

      expect(gameState.afrobeatHypeProgress, greaterThanOrEqualTo(prevHype));
      expect(gameState.afrobeatHypeCount, equals(prevCount + 1));
    });

    test('Crowd 👎 BOO button decreases hype and triggers stage kickout upon threshold', () {
      gameState.afrobeatDjName = 'DJ Chinedu 👑';
      gameState.afrobeatHypeProgress = 0.20;
      gameState.afrobeatBooCount = 7;

      // This boo should trigger stage rotation
      gameState.booAfrobeatDj();

      // DJ should have been rotated
      expect(gameState.afrobeatDjName, isNot(equals('DJ Chinedu 👑')));
      expect(gameState.afrobeatHypeProgress, equals(0.80));
      expect(gameState.afrobeatBooCount, equals(0));

      // Notice inserted in chatroom
      final msgs = gameState.twoGoRoomChats['room_afrobeat_vibes'] ?? [];
      expect(msgs.last.text, contains('BOOED OFF the stage'));
    });

    test('Joining DJ Queue costs 20 credits and enables stage takeover', () {
      gameState.user.walletBalance = 50;
      gameState.afrobeatDjName = 'DJ Chinedu 👑'; // resident bot

      final err = gameState.joinAfrobeatDjQueue('Asake - Lonely At The Top (Log Drum Cut)');
      expect(err, isNull);
      expect(gameState.user.walletBalance, equals(30));

      // User immediately stepped into resident DJ spot
      expect(gameState.afrobeatDjName, contains(gameState.user.username));
      expect(gameState.afrobeatTrackTitle, equals('Asake - Lonely At The Top (Log Drum Cut)'));

      // If user joins again while on stage, they go to the queue
      final queueErr = gameState.joinAfrobeatDjQueue('Rema - Calm Down (Vibe Rhythms)');
      expect(queueErr, isNull);
      expect(gameState.afrobeatDjQueue.length, equals(1));
      expect(gameState.afrobeatDjQueue.first['track'], equals('Rema - Calm Down (Vibe Rhythms)'));
    });

    test('SoundService generates and handles all Afrobeat sound samples safely', () async {
      final sound = SoundService();
      // Should not throw even in headless test environment
      await sound.playAfrobeatSample('kick');
      await sound.playAfrobeatSample('conga');
      await sound.playAfrobeatSample('bell');
      await sound.playAfrobeatSample('airhorn');
      await sound.playAfrobeatSample('sax');
      await sound.playAfrobeatSample('sheesh');
      await sound.playAfrobeatSample('scratch');
      await sound.playAfrobeatSample('cheer');
    });
  });
}
