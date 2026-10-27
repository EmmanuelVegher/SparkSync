import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class LocalPersistenceService {
  static final LocalPersistenceService _instance = LocalPersistenceService._internal();
  factory LocalPersistenceService() => _instance;
  LocalPersistenceService._internal();

  static const String _prefUserXp = 'sparksync_user_xp';
  static const String _prefUserCoins = 'sparksync_user_coins';
  static const String _prefUserEnergy = 'sparksync_user_energy';
  static const String _prefUserAvatar = 'sparksync_user_avatar';
  static const String _prefUserVerified = 'sparksync_user_verified';
  static const String _prefUserPhoto = 'sparksync_user_photo';
  static const String _prefUserTitle = 'sparksync_user_title';
  static const String _prefUserStatus = 'sparksync_user_status';
  static const String _prefUserHood = 'sparksync_user_hood';
  static const String _prefUserState = 'sparksync_user_state';
  static const String _prefUserLga = 'sparksync_user_lga';
  static const String _prefUserArea = 'sparksync_user_area';
  static const String _prefUserCountry = 'sparksync_user_country';
  static const String _prefUserVaultPhotos = 'sparksync_user_vault_photos';
  static const String _prefUserCartoonAvatar = 'sparksync_user_cartoon_avatar';
  static const String _prefUserAvatarGlasses = 'sparksync_user_avatar_glasses';
  static const String _prefUserAvatarBeard = 'sparksync_user_avatar_beard';
  static const String _prefUserAvatarSkin = 'sparksync_user_avatar_skin';
  static const String _prefUserAvatarHair = 'sparksync_user_avatar_hair';
  static const String _prefUserAvatarOutfit = 'sparksync_user_avatar_outfit';
  static const String _prefUserSupportedClub = 'sparksync_user_supported_club';
  static const String _prefUserCertifiedPundit = 'sparksync_user_certified_pundit';
  static const String _prefUserTravelMode = 'sparksync_user_travel_mode';
  static const String _prefRoomChatsPrefix = 'sparksync_room_chat_';
  static const String _prefRoomLatestSnippets = 'sparksync_room_latest_snippets';

  /// Save core user attributes locally
  Future<void> saveUser(UserStats user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefUserXp, user.xp);
      await prefs.setInt(_prefUserCoins, user.walletBalance);
      await prefs.setInt(_prefUserEnergy, user.energy);
      await prefs.setString(_prefUserAvatar, user.avatarEmoji);
      await prefs.setBool(_prefUserVerified, user.isVerified);
      if (user.verifiedPhotoUrl != null) {
        await prefs.setString(_prefUserPhoto, user.verifiedPhotoUrl!);
      }
      if (user.avatarCartoonUrl != null) {
        await prefs.setString(_prefUserCartoonAvatar, user.avatarCartoonUrl!);
      }
      await prefs.setBool(_prefUserAvatarGlasses, user.avatarHasGlasses);
      await prefs.setBool(_prefUserAvatarBeard, user.avatarHasBeard);
      await prefs.setString(_prefUserAvatarSkin, user.avatarSkinTone);
      await prefs.setString(_prefUserAvatarHair, user.avatarHairStyle);
      await prefs.setString(_prefUserAvatarOutfit, user.avatarOutfit);
      if (user.vaultPhotos.isNotEmpty) {
        await prefs.setStringList(_prefUserVaultPhotos, user.vaultPhotos);
      }
      await prefs.setString(_prefUserTitle, user.title);
      await prefs.setString(_prefUserStatus, user.statusText);
      await prefs.setString(_prefUserHood, user.neighborhood);
      await prefs.setString(_prefUserState, user.stateName);
      await prefs.setString(_prefUserLga, user.lgaName);
      await prefs.setString(_prefUserArea, user.areaName);
      await prefs.setString(_prefUserCountry, user.countryName);
      if (user.supportedClub != null) {
        await prefs.setString(_prefUserSupportedClub, user.supportedClub!);
      }
      await prefs.setBool(_prefUserCertifiedPundit, user.isCertifiedPundit);
      await prefs.setBool(_prefUserTravelMode, user.isTravelMode);
    } catch (e) {
      debugPrint('[LocalPersistence] Error saving user stats: $e');
    }
  }

  /// Restore user attributes from local cache
  Future<void> restoreUser(UserStats user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final xp = prefs.getInt(_prefUserXp);
      if (xp != null) user.xp = xp;

      final coins = prefs.getInt(_prefUserCoins);
      if (coins != null) user.walletBalance = coins;

      final energy = prefs.getInt(_prefUserEnergy);
      if (energy != null) user.energy = energy;

      final avatar = prefs.getString(_prefUserAvatar);
      if (avatar != null && avatar.isNotEmpty) user.avatarEmoji = avatar;

      final verified = prefs.getBool(_prefUserVerified);
      if (verified != null) user.isVerified = verified;

      final photo = prefs.getString(_prefUserPhoto);
      if (photo != null && photo.isNotEmpty) user.verifiedPhotoUrl = photo;

      final cartoon = prefs.getString(_prefUserCartoonAvatar);
      if (cartoon != null && cartoon.isNotEmpty) user.avatarCartoonUrl = cartoon;

      final glasses = prefs.getBool(_prefUserAvatarGlasses);
      if (glasses != null) user.avatarHasGlasses = glasses;

      final beard = prefs.getBool(_prefUserAvatarBeard);
      if (beard != null) user.avatarHasBeard = beard;

      final skin = prefs.getString(_prefUserAvatarSkin);
      if (skin != null && skin.isNotEmpty) user.avatarSkinTone = skin;

      final hair = prefs.getString(_prefUserAvatarHair);
      if (hair != null && hair.isNotEmpty) user.avatarHairStyle = hair;

      final outfit = prefs.getString(_prefUserAvatarOutfit);
      if (outfit != null && outfit.isNotEmpty) user.avatarOutfit = outfit;

      final title = prefs.getString(_prefUserTitle);
      if (title != null && title.isNotEmpty) user.title = title;

      final status = prefs.getString(_prefUserStatus);
      if (status != null && status.isNotEmpty) user.statusText = status;

      final hood = prefs.getString(_prefUserHood);
      if (hood != null && hood.isNotEmpty) user.neighborhood = hood;

      final state = prefs.getString(_prefUserState);
      if (state != null && state.isNotEmpty) user.stateName = state;

      final lga = prefs.getString(_prefUserLga);
      if (lga != null && lga.isNotEmpty) user.lgaName = lga;

      final area = prefs.getString(_prefUserArea);
      if (area != null && area.isNotEmpty) user.areaName = area;

      final country = prefs.getString(_prefUserCountry);
      if (country != null && country.isNotEmpty) user.countryName = country;

      final vault = prefs.getStringList(_prefUserVaultPhotos);
      if (vault != null && vault.isNotEmpty) user.vaultPhotos = vault;

      final club = prefs.getString(_prefUserSupportedClub);
      if (club != null && club.isNotEmpty) user.supportedClub = club;

      final pundit = prefs.getBool(_prefUserCertifiedPundit);
      if (pundit != null) user.isCertifiedPundit = pundit;

      final travel = prefs.getBool(_prefUserTravelMode);
      if (travel != null) user.isTravelMode = travel;

      debugPrint('[LocalPersistence] Restored user: ${user.username}, XP=${user.xp}, Coins=${user.walletBalance}, Location=${user.dynamicLocationDisplay}, TravelMode=${user.isTravelMode}, Verified=${user.isVerified}, Club=${user.supportedClub}');
    } catch (e) {
      debugPrint('[LocalPersistence] Error restoring user stats: $e');
    }
  }

  /// Save room chat messages for offline & instant reload persistence (Option C: Rolling 25-message buffer)
  Future<void> saveRoomMessages(String roomId, List<TwoGoRoomMessage> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Option C: Keep up to 25 rolling most recent messages per room
      final toSave = messages.length > 25 ? messages.sublist(messages.length - 25) : messages;

      final jsonList = toSave.map((m) => {
        'id': m.id,
        'room_id': m.roomId,
        'sender_id': m.senderId,
        'sender_name': m.senderName,
        'sender_avatar': m.senderAvatar,
        'sender_rank': m.senderRank.name,
        'has_neon_glow': m.hasNeonGlow,
        'status_text': m.statusText,
        'text': m.text,
        'timestamp': m.timestamp.toIso8601String(),
        'is_user': m.isUser,
        'is_announcement': m.isAnnouncement,
      }).toList();

      await prefs.setString('$_prefRoomChatsPrefix$roomId', jsonEncode(jsonList));
    } catch (e) {
      debugPrint('[LocalPersistence] Error saving room messages for $roomId: $e');
    }
  }

  /// Restore room chat messages from local storage (Option C: Rolling 25-message buffer)
  Future<List<TwoGoRoomMessage>> restoreRoomMessages(String roomId, String currentUserId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_prefRoomChatsPrefix$roomId');
      if (raw == null || raw.isEmpty) return [];

      final list = jsonDecode(raw) as List? ?? [];
      final parsed = list.map((item) {
        final map = item as Map<String, dynamic>;
        final sId = map['sender_id'] as String? ?? '';
        return TwoGoRoomMessage(
          id: map['id']?.toString() ?? 'msg_${DateTime.now().millisecondsSinceEpoch}',
          roomId: roomId,
          senderId: sId,
          senderName: map['sender_name'] as String? ?? 'Spark Member',
          senderAvatar: map['sender_avatar'] as String? ?? '😎',
          senderRank: TwoGoStarRank.values.firstWhere(
            (r) => r.name == (map['sender_rank'] as String? ?? ''),
            orElse: () => TwoGoStarRank.novice,
          ),
          hasNeonGlow: map['has_neon_glow'] as bool? ?? false,
          isAnnouncement: map['is_announcement'] as bool? ?? false,
          statusText: map['status_text'] as String?,
          text: map['text'] as String? ?? '',
          timestamp: DateTime.tryParse(map['timestamp']?.toString() ?? '') ?? DateTime.now(),
          isUser: map['is_user'] as bool? ?? (sId == currentUserId),
        );
      }).toList();

      return parsed.length > 25 ? parsed.sublist(parsed.length - 25) : parsed;
    } catch (e) {
      debugPrint('[LocalPersistence] Error restoring room messages for $roomId: $e');
      return [];
    }
  }

  /// Save latest snippets for all room cards
  Future<void> saveRoomLatestSnippets(Map<String, String> snippets) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefRoomLatestSnippets, jsonEncode(snippets));
    } catch (_) {}
  }

  /// Restore latest snippets for room cards
  Future<Map<String, String>> restoreRoomLatestSnippets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefRoomLatestSnippets);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        return decoded.map((k, v) => MapEntry(k, v.toString()));
      }
    } catch (_) {}
    return {};
  }

  static const String _prefThemeMode = 'sparksync_theme_mode';

  /// Save user's preferred theme mode (light or dark)
  Future<void> saveThemeMode(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefThemeMode, mode == ThemeMode.light ? 'light' : 'dark');
    } catch (_) {}
  }

  /// Restore user's preferred theme mode
  Future<ThemeMode> restoreThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final val = prefs.getString(_prefThemeMode);
      if (val == 'light') return ThemeMode.light;
    } catch (_) {}
    return ThemeMode.dark;
  }
}
