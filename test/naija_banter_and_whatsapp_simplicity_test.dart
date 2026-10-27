import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sparksync/models/models.dart';
import 'package:sparksync/screens/two_go_room_view.dart';
import 'package:sparksync/services/game_state.dart';
import 'package:sparksync/services/sound_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Naija Banter & Premier League Lounge Gamification', () {
    late GameState gameState;

    setUp(() {
      gameState = GameState();
      gameState.user.walletBalance = 200;
      gameState.user.xp = 100;
      gameState.user.isCertifiedPundit = false;
    });

    test('Room room_naija_banter is configured for open entry and football banter', () {
      final banterRoom = gameState.twoGoRooms.firstWhere(
        (r) => r.id == 'room_naija_banter',
      );

      expect(banterRoom.name, equals('Naija Banter & Premier League'));
      expect(banterRoom.minStarRank, equals(TwoGoStarRank.novice));
      expect(banterRoom.iconEmoji, equals('⚽'));
    });

    test('Match prediction pool lets user stake 10 credits, gain +50 XP, and unlock Certified Pundit', () {
      final initialBalance = gameState.user.walletBalance;
      final initialXp = gameState.user.xp;

      final pool = gameState.activePredictionPool;
      expect(pool.homeTeam, equals('Arsenal'));
      expect(pool.awayTeam, equals('Chelsea'));
      expect(gameState.user.isCertifiedPundit, isFalse);

      final err = gameState.submitMatchPrediction(poolId: pool.id, outcome: '1');
      expect(err, isNull);
      expect(gameState.user.walletBalance, equals(initialBalance - 10));
      expect(gameState.user.xp, equals(initialXp + 50));
      expect(gameState.user.isCertifiedPundit, isTrue);

      // Verify active pool state updated
      expect(gameState.activePredictionPool.userPrediction, equals('1'));
      expect(gameState.activePredictionPool.totalPoolCredits, equals(pool.totalPoolCredits + 10));

      // Second stake prevented
      final secondErr = gameState.submitMatchPrediction(poolId: pool.id, outcome: '2');
      expect(secondErr, contains('already staked'));
    });

    test('Banter sound pads deduct micro-credits (2 🪙), award XP, and post stadium fx to room', () {
      final initialBalance = gameState.user.walletBalance;

      // Whistle
      final whistleErr = gameState.triggerBanterSoundPad('whistle');
      expect(whistleErr, isNull);
      expect(gameState.user.walletBalance, equals(initialBalance - 2));

      // Vuvuzela
      final vuvuErr = gameState.triggerBanterSoundPad('vuvuzela');
      expect(vuvuErr, isNull);
      expect(gameState.user.walletBalance, equals(initialBalance - 4));

      // Goal
      final goalErr = gameState.triggerBanterSoundPad('goal');
      expect(goalErr, isNull);
      expect(gameState.user.walletBalance, equals(initialBalance - 6));

      // Airhorn, Sheesh, Scratch
      expect(gameState.triggerBanterSoundPad('airhorn'), isNull);
      expect(gameState.triggerBanterSoundPad('sheesh'), isNull);
      expect(gameState.triggerBanterSoundPad('scratch'), isNull);

      final msgs = gameState.twoGoRoomChats['room_naija_banter'] ?? [];
      expect(msgs, isNotEmpty);
      expect(msgs.any((m) => m.text.contains('VUVUZELA')), isTrue);
    });

    test('Club Allegiance Flair updates profile and broadcasts loyalty', () {
      gameState.setSupportedClub('Chelsea 🔵');
      expect(gameState.user.supportedClub, equals('Chelsea 🔵'));

      final msgs = gameState.twoGoRoomChats['room_naija_banter'] ?? [];
      expect(msgs.last.text, contains('Chelsea 🔵'));
    });

    test('Send Matchday Cocktail deducts 50 🪙 and posts flirting icebreaker', () {
      final initialBalance = gameState.user.walletBalance;
      final err = gameState.sendMatchdayCocktail(
        recipientName: 'Amaka',
        rivalClub: 'Chelsea 🔵',
      );
      expect(err, isNull);
      expect(gameState.user.walletBalance, equals(initialBalance - 50));

      final msgs = gameState.twoGoRoomChats['room_naija_banter'] ?? [];
      expect(msgs.last.text, contains('Friendly Rivalry Cocktail'));
      expect(msgs.last.text, contains('Amaka'));
    });

    test('SoundService plays synthesized banter audio without error', () async {
      final sound = SoundService();
      await sound.playBanterSound('whistle');
      await sound.playBanterSound('vuvuzela');
      await sound.playBanterSound('goal');
      await sound.playBanterSound('airhorn');
      await sound.playBanterSound('sheesh');
      await sound.playBanterSound('scratch');
    });
  });

  group('WhatsApp-Style Simplicity & User-Friendly Room Experience', () {
    late GameState gameState;

    setUp(() {
      gameState = GameState();
      gameState.user.walletBalance = 200;
    });

    testWidgets('TwoGoRoomView renders clean WhatsApp layout with "+" action trigger and no screen clutter', (tester) async {
      final afrobeatRoom = gameState.twoGoRooms.firstWhere((r) => r.id == 'room_afrobeat_vibes');

      await tester.pumpWidget(
        MaterialApp(
          home: TwoGoRoomView(
            room: afrobeatRoom,
            gameState: gameState,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 1. WhatsApp Clean Header
      expect(find.text('The Afrobeat Vibe Room'), findsOneWidget);
      expect(find.text('Stage & DJ'), findsOneWidget);

      // 2. Verified NO developer clutter ("Option C • Rolling 25-Message Buffer Active" is GONE)
      expect(find.textContaining('Option C • Rolling 25-Message'), findsNothing);

      // 3. Verified WhatsApp '+' Feature Button and clean 'Message...' input
      expect(find.byIcon(Icons.add_circle_outline_rounded), findsOneWidget);
      expect(find.text('Message...'), findsOneWidget);

      // 4. Tap '+' action button opens clean feature menu
      await tester.tap(find.byIcon(Icons.add_circle_outline_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('The Afrobeat Vibe Room Features'), findsOneWidget);
      expect(find.text('Live Stage'), findsOneWidget);
      expect(find.text('DJ Decks'), findsOneWidget);
      expect(find.text('Spray Naira'), findsOneWidget);
    });
  });
}
