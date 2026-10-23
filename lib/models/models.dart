import 'dart:math';

enum ItemCategory { consumable, fashion, romanticGift, profileFlair, roomPass }

enum RelationshipStage {
  talkingStage,
  situationship,
  mainSqueeze,
  owambeOfficial,
}

extension RelationshipStageExt on RelationshipStage {
  String get displayName {
    switch (this) {
      case RelationshipStage.talkingStage:
        return 'Tier 1 (Talking Stage 💬)';
      case RelationshipStage.situationship:
        return 'Tier 2 (Situationship ✨)';
      case RelationshipStage.mainSqueeze:
        return 'Tier 3 (Good Vibe 🍃)';
      case RelationshipStage.owambeOfficial:
        return 'Tier 4 (Official Match 💍)';
    }
  }

  int get requiredGifts {
    switch (this) {
      case RelationshipStage.talkingStage:
        return 0;
      case RelationshipStage.situationship:
        return 2;
      case RelationshipStage.mainSqueeze:
        return 4; // Unlocks Tier 3 (Good Vibe) Vault Reveal!
      case RelationshipStage.owambeOfficial:
        return 8;
    }
  }
}

enum TwoGoPresence {
  online,
  busy,
  away,
  offline,
}

extension TwoGoPresenceExt on TwoGoPresence {
  String get label {
    switch (this) {
      case TwoGoPresence.online:
        return 'Online';
      case TwoGoPresence.busy:
        return 'Busy';
      case TwoGoPresence.away:
        return 'Away';
      case TwoGoPresence.offline:
        return 'Offline';
    }
  }

  String get indicatorEmoji {
    switch (this) {
      case TwoGoPresence.online:
        return '🟢';
      case TwoGoPresence.busy:
        return '🔴';
      case TwoGoPresence.away:
        return '🟡';
      case TwoGoPresence.offline:
        return '⚪';
    }
  }

  String get badgeText {
    switch (this) {
      case TwoGoPresence.online:
        return '🟢 Available';
      case TwoGoPresence.busy:
        return '🔴 Busy';
      case TwoGoPresence.away:
        return '🟡 Away';
      case TwoGoPresence.offline:
        return '⚪ Offline';
    }
  }

  String get description {
    switch (this) {
      case TwoGoPresence.online:
        return 'Available to chat and connect';
      case TwoGoPresence.busy:
        return 'Busy / Do Not Disturb';
      case TwoGoPresence.away:
        return 'Away / Be Right Back';
      case TwoGoPresence.offline:
        return 'Appear Offline (Stealth mode)';
    }
  }
}

enum TwoGoStarRank {
  novice,
  amateur,
  senior,
  master,
  professional,
  expert,
  veteran,
  ultimate,
}

extension TwoGoStarRankExt on TwoGoStarRank {
  String get rankName {
    switch (this) {
      case TwoGoStarRank.novice:
        return 'Novice';
      case TwoGoStarRank.amateur:
        return 'Amateur';
      case TwoGoStarRank.senior:
        return 'Senior';
      case TwoGoStarRank.master:
        return 'Master';
      case TwoGoStarRank.professional:
        return 'Professional';
      case TwoGoStarRank.expert:
        return 'Expert';
      case TwoGoStarRank.veteran:
        return 'Veteran';
      case TwoGoStarRank.ultimate:
        return 'Ultimate';
    }
  }

  String get badgeTitle {
    switch (this) {
      case TwoGoStarRank.novice:
        return '⭐ NOVICE';
      case TwoGoStarRank.amateur:
        return '⭐ AMATEUR';
      case TwoGoStarRank.senior:
        return '🛡️ SENIOR';
      case TwoGoStarRank.master:
        return '👑 MASTER';
      case TwoGoStarRank.professional:
        return '💎 PROFESSIONAL';
      case TwoGoStarRank.expert:
        return '✨ EXPERT';
      case TwoGoStarRank.veteran:
        return '🔥 VETERAN';
      case TwoGoStarRank.ultimate:
        return '🌌 ULTIMATE';
    }
  }

  int get requiredXp {
    switch (this) {
      case TwoGoStarRank.novice:
        return 0;
      case TwoGoStarRank.amateur:
        return 500;
      case TwoGoStarRank.senior:
        return 2500;
      case TwoGoStarRank.master:
        return 7500;
      case TwoGoStarRank.professional:
        return 20000;
      case TwoGoStarRank.expert:
        return 50000;
      case TwoGoStarRank.veteran:
        return 120000;
      case TwoGoStarRank.ultimate:
        return 300000;
    }
  }

  int get maxDailySwipes {
    switch (this) {
      case TwoGoStarRank.novice:
        return 10;
      case TwoGoStarRank.amateur:
        return 25;
      case TwoGoStarRank.senior:
        return 50;
      default:
        return 9999; // Unlimited
    }
  }

  List<String> get perks {
    switch (this) {
      case TwoGoStarRank.novice:
        return [
          'Default beginner tier',
          'Max 10 swipes/day',
          'Access to standard local city chatrooms',
        ];
      case TwoGoStarRank.amateur:
        return [
          'Profile unlocked for global search',
          'Swipe limit increased to 25/day',
          'Upload up to 3 profile photos',
        ];
      case TwoGoStarRank.senior:
        return [
          'Direct Image Messaging in private DMs',
          'Access to specialized Interest Rooms',
          '1-line custom status message display',
        ];
      case TwoGoStarRank.master:
        return [
          'Unlimited swiping enabled',
          'Profile card highlighted in swipe deck',
          'Free entry to VIP Lounges',
        ];
      case TwoGoStarRank.professional:
        return [
          'Listed on Trending Singles section',
          'Room Entry Flare (text flashes cyan in chat)',
          'Eligible to apply for Room Moderator',
        ];
      case TwoGoStarRank.expert:
        return [
          '15% discount on all store items & gifts',
          'Invisible Mode toggle to browse undetected',
          'Pin custom bio to top of your room card',
        ];
      case TwoGoStarRank.veteran:
        return [
          'Permanent verified checkmark ✅',
          'Priority customer support response',
          'Daily energy pool increased from 100 to 150',
        ];
      case TwoGoStarRank.ultimate:
        return [
          'Ultimate Cloud Elite status',
          'Direct audio-notes in public chatrooms',
          'Earns 5 passive credits/hour in chatrooms',
        ];
    }
  }

  static TwoGoStarRank fromXp(int xp) {
    if (xp >= 300000) return TwoGoStarRank.ultimate;
    if (xp >= 120000) return TwoGoStarRank.veteran;
    if (xp >= 50000) return TwoGoStarRank.expert;
    if (xp >= 20000) return TwoGoStarRank.professional;
    if (xp >= 7500) return TwoGoStarRank.master;
    if (xp >= 2500) return TwoGoStarRank.senior;
    if (xp >= 500) return TwoGoStarRank.amateur;
    return TwoGoStarRank.novice;
  }

  TwoGoStarRank? get nextRank {
    final idx = index;
    if (idx < TwoGoStarRank.values.length - 1) {
      return TwoGoStarRank.values[idx + 1];
    }
    return null;
  }

  double progressToNext(int xp) {
    final next = nextRank;
    if (next == null) return 1.0;
    final currentReq = requiredXp;
    final nextReq = next.requiredXp;
    final progress = (xp - currentReq) / (nextReq - currentReq);
    return progress.clamp(0.0, 1.0);
  }
}

class UserStats {
  String username;
  String title;
  String avatarEmoji;
  int level;
  int xp;
  int walletBalance; // 🪙 Spark Coins / Credits
  int energy; // 0 - 100
  int maxEnergy;
  String neighborhood;
  String stateName;
  String lgaName;
  String areaName;
  String countryName;
  String statusText;
  TwoGoPresence presence;
  String? equippedFlair; // e.g. 'neon_night_glow'
  bool isInvisible;
  int totalGiftsSent;
  Set<String> equippedItemIds;
  int currentStreakDays;
  DateTime? lastLoginClaimAt;
  bool isVerified;
  String? verifiedPhotoUrl;
  DateTime? verifiedAt;
  List<String> vaultPhotos;
  String? avatarCartoonUrl;
  bool avatarHasGlasses;
  bool avatarHasBeard;
  String avatarSkinTone;
  String avatarHairStyle;
  String avatarOutfit;

  UserStats({
    required this.username,
    required this.title,
    required this.avatarEmoji,
    this.level = 1,
    this.xp = 0, // Starts at Novice tier (0 XP)
    this.walletBalance = 0,
    this.energy = 100,
    this.maxEnergy = 100,
    this.neighborhood = 'Central Business District',
    this.stateName = 'Federal Capital Territory (FCT)',
    this.lgaName = 'Abuja Municipal (AMAC)',
    this.areaName = 'Central Area',
    this.countryName = 'Nigeria',
    this.statusText = 'Available to connect',
    this.presence = TwoGoPresence.online,
    this.equippedFlair,
    this.isInvisible = false,
    this.totalGiftsSent = 0,
    Set<String>? equippedItemIds,
    this.currentStreakDays = 0,
    this.lastLoginClaimAt,
    this.isVerified = false,
    this.verifiedPhotoUrl,
    this.verifiedAt,
    List<String>? vaultPhotos,
    this.avatarCartoonUrl,
    this.avatarHasGlasses = true,
    this.avatarHasBeard = true,
    this.avatarSkinTone = 'warm_brown',
    this.avatarHairStyle = 'fade',
    this.avatarOutfit = 'executive',
  })  : equippedItemIds = equippedItemIds ?? {},
        vaultPhotos = vaultPhotos ?? [];

  List<String> get effectiveVaultPhotos {
    final list = <String>[];
    if (verifiedPhotoUrl != null && verifiedPhotoUrl!.isNotEmpty) {
      list.add(verifiedPhotoUrl!);
    }
    for (final p in vaultPhotos) {
      if (p.isNotEmpty && !list.contains(p)) {
        list.add(p);
      }
    }
    return list;
  }

  TwoGoStarRank get starRank => TwoGoStarRankExt.fromXp(xp);

  String get dynamicLocationDisplay {
    final parts = <String>[];
    if (areaName.isNotEmpty) parts.add(areaName);
    if (lgaName.isNotEmpty && lgaName.toLowerCase() != areaName.toLowerCase()) {
      parts.add(lgaName);
    }

    String suffix = stateName;
    if (countryName.isNotEmpty && countryName.toLowerCase() != 'nigeria') {
      suffix = stateName.isNotEmpty ? '$stateName, $countryName' : countryName;
    }

    if (parts.isNotEmpty && suffix.isNotEmpty) {
      return '${parts.join(', ')} • $suffix';
    } else if (parts.isNotEmpty) {
      return parts.join(', ');
    } else if (suffix.isNotEmpty) {
      return suffix;
    }
    return countryName.isNotEmpty ? countryName : 'Global';
  }

  void setDynamicLocation({
    required String state,
    required String lga,
    required String area,
    String country = 'Nigeria',
  }) {
    stateName = state;
    lgaName = lga;
    areaName = area;
    countryName = country;
    neighborhood = area.isNotEmpty ? area : lga;
  }

  bool get canClaimDailyGacha {
    if (lastLoginClaimAt == null) return true;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    return lastLoginClaimAt!.isBefore(todayStart);
  }
}

class HustleJob {
  final String id;
  final String title;
  final String hood;
  final String iconEmoji;
  final int energyCost;
  final int coinReward;
  final int durationSeconds;
  final String description;

  const HustleJob({
    required this.id,
    required this.title,
    required this.hood,
    required this.iconEmoji,
    required this.energyCost,
    required this.coinReward,
    required this.durationSeconds,
    required this.description,
  });
}

class VenueSpot {
  final String id;
  final String name;
  final String area;
  final String category;
  final String iconEmoji;
  final int activeSingles;
  final String description;
  final String vibeTag;
  final List<String> popularDrinks;

  const VenueSpot({
    required this.id,
    required this.name,
    required this.area,
    required this.category,
    required this.iconEmoji,
    required this.activeSingles,
    required this.description,
    required this.vibeTag,
    required this.popularDrinks,
  });
}

class ChatMessage {
  final String id;
  final String senderName;
  final String senderAvatar;
  final String text;
  final DateTime timestamp;
  final bool isUser;
  final ShopItem? attachedGift;

  ChatMessage({
    required this.id,
    required this.senderName,
    required this.senderAvatar,
    required this.text,
    required this.timestamp,
    required this.isUser,
    this.attachedGift,
  });
}

class MatchProfile {
  final String id;
  final String name;
  final int age;
  final String neighborhood;
  final String city;
  final String occupation;
  final String bio;
  final String avatarEmoji;
  final bool verifiedBadge;
  double distanceKm;
  final double latitude;
  final double longitude;
  final int syncScore; // 0 - 100%
  final List<String> interests;
  final String favoriteVenueId;
  RelationshipStage relationshipStage;
  int totalGiftsExchanged;
  TwoGoStarRank starRank;
  String statusText;
  bool hasNeonGlow;
  int giftsSent;
  List<ChatMessage> chatMessages;
  final List<String> realPhotos;
  bool vaultUnlocked;
  bool isSevered;

  bool get isVaultUnlocked =>
      relationshipStage.index >= RelationshipStage.mainSqueeze.index || vaultUnlocked;

  MatchProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.neighborhood,
    this.city = 'Lagos',
    required this.occupation,
    required this.bio,
    required this.avatarEmoji,
    this.verifiedBadge = true,
    required this.distanceKm,
    this.latitude = 6.4474,
    this.longitude = 3.4849,
    required this.syncScore,
    required this.interests,
    required this.favoriteVenueId,
    this.relationshipStage = RelationshipStage.talkingStage,
    this.totalGiftsExchanged = 0,
    this.starRank = TwoGoStarRank.master,
    this.statusText = 'Chilling, no dry chats pls.',
    this.hasNeonGlow = false,
    this.giftsSent = 28,
    List<ChatMessage>? chatMessages,
    List<String>? realPhotos,
    this.vaultUnlocked = false,
    this.isSevered = false,
  })  : chatMessages = chatMessages ?? [],
        realPhotos = realPhotos ??
            const [
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=600&q=80',
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=600&q=80',
              'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=600&q=80',
            ];

  /// Dynamically recalculate distance to live user coordinates
  double updateLiveDistance(double userLat, double userLon) {
    if (userLat == 0.0 && userLon == 0.0) return distanceKm;
    final p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 -
        cos((latitude - userLat) * p) / 2 +
        cos(userLat * p) * cos(latitude * p) * (1 - cos((longitude - userLon) * p)) / 2;
    final km = 12742 * asin(sqrt(a));
    distanceKm = double.parse(km.toStringAsFixed(1));
    return distanceKm;
  }
}

class UserDiscoveredIntel {
  final String detectedCity;
  final String detectedRegion;
  final String detectedCountry;
  final String detectedNeighborhood;
  final String detectedState;
  final String detectedLga;
  final String detectedArea;
  final double latitude;
  final double longitude;
  final String ispOrCarrier;
  final String localTimeAndTemp;
  final String predictedVibe;
  final int activeSinglesCount;
  final String topHotspotSuggestion;
  final String hardwarePlatform;
  final String trustScore;

  const UserDiscoveredIntel({
    required this.detectedCity,
    required this.detectedRegion,
    required this.detectedCountry,
    required this.detectedNeighborhood,
    this.detectedState = 'Federal Capital Territory (FCT)',
    this.detectedLga = 'Abuja Municipal (AMAC)',
    this.detectedArea = 'Central Business District',
    required this.latitude,
    required this.longitude,
    required this.ispOrCarrier,
    required this.localTimeAndTemp,
    required this.predictedVibe,
    required this.activeSinglesCount,
    required this.topHotspotSuggestion,
    required this.hardwarePlatform,
    this.trustScore = '99.4% Verified Identity',
  });
}

class ShopItem {
  final String id;
  final String name;
  final ItemCategory category;
  final int tokenCost;
  final String emoji;
  final String description;
  final String effectDescription;
  final int energyBoost;
  final String rarity; // e.g. 'Common ⚪', 'Rare 💎', 'Epic 🔮', 'Legendary 👑'

  const ShopItem({
    required this.id,
    required this.name,
    required this.category,
    required this.tokenCost,
    required this.emoji,
    required this.description,
    required this.effectDescription,
    this.energyBoost = 0,
    this.rarity = 'Rare 💎',
  });
}

class TwoGoChatRoom {
  final String id;
  final String name;
  final String category; // 'city', 'vibe', 'vip'
  final String? city;
  final int activeOnline;
  final TwoGoStarRank minStarRank;
  final int creditEntryCost;
  final String latestMessage;
  final String description;
  final String iconEmoji;

  const TwoGoChatRoom({
    required this.id,
    required this.name,
    required this.category,
    this.city,
    this.activeOnline = 0,
    this.minStarRank = TwoGoStarRank.novice,
    this.creditEntryCost = 0,
    required this.latestMessage,
    required this.description,
    required this.iconEmoji,
  });

  bool canUserEnter(UserStats user) {
    if (user.starRank.index >= minStarRank.index) return true;
    if (creditEntryCost > 0 && user.walletBalance >= creditEntryCost) return true;
    return false;
  }

  TwoGoChatRoom copyWith({
    String? id,
    String? name,
    String? category,
    String? city,
    int? activeOnline,
    TwoGoStarRank? minStarRank,
    int? creditEntryCost,
    String? latestMessage,
    String? description,
    String? iconEmoji,
  }) {
    return TwoGoChatRoom(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      city: city ?? this.city,
      activeOnline: activeOnline ?? this.activeOnline,
      minStarRank: minStarRank ?? this.minStarRank,
      creditEntryCost: creditEntryCost ?? this.creditEntryCost,
      latestMessage: latestMessage ?? this.latestMessage,
      description: description ?? this.description,
      iconEmoji: iconEmoji ?? this.iconEmoji,
    );
  }
}

class TwoGoRoomMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final TwoGoStarRank senderRank;
  final bool hasNeonGlow;
  final String? statusText;
  final String text;
  final DateTime timestamp;
  final bool isUser;
  final bool isAnnouncement;
  final bool isSystem;

  const TwoGoRoomMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.senderRank,
    this.hasNeonGlow = false,
    this.statusText,
    required this.text,
    required this.timestamp,
    this.isUser = false,
    this.isAnnouncement = false,
    this.isSystem = false,
  });
}

class LagosRandomEvent {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final String actionText;
  final int costOrReward;
  final bool isReward;

  const LagosRandomEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.actionText,
    required this.costOrReward,
    required this.isReward,
  });
}

class KaraokeLyricLine {
  final int seconds;
  final String text;
  final String? nextHint;

  const KaraokeLyricLine({
    required this.seconds,
    required this.text,
    this.nextHint,
  });
}

class KaraokeTrack {
  final String id;
  final String title;
  final String artist;
  final String emoji;
  final int durationSeconds;
  final List<KaraokeLyricLine> lyrics;

  const KaraokeTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.emoji,
    required this.durationSeconds,
    required this.lyrics,
  });

  static const List<KaraokeTrack> curatedTracks = [
    KaraokeTrack(
      id: 'wizkid_essence',
      title: 'Essence',
      artist: 'Wizkid ft. Tems',
      emoji: '✨',
      durationSeconds: 32,
      lyrics: [
        KaraokeLyricLine(seconds: 0, text: '✨ Instrumental intro... Mic is LIVE! ✨', nextHint: 'Say you don\'t need no other body...'),
        KaraokeLyricLine(seconds: 4, text: '🎤 "Say you don\'t need no other body..."', nextHint: 'You don\'t need no other body...'),
        KaraokeLyricLine(seconds: 8, text: '✨ "You don\'t need no other body... ✨"', nextHint: 'Only you fit hold my body...'),
        KaraokeLyricLine(seconds: 13, text: '🎶 "Only you fit hold my body, yeah yeah..."', nextHint: 'Tell me say your love na medicine...'),
        KaraokeLyricLine(seconds: 18, text: '💖 "Tell me say your love na medicine, baby..."', nextHint: 'Loving every day, loving every night...'),
        KaraokeLyricLine(seconds: 23, text: '🔥 "Loving every day, loving every night! 🔥"', nextHint: 'Baby tell me what you want...'),
        KaraokeLyricLine(seconds: 28, text: '🎤 "You don\'t need no other body... 🎶"', nextHint: 'Outro melody'),
      ],
    ),
    KaraokeTrack(
      id: 'burna_boy_last_last',
      title: 'Last Last (Breakfast)',
      artist: 'Burna Boy',
      emoji: '💔',
      durationSeconds: 28,
      lyrics: [
        KaraokeLyricLine(seconds: 0, text: '🎷 Afro-fusion horns spinning... 🎷', nextHint: 'E don cast, last last...'),
        KaraokeLyricLine(seconds: 4, text: '🎤 "E don cast, last last, na everybody go chop breakfast!"', nextHint: 'Shayo na my only healer...'),
        KaraokeLyricLine(seconds: 9, text: '🔥 "Shayo na my only healer, oh lord..."', nextHint: 'Why you go dey lie to me like that?'),
        KaraokeLyricLine(seconds: 14, text: '💔 "Why you go dey lie to me like that? 💔"', nextHint: 'I need Igbo and Shayo!'),
        KaraokeLyricLine(seconds: 19, text: '✨ "I need Igbo and Shayo! ✨"', nextHint: 'E don cast, last last...'),
        KaraokeLyricLine(seconds: 24, text: '🎤 "Na everybody go chop breakfast! 🍳"', nextHint: 'Crowd applause'),
      ],
    ),
    KaraokeTrack(
      id: 'asake_lonely_at_the_top',
      title: 'Lonely At The Top',
      artist: 'Asake',
      emoji: '🪵',
      durationSeconds: 30,
      lyrics: [
        KaraokeLyricLine(seconds: 0, text: '🪵 Deep Amapiano log drum drops... 🪵', nextHint: 'Out in the street dem call me lonely...'),
        KaraokeLyricLine(seconds: 4, text: '🎤 "Out in the street dem call me lonely..."', nextHint: 'But I like the way I dey go...'),
        KaraokeLyricLine(seconds: 9, text: '✨ "But I like the way I dey go, oh yeah... ✨"', nextHint: 'Money in my pocket, steady grinding...'),
        KaraokeLyricLine(seconds: 14, text: '💰 "Money in my pocket, steady grinding! 💰"', nextHint: 'Mo fe ra mansion, mo fe ra Bentley...'),
        KaraokeLyricLine(seconds: 19, text: '🔥 "Mo fe ra mansion, mo fe ra Bentley! 🔥"', nextHint: 'It\'s lonely at the top...'),
        KaraokeLyricLine(seconds: 24, text: '👑 "It\'s lonely at the top, but I\'m standing tall! 🌟"', nextHint: 'Victory cheer'),
      ],
    ),
    KaraokeTrack(
      id: 'rema_calm_down',
      title: 'Calm Down',
      artist: 'Rema',
      emoji: '💃',
      durationSeconds: 28,
      lyrics: [
        KaraokeLyricLine(seconds: 0, text: '✨ Baby calm down, sound is locked! ✨', nextHint: 'Baby calm down, calm down...'),
        KaraokeLyricLine(seconds: 4, text: '🎤 "Baby calm down, calm down..."', nextHint: 'Girl this your body put my heart for lockdown...'),
        KaraokeLyricLine(seconds: 9, text: '💃 "Girl this your body put my heart for lockdown... 💃"', nextHint: 'For lockdown, oh lockdown...'),
        KaraokeLyricLine(seconds: 14, text: '✨ "For lockdown, oh lockdown... ✨"', nextHint: 'As I reach your side, you dey give me smile...'),
        KaraokeLyricLine(seconds: 19, text: '💖 "As I reach your side, you dey give me smile! 💖"', nextHint: 'Baby calm down, calm down...'),
        KaraokeLyricLine(seconds: 24, text: '🔥 "Baby calm down, calm down! 🎶"', nextHint: 'Encore'),
      ],
    ),
    KaraokeTrack(
      id: 'ayra_starr_rush',
      title: 'Rush',
      artist: 'Ayra Starr',
      emoji: '⚡',
      durationSeconds: 28,
      lyrics: [
        KaraokeLyricLine(seconds: 0, text: '⚡ Celestial guitar strums... mic on! ⚡', nextHint: 'Me no dey follow dem, me I dey run my race...'),
        KaraokeLyricLine(seconds: 4, text: '🎤 "Me no dey follow dem, me I dey run my race..."', nextHint: 'Na God dey do am, no be my power...'),
        KaraokeLyricLine(seconds: 9, text: '💫 "Na God dey do am, no be my power... 💫"', nextHint: 'E dey rush, e dey rush well well...'),
        KaraokeLyricLine(seconds: 14, text: '✨ "E dey rush, e dey rush well well! ✨"', nextHint: 'Everything I do na double grace...'),
        KaraokeLyricLine(seconds: 19, text: '🎶 "Everything I do na double grace! 🎶"', nextHint: 'E dey rush, no stress in my zone...'),
        KaraokeLyricLine(seconds: 24, text: '💖 "E dey rush! No stress in my zone! ⚡"', nextHint: 'Final drop'),
      ],
    ),
  ];
}

