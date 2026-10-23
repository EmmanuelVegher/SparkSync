import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sparksync/services/nvidia_avatar_service.dart';
import 'package:sparksync/services/game_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('NVIDIA Avatar Generation & Vault Pipeline', () {
    test('NvidiaAvatarService produces structured AvatarFeatureProfile from bytes or hint', () async {
      final service = NvidiaAvatarService();

      // Test with dummy image bytes
      final dummyBytes = Uint8List.fromList(utf8.encode('dummy_image_data'));
      final profile = await service.analyzePhotoForAvatar(
        imageBytes: dummyBytes,
        fallbackHint: 'Silicon Lagoon Founder',
      );

      expect(profile, isNotNull);
      expect(profile.matchedEmoji.isNotEmpty, isTrue);
      expect(profile.vibeTitle.isNotEmpty, isTrue);
      expect(profile.skinTone.isNotEmpty, isTrue);
      expect(profile.hairStyle.isNotEmpty, isTrue);
    });

    test('GameState verifyUserSelfie updates user state with NVIDIA avatar & verified status', () async {
      final gameState = GameState();
      final user = gameState.user;

      expect(user.isVerified, isFalse);

      final mockProfile = AvatarFeatureProfile(
        skinTone: 'dark_rich',
        hairStyle: 'braids',
        hairColor: 'black',
        facialHair: 'clean_shaven',
        eyeExpression: 'confident',
        accessories: 'shades',
        clothingColor: 'lagoon_blue',
        vibeTitle: 'Silicon Lagoon Tech Founder',
        matchedEmoji: '👩🏾‍💻',
      );

      await gameState.verifyUserSelfie(
        avatarEmoji: mockProfile.matchedEmoji,
        photoUrl: 'https://ngcbjbscuegjdhmrmlvc.supabase.co/storage/v1/object/public/avatars/users/test/avatar.jpg',
        avatarProfile: mockProfile,
        title: mockProfile.vibeTitle,
      );

      expect(user.isVerified, isTrue);
      expect(user.avatarEmoji, equals('👩🏾‍💻'));
      expect(user.title, equals('Silicon Lagoon Tech Founder'));
      expect(user.verifiedPhotoUrl, contains('supabase.co'));
      expect(user.xp, greaterThanOrEqualTo(150));
      expect(user.walletBalance, greaterThanOrEqualTo(150));
    });

    test('Verification awards both +150 XP and +150 Coins', () async {
      final gameState = GameState();
      final initialCoins = gameState.user.walletBalance;
      final initialXp = gameState.user.xp;

      await gameState.verifyUserSelfie(
        avatarEmoji: '👨🏾‍💼',
        photoUrl: 'https://example.com/photo.jpg',
        title: 'Maitama Executive VIP',
      );

      expect(gameState.user.walletBalance, equals(initialCoins + 150));
      expect(gameState.user.xp, equals(initialXp + 150));
      expect(gameState.user.avatarEmoji, equals('👨🏾‍💼'));
    });
  });
}
