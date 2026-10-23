import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sparksync/models/models.dart';
import 'package:sparksync/services/game_state.dart';
import 'package:sparksync/services/local_persistence_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Option C: Rolling 25-Message Buffer Enforcement', () {
    test('LocalPersistenceService clamps saved messages to the rolling 25 most recent', () async {
      final persistence = LocalPersistenceService();
      const roomId = 'test_room_lagos';

      // Generate 35 messages
      final messages = List.generate(35, (i) {
        return TwoGoRoomMessage(
          id: 'msg_$i',
          roomId: roomId,
          senderId: 'user_$i',
          senderName: 'User $i',
          senderAvatar: '😎',
          senderRank: TwoGoStarRank.senior,
          text: 'Message sequence index: $i',
          timestamp: DateTime.now().add(Duration(seconds: i)),
          isUser: i == 0,
        );
      });

      // Save all 35 messages
      await persistence.saveRoomMessages(roomId, messages);

      // Restore messages
      final restored = await persistence.restoreRoomMessages(roomId, 'user_0');

      // Verify Option C: Exactly 25 messages restored
      expect(restored.length, equals(25));

      // Verify they are the rolling 25 newest (index 10 to 34)
      expect(restored.first.id, equals('msg_10'));
      expect(restored.last.id, equals('msg_34'));
      expect(restored.first.text, equals('Message sequence index: 10'));
      expect(restored.last.text, equals('Message sequence index: 34'));
    });

    test('GameState caps room messages to 25 on repeated messages', () {
      final gameState = GameState();
      const roomId = 'room_eko_lounge';

      // Pre-populate room with 24 messages
      final initialMessages = List.generate(24, (i) {
        return TwoGoRoomMessage(
          id: 'init_$i',
          roomId: roomId,
          senderId: 'bot_$i',
          senderName: 'Bot $i',
          senderAvatar: '🤖',
          senderRank: TwoGoStarRank.amateur,
          text: 'Initial message $i',
          timestamp: DateTime.now().subtract(Duration(minutes: 30 - i)),
        );
      });
      gameState.twoGoRoomChats[roomId] = initialMessages;

      expect(gameState.twoGoRoomChats[roomId]!.length, equals(24));

      // Sending message 25
      gameState.sendTwoGoMessage(roomId, 'Hello 25th message');
      expect(gameState.twoGoRoomChats[roomId]!.length, equals(25));
      expect(gameState.twoGoRoomChats[roomId]!.last.text, equals('Hello 25th message'));

      // Sending message 26 (should clamp to 25 by dropping oldest init_0)
      gameState.sendTwoGoMessage(roomId, 'Hello 26th message');
      expect(gameState.twoGoRoomChats[roomId]!.length, equals(25));
      expect(gameState.twoGoRoomChats[roomId]!.first.id, equals('init_1'));
      expect(gameState.twoGoRoomChats[roomId]!.last.text, equals('Hello 26th message'));

      // Sending message 27
      gameState.sendTwoGoMessage(roomId, 'Hello 27th message');
      expect(gameState.twoGoRoomChats[roomId]!.length, equals(25));
      expect(gameState.twoGoRoomChats[roomId]!.first.id, equals('init_2'));
      expect(gameState.twoGoRoomChats[roomId]!.last.text, equals('Hello 27th message'));
    });

    test('GameState buyRoundOfDrinks and sendDrinkToUser enforce rolling 25 buffer', () {
      final gameState = GameState();
      gameState.user.walletBalance = 500;
      const roomId = 'room_vip_terrace';

      // Pre-fill with 25 messages
      gameState.twoGoRoomChats[roomId] = List.generate(25, (i) {
        return TwoGoRoomMessage(
          id: 'vip_$i',
          roomId: roomId,
          senderId: 'guest_$i',
          senderName: 'Guest $i',
          senderAvatar: '🍹',
          senderRank: TwoGoStarRank.master,
          text: 'Toast $i',
          timestamp: DateTime.now().subtract(Duration(minutes: 30 - i)),
        );
      });

      expect(gameState.twoGoRoomChats[roomId]!.length, equals(25));
      expect(gameState.twoGoRoomChats[roomId]!.first.id, equals('vip_0'));

      // Buy round of drinks (adds announcement)
      final bought = gameState.buyRoundOfDrinks(roomId);
      expect(bought, isTrue);
      expect(gameState.twoGoRoomChats[roomId]!.length, equals(25));
      expect(gameState.twoGoRoomChats[roomId]!.first.id, equals('vip_1'));
      expect(gameState.twoGoRoomChats[roomId]!.last.isAnnouncement, isTrue);

      // Send drink to user
      final sentDrink = gameState.sendDrinkToUser(roomId, 'Chioma');
      expect(sentDrink, isTrue);
      expect(gameState.twoGoRoomChats[roomId]!.length, equals(25));
      expect(gameState.twoGoRoomChats[roomId]!.first.id, equals('vip_2'));
      expect(gameState.twoGoRoomChats[roomId]!.last.text, contains('Chioma'));
    });
  });
}
