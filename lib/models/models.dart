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
  List<ProfileSavedPerformance> savedPerformances;
  String? supportedClub; // e.g. 'Arsenal 🔴', 'Chelsea 🔵', 'Man United 🔴', 'Real Madrid ⚪'
  bool isCertifiedPundit;
  bool isTravelMode;

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
    List<ProfileSavedPerformance>? savedPerformances,
    this.supportedClub,
    this.isCertifiedPundit = false,
    this.isTravelMode = false,
  })  : equippedItemIds = equippedItemIds ?? {},
        vaultPhotos = vaultPhotos ?? [],
        savedPerformances = savedPerformances ?? [];

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
    bool? isTravelMode,
  }) {
    stateName = state;
    lgaName = lga;
    areaName = area;
    countryName = country;
    neighborhood = area.isNotEmpty ? area : lga;
    if (isTravelMode != null) {
      this.isTravelMode = isTravelMode;
    }
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
  final String? audioPreviewUrl;
  final String? artworkUrl;
  final String? genre;
  /// YouTube video ID (11-char), resolved lazily by YoutubeService
  final String? youtubeVideoId;
  final bool hasRealLyrics;

  const KaraokeTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.emoji,
    required this.durationSeconds,
    required this.lyrics,
    this.audioPreviewUrl,
    this.artworkUrl,
    this.genre,
    this.youtubeVideoId,
    this.hasRealLyrics = true,
  });

  KaraokeTrack copyWith({
    String? id,
    String? title,
    String? artist,
    String? emoji,
    int? durationSeconds,
    List<KaraokeLyricLine>? lyrics,
    String? audioPreviewUrl,
    String? artworkUrl,
    String? genre,
    String? youtubeVideoId,
    bool? hasRealLyrics,
  }) {
    return KaraokeTrack(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      emoji: emoji ?? this.emoji,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      lyrics: lyrics ?? this.lyrics,
      audioPreviewUrl: audioPreviewUrl ?? this.audioPreviewUrl,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      genre: genre ?? this.genre,
      youtubeVideoId: youtubeVideoId ?? this.youtubeVideoId,
      hasRealLyrics: hasRealLyrics ?? this.hasRealLyrics,
    );
  }

  static const List<KaraokeTrack> curatedTracks = [
    KaraokeTrack(
      id: 'wizkid_essence',
      title: 'Essence',
      artist: 'Wizkid ft. Tems',
      emoji: '✨',
      durationSeconds: 180,
      genre: 'Afrobeats',
      audioPreviewUrl: 'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/b3/dc/ba/b3dcba73-7f33-9abe-089c-73557a6dcb54/mzaf_16412591162283722395.plus.aac.p.m4a',
      artworkUrl: 'https://is1-ssl.mzstatic.com/image/thumb/Music115/v4/b0/09/8e/b0098ed0-ef53-f2b5-386a-c8e6181f3c8a/886448775256.jpg/100x100bb.jpg',
      lyrics: [
        KaraokeLyricLine(seconds: 0, text: '✨ Instrumental intro... Mic is LIVE! ✨', nextHint: 'Say you don\'t need no other body...'),
        KaraokeLyricLine(seconds: 14, text: '🎤 "Say you don\'t need no other body..."', nextHint: 'You don\'t need no other body...'),
        KaraokeLyricLine(seconds: 28, text: '✨ "You don\'t need no other body... ✨"', nextHint: 'Only you fit hold my body...'),
        KaraokeLyricLine(seconds: 42, text: '🎶 "Only you fit hold my body, yeah yeah..."', nextHint: 'Tell me say your love na medicine...'),
        KaraokeLyricLine(seconds: 56, text: '💖 "Tell me say your love na medicine, baby..."', nextHint: 'Loving every day, loving every night...'),
        KaraokeLyricLine(seconds: 70, text: '🔥 "Loving every day, loving every night! 🔥"', nextHint: 'Baby tell me what you want...'),
        KaraokeLyricLine(seconds: 85, text: '🎤 "Baby tell me what you want, make I give you..."', nextHint: 'Give you love in the morning...'),
        KaraokeLyricLine(seconds: 100, text: '✨ "Give you love in the morning, love in the night! ✨"', nextHint: 'Time is of the essence...'),
        KaraokeLyricLine(seconds: 115, text: '💖 "Time is of the essence, no dey waste time! 💖"', nextHint: 'You don\'t need no other body...'),
        KaraokeLyricLine(seconds: 130, text: '🎶 "You don\'t need no other body! 🎶"', nextHint: 'Only you fit hold my body...'),
        KaraokeLyricLine(seconds: 145, text: '🌟 "Only you fit hold my body, yeah yeah! 🌟"', nextHint: 'Feel the rhythm soaring...'),
        KaraokeLyricLine(seconds: 160, text: '💸 "Lounge crowd is cheering and spraying Naira! 👏💵"', nextHint: 'Final hook outro...'),
        KaraokeLyricLine(seconds: 177, text: '👑 "Essence outro: End on high notes! Take your bow! 🌟"', nextHint: 'Thunderous applause'),
      ],
    ),
    KaraokeTrack(
      id: 'burna_boy_last_last',
      title: 'Last Last (Breakfast)',
      artist: 'Burna Boy',
      emoji: '💔',
      durationSeconds: 180,
      genre: 'Afro-fusion',
      audioPreviewUrl: 'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/42/c0/0f/42c00f8b-fff6-2529-70c3-861c21143c0a/mzaf_2842108628707526245.plus.aac.p.m4a',
      artworkUrl: 'https://is1-ssl.mzstatic.com/image/thumb/Music221/v4/ca/eb/31/caeb3173-eaf0-0cd5-65ea-585adfe312ba/075679745156.jpg/100x100bb.jpg',
      lyrics: [
        KaraokeLyricLine(seconds: 0, text: '🎷 Afro-fusion horns spinning... Mic is LIVE! 🎷', nextHint: 'E don cast, last last...'),
        KaraokeLyricLine(seconds: 14, text: '🎤 "E don cast, last last, na everybody go chop breakfast!"', nextHint: 'Shayo na my only healer...'),
        KaraokeLyricLine(seconds: 28, text: '🔥 "Shayo na my only healer, oh lord..."', nextHint: 'Why you go dey lie to me like that?'),
        KaraokeLyricLine(seconds: 42, text: '💔 "Why you go dey lie to me like that? 💔"', nextHint: 'I put my heart inside your hand...'),
        KaraokeLyricLine(seconds: 56, text: '🎶 "I put my heart inside your hand, you break am..."', nextHint: 'I need Igbo and Shayo!'),
        KaraokeLyricLine(seconds: 70, text: '✨ "I need Igbo and Shayo! ✨"', nextHint: 'E don cast, last last...'),
        KaraokeLyricLine(seconds: 85, text: '🎤 "E don cast, last last, na everybody go chop breakfast! 🍳"', nextHint: 'You say you love me, but na lie...'),
        KaraokeLyricLine(seconds: 100, text: '🔥 "You say you love me, but na lie you dey talk! 🔥"', nextHint: 'Now I dey drink, I dey sip...'),
        KaraokeLyricLine(seconds: 115, text: '🍷 "Now I dey drink, I dey sip, shayo all night long! 🍷"', nextHint: 'Everybody sing the chorus together...'),
        KaraokeLyricLine(seconds: 130, text: '💥 "Na everybody go chop breakfast! Shout it loud! 💥"', nextHint: 'Let your vocals soar...'),
        KaraokeLyricLine(seconds: 145, text: '💸 "Lounge crowd spraying ₦1000 notes on stage! 💵"', nextHint: 'Climax outro...'),
        KaraokeLyricLine(seconds: 160, text: '✨ "Last last, we go dey alright! ✨"', nextHint: 'Final bow'),
        KaraokeLyricLine(seconds: 177, text: '👑 "African Giant energy! Take your bow! 🌟"', nextHint: 'VIP Encore'),
      ],
    ),
    KaraokeTrack(
      id: 'asake_lonely_at_the_top',
      title: 'Lonely At The Top',
      artist: 'Asake',
      emoji: '🪵',
      durationSeconds: 180,
      genre: 'Amapiano',
      audioPreviewUrl: 'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview221/v4/af/79/fd/af79fdf3-e757-5acd-c0de-b5c6edfaa77a/mzaf_15402833629808241649.plus.aac.p.m4a',
      artworkUrl: 'https://is1-ssl.mzstatic.com/image/thumb/Music116/v4/cc/23/83/cc2383d9-eecc-f974-5f5b-d445c583acdb/197342233958_cover.jpg/100x100bb.jpg',
      lyrics: [
        KaraokeLyricLine(seconds: 0, text: '🪵 Deep Amapiano log drum drops... Ololade mi Asake! 🪵', nextHint: 'Out in the street dem call me lonely...'),
        KaraokeLyricLine(seconds: 14, text: '🎤 "Out in the street dem call me lonely..."', nextHint: 'But I like the way I dey go...'),
        KaraokeLyricLine(seconds: 28, text: '✨ "But I like the way I dey go, oh yeah... ✨"', nextHint: 'Money in my pocket, steady grinding...'),
        KaraokeLyricLine(seconds: 42, text: '💰 "Money in my pocket, steady grinding! 💰"', nextHint: 'Mo fe ra mansion, mo fe ra Bentley...'),
        KaraokeLyricLine(seconds: 56, text: '🔥 "Mo fe ra mansion, mo fe ra Bentley! 🔥"', nextHint: 'It\'s lonely at the top...'),
        KaraokeLyricLine(seconds: 70, text: '👑 "It\'s lonely at the top, but I\'m standing tall! 🌟"', nextHint: 'Nobody dey my lane...'),
        KaraokeLyricLine(seconds: 85, text: '🎤 "Nobody dey my lane, I dey follow my pace! 🎤"', nextHint: 'Life na one turn, make you chop am well...'),
        KaraokeLyricLine(seconds: 100, text: '✨ "Life na one turn, make you chop am well well! ✨"', nextHint: 'Oluwa shower blessings on me...'),
        KaraokeLyricLine(seconds: 115, text: '🙏 "Oluwa shower blessings on me every day! 🙏"', nextHint: 'Lonely at the top chorus...'),
        KaraokeLyricLine(seconds: 130, text: '🪵 "It\'s lonely at the top! Log drums vibrating the floor! 🪵"', nextHint: 'Crowd applauds and throws money...'),
        KaraokeLyricLine(seconds: 145, text: '💸 "The whole lounge is on their feet! Spray that Naira! 💵"', nextHint: 'Asake violin finale...'),
        KaraokeLyricLine(seconds: 160, text: '⚡ "Mr Money with the vibe! Never giving up! ⚡"', nextHint: 'Outro finish'),
        KaraokeLyricLine(seconds: 177, text: '🌟 "Grand finale! Stand proud at the top! 👑✨"', nextHint: 'Standing ovation'),
      ],
    ),
    KaraokeTrack(
      id: 'rema_calm_down',
      title: 'Calm Down',
      artist: 'Rema',
      emoji: '💃',
      durationSeconds: 180,
      genre: 'Afrorave',
      audioPreviewUrl: 'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview221/v4/c3/c7/54/c3c754cd-6680-4818-9182-e08a719d59ba/mzaf_1190051474475595816.plus.aac.p.m4a',
      artworkUrl: 'https://is1-ssl.mzstatic.com/image/thumb/Music112/v4/ee/f1/dc/eef1dc82-f516-fd0f-581c-3f952a0e2243/22UMGIM92113.rgb.jpg/100x100bb.jpg',
      lyrics: [
        KaraokeLyricLine(seconds: 0, text: '✨ Baby calm down, sound is locked! Mic is LIVE! ✨', nextHint: 'Baby calm down, calm down...'),
        KaraokeLyricLine(seconds: 14, text: '🎤 "Baby calm down, calm down..."', nextHint: 'Girl this your body put my heart for lockdown...'),
        KaraokeLyricLine(seconds: 28, text: '💃 "Girl this your body put my heart for lockdown... 💃"', nextHint: 'For lockdown, oh lockdown...'),
        KaraokeLyricLine(seconds: 42, text: '✨ "For lockdown, oh lockdown... ✨"', nextHint: 'As I reach your side, you dey give me smile...'),
        KaraokeLyricLine(seconds: 56, text: '💖 "As I reach your side, you dey give me smile! 💖"', nextHint: 'You dey tell me say no stress today...'),
        KaraokeLyricLine(seconds: 70, text: '🎶 "You dey tell me say no stress today, make we dance! 🎶"', nextHint: 'Baby calm down, calm down...'),
        KaraokeLyricLine(seconds: 85, text: '🔥 "Baby calm down, calm down! Sing the hook! 🔥"', nextHint: 'Girl your waistline dey sweet me...'),
        KaraokeLyricLine(seconds: 100, text: '💃 "Girl your waistline dey sweet me like sugar! 💃"', nextHint: 'Another banger in the building...'),
        KaraokeLyricLine(seconds: 115, text: '✨ "Rave and roses! The crowd is enchanted! ✨"', nextHint: 'Baby calm down chorus reprise...'),
        KaraokeLyricLine(seconds: 130, text: '🎤 "Baby calm down, oh calm down! 🎤"', nextHint: 'VIP cocktail sent to the stage...'),
        KaraokeLyricLine(seconds: 145, text: '🍹 "Chilled cocktails flowing, club is electrified! 🥂"', nextHint: 'Final high notes...'),
        KaraokeLyricLine(seconds: 160, text: '💖 "Lockdown forever in this rhythm! 💖"', nextHint: 'Encore celebration'),
        KaraokeLyricLine(seconds: 177, text: '🌟 "Global Rave sensation! Take your bow! 👑✨"', nextHint: 'Audience cheers'),
      ],
    ),
    KaraokeTrack(
      id: 'ayra_starr_rush',
      title: 'Rush',
      artist: 'Ayra Starr',
      emoji: '⚡',
      durationSeconds: 180,
      genre: 'Afrobeats',
      audioPreviewUrl: 'https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview211/v4/a0/0c/07/a00c0745-9162-1e7f-af70-b92f891a728e/mzaf_12267370392753596352.plus.aac.p.m4a',
      artworkUrl: 'https://is1-ssl.mzstatic.com/image/thumb/Music211/v4/92/93/c1/9293c1af-2881-bcb7-439f-99a516e5d715/5059449090122.png/100x100bb.jpg',
      lyrics: [
        KaraokeLyricLine(seconds: 0, text: '⚡ Celestial guitar strums... Celestial mic is LIVE! ⚡', nextHint: 'Me no dey follow dem, me I dey run my race...'),
        KaraokeLyricLine(seconds: 14, text: '🎤 "Me no dey follow dem, me I dey run my race..."', nextHint: 'Na God dey do am, no be my power...'),
        KaraokeLyricLine(seconds: 28, text: '💫 "Na God dey do am, no be my power... 💫"', nextHint: 'E dey rush, e dey rush well well...'),
        KaraokeLyricLine(seconds: 42, text: '✨ "E dey rush, e dey rush well well! ✨"', nextHint: 'Everything I do na double grace...'),
        KaraokeLyricLine(seconds: 56, text: '🎶 "Everything I do na double grace! 🎶"', nextHint: 'E dey rush, no stress in my zone...'),
        KaraokeLyricLine(seconds: 70, text: '💖 "E dey rush! No stress in my zone! 💖"', nextHint: 'Sabi girl no dey carry last...'),
        KaraokeLyricLine(seconds: 85, text: '👑 "Sabi girl no dey carry last, we steady shining! 👑"', nextHint: 'E dey rush chorus blast...'),
        KaraokeLyricLine(seconds: 100, text: '⚡ "E dey rush, e dey rush! Sing it with energy! ⚡"', nextHint: 'Money dey enter my account...'),
        KaraokeLyricLine(seconds: 115, text: '💰 "Money dey enter my account, grace overload! 💰"', nextHint: 'Double grace anthem...'),
        KaraokeLyricLine(seconds: 130, text: '✨ "Double grace! Double joy! Double blessings! ✨"', nextHint: 'Crowd screaming and applauding...'),
        KaraokeLyricLine(seconds: 145, text: '💸 "Applause rocking the lounge! Star power on 100! 💵"', nextHint: 'Ayra vocal fade...'),
        KaraokeLyricLine(seconds: 160, text: '💫 "E dey rush, e dey rush well well! 💫"', nextHint: 'Final bow'),
        KaraokeLyricLine(seconds: 177, text: '🌟 "Celestial bow! Star of the night! 👑✨"', nextHint: 'Encore'),
      ],
    ),
  ];
}

/// Dynamic weekly scheduling system for chatrooms
enum RoomScheduleMode {
  standard,  // Monday - Wednesday: Chill lounge, beats & ad-libs
  karaoke,   // Thursday - Friday: Live Karaoke nights with stage queue & backing tracks
  challenge, // Saturday: Live Acapella Musical Challenge Arena with audience voting
}

extension RoomScheduleModeExt on RoomScheduleMode {
  String get displayName {
    switch (this) {
      case RoomScheduleMode.standard:
        return 'Standard Lounge';
      case RoomScheduleMode.karaoke:
        return 'Karaoke Nights';
      case RoomScheduleMode.challenge:
        return 'Saturday Musical Challenge';
    }
  }

  String get shortTag {
    switch (this) {
      case RoomScheduleMode.standard:
        return 'LOUNGE MODE';
      case RoomScheduleMode.karaoke:
        return 'KARAOKE LIVE';
      case RoomScheduleMode.challenge:
        return 'TOURNAMENT ARENA';
    }
  }

  String get emoji {
    switch (this) {
      case RoomScheduleMode.standard:
        return '🛋️';
      case RoomScheduleMode.karaoke:
        return '🎤';
      case RoomScheduleMode.challenge:
        return '🏆';
    }
  }

  String get badgeDescription {
    switch (this) {
      case RoomScheduleMode.standard:
        return 'Chill vibes, chat & Afrobeat drum pads active';
      case RoomScheduleMode.karaoke:
        return 'Stage mic open! Pick tracks, sing along & spray Nairas';
      case RoomScheduleMode.challenge:
        return 'Acapella Showdown! Raw vocals, live video, audience voting poll & +XP rewards!';
    }
  }

  /// Automatically computes the default scheduled mode based on day of week
  /// Mon=1, Tue=2, Wed=3 -> standard
  /// Thu=4, Fri=5 -> karaoke
  /// Sat=6 -> challenge
  /// Sun=7 -> standard (Sunday Chill)
  static RoomScheduleMode modeForDate(DateTime dt) {
    switch (dt.weekday) {
      case DateTime.thursday:
      case DateTime.friday:
        return RoomScheduleMode.karaoke;
      case DateTime.saturday:
        return RoomScheduleMode.challenge;
      default:
        return RoomScheduleMode.standard;
    }
  }
}

/// Model for saved user video/audio clips stored in profile showcase
class ProfileSavedPerformance {
  final String id;
  final String userId;
  final String username;
  final String userAvatar;
  final String trackTitle;
  final String trackArtist;
  final String? videoStorageUrl;
  final String? localFilePath;
  final int totalVotes;
  final int xpEarned;
  final String rankTitle;
  final bool isAcapella;
  final DateTime recordedAt;
  final Map<String, int> voteBreakdown; // e.g. {'naira_spray': 24, 'good_vibe': 12, 'generator_cut': 2}

  ProfileSavedPerformance({
    required this.id,
    required this.userId,
    required this.username,
    required this.userAvatar,
    required this.trackTitle,
    required this.trackArtist,
    this.videoStorageUrl,
    this.localFilePath,
    this.totalVotes = 0,
    this.xpEarned = 0,
    required this.rankTitle,
    this.isAcapella = false,
    DateTime? recordedAt,
    Map<String, int>? voteBreakdown,
  })  : recordedAt = recordedAt ?? DateTime.now(),
        voteBreakdown = voteBreakdown ?? {
          'naira_spray': 0,
          'good_vibe': 0,
          'generator_cut': 0,
        };

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'username': username,
        'user_avatar': userAvatar,
        'track_title': trackTitle,
        'track_artist': trackArtist,
        'video_storage_url': videoStorageUrl,
        'local_file_path': localFilePath,
        'total_votes': totalVotes,
        'xp_earned': xpEarned,
        'rank_title': rankTitle,
        'is_acapella': isAcapella,
        'recorded_at': recordedAt.toIso8601String(),
        'vote_breakdown': voteBreakdown,
      };

  factory ProfileSavedPerformance.fromJson(Map<String, dynamic> json) {
    return ProfileSavedPerformance(
      id: json['id'] as String? ?? 'clip_${DateTime.now().millisecondsSinceEpoch}',
      userId: json['user_id'] as String? ?? '',
      username: json['username'] as String? ?? 'Performer',
      userAvatar: json['user_avatar'] as String? ?? '🎤',
      trackTitle: json['track_title'] as String? ?? 'Afrobeat Hit',
      trackArtist: json['track_artist'] as String? ?? 'Artist',
      videoStorageUrl: json['video_storage_url'] as String?,
      localFilePath: json['local_file_path'] as String?,
      totalVotes: (json['total_votes'] as num?)?.toInt() ?? 0,
      xpEarned: (json['xp_earned'] as num?)?.toInt() ?? 0,
      rankTitle: json['rank_title'] as String? ?? 'Master',
      isAcapella: json['is_acapella'] as bool? ?? false,
      recordedAt: json['recorded_at'] != null
          ? DateTime.tryParse(json['recorded_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      voteBreakdown: (json['vote_breakdown'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toInt()),
          ) ??
          {},
    );
  }
}

/// Represents a registered contestant in the Saturday Musical Challenge Arena
class TournamentContestant {
  final String userId;
  final String username;
  final String avatarEmoji;
  final String rankTitle;
  final int performanceOrder;
  int voteCount;

  TournamentContestant({
    required this.userId,
    required this.username,
    required this.avatarEmoji,
    required this.rankTitle,
    required this.performanceOrder,
    this.voteCount = 0,
  });
}

/// Represents an in-app Spark Credits token bundle for purchase
class CreditBundle {
  final String id;
  final String title;
  final String tag;
  final int baseCredits;
  final int bonusCredits;
  final int priceNaira;
  final double priceUsd;
  final String icon;
  final bool isPopular;
  final bool isBestValue;

  const CreditBundle({
    required this.id,
    required this.title,
    required this.tag,
    required this.baseCredits,
    required this.bonusCredits,
    required this.priceNaira,
    required this.priceUsd,
    required this.icon,
    this.isPopular = false,
    this.isBestValue = false,
  });

  int get totalCredits => baseCredits + bonusCredits;
  String get formattedNaira =>
      '₦${priceNaira.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  static const List<CreditBundle> defaultBundles = [
    CreditBundle(
      id: 'bundle_starter',
      title: 'Starter Vibe Pack',
      tag: 'First Timer ⚡',
      baseCredits: 100,
      bonusCredits: 15,
      priceNaira: 500,
      priceUsd: 0.50,
      icon: '⚡',
    ),
    CreditBundle(
      id: 'bundle_flexer',
      title: 'Lounge Flexer Pack',
      tag: 'Most Popular 🔥',
      baseCredits: 500,
      bonusCredits: 100,
      priceNaira: 2000,
      priceUsd: 2.00,
      icon: '🔥',
      isPopular: true,
    ),
    CreditBundle(
      id: 'bundle_oga_boss',
      title: 'Oga Boss Vault Pack',
      tag: 'Best Value 💎',
      baseCredits: 1500,
      bonusCredits: 400,
      priceNaira: 5000,
      priceUsd: 5.00,
      icon: '💎',
      isBestValue: true,
    ),
    CreditBundle(
      id: 'bundle_billionaire',
      title: 'Billionaire VIP Crown',
      tag: 'Ultimate Flex 👑',
      baseCredits: 5000,
      bonusCredits: 1500,
      priceNaira: 15000,
      priceUsd: 15.00,
      icon: '👑',
    ),
  ];
}

/// Match prediction pool for the Naija Banter & Premier League Room
class MatchPredictionPool {
  final String id;
  final String homeTeam;
  final String awayTeam;
  final String homeBadge;
  final String awayBadge;
  final String league;
  final String matchTime;
  final int totalPoolCredits;
  final int entryCostCredits;
  final Map<String, int> predictionsCount; // '1' (Home), 'X' (Draw), '2' (Away)
  final String? userPrediction; // null if not participated
  final bool isLocked;

  const MatchPredictionPool({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeBadge,
    required this.awayBadge,
    required this.league,
    required this.matchTime,
    this.totalPoolCredits = 420,
    this.entryCostCredits = 10,
    required this.predictionsCount,
    this.userPrediction,
    this.isLocked = false,
  });

  MatchPredictionPool copyWith({
    String? id,
    String? homeTeam,
    String? awayTeam,
    String? homeBadge,
    String? awayBadge,
    String? league,
    String? matchTime,
    int? totalPoolCredits,
    int? entryCostCredits,
    Map<String, int>? predictionsCount,
    String? userPrediction,
    bool? isLocked,
  }) {
    return MatchPredictionPool(
      id: id ?? this.id,
      homeTeam: homeTeam ?? this.homeTeam,
      awayTeam: awayTeam ?? this.awayTeam,
      homeBadge: homeBadge ?? this.homeBadge,
      awayBadge: awayBadge ?? this.awayBadge,
      league: league ?? this.league,
      matchTime: matchTime ?? this.matchTime,
      totalPoolCredits: totalPoolCredits ?? this.totalPoolCredits,
      entryCostCredits: entryCostCredits ?? this.entryCostCredits,
      predictionsCount: predictionsCount ?? this.predictionsCount,
      userPrediction: userPrediction ?? this.userPrediction,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}



