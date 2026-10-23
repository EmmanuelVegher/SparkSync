import 'dart:async';
import 'dart:math';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import '../models/models.dart';
import 'local_persistence_service.dart';
import 'location_service.dart';
import 'nvidia_avatar_service.dart';
import 'photo_vault_service.dart';
import 'sound_service.dart';
import 'supabase_service.dart';

class GameState extends ChangeNotifier {
  static final GameState _instance = GameState._internal();
  factory GameState() => _instance;

  bool _isNotificationScheduled = false;

  @override
  void notifyListeners() {
    try {
      final binding = WidgetsBinding.instance;
      final phase = binding.schedulerPhase;
      if (phase == SchedulerPhase.persistentCallbacks ||
          phase == SchedulerPhase.midFrameMicrotasks) {
        if (!_isNotificationScheduled) {
          _isNotificationScheduled = true;
          binding.addPostFrameCallback((_) {
            _isNotificationScheduled = false;
            super.notifyListeners();
          });
        }
        return;
      }
    } catch (_) {
      // Non-Flutter unit testing fallback
    }
    super.notifyListeners();
  }

  GameState._internal() {
    _initCatalog();
    _startEnergyTimer();
    _initVenueChats();
    _initTwoGoRooms();
    _initLocalPersistence();
  }

  // Current User (Defaults to Novice tier, synced dynamically from Supabase on login)
  final UserStats user = UserStats(
    username: 'Spark Member',
    title: 'City Resident',
    avatarEmoji: '😎',
    level: 1,
    xp: 0, // Starts at 0 XP (Novice tier, 0%)
    walletBalance: 0,
    energy: 100,
    maxEnergy: 100,
    neighborhood: 'Central Business District',
    stateName: 'Federal Capital Territory (FCT)',
    lgaName: 'Abuja Municipal (AMAC)',
    areaName: 'Central Area',
    countryName: 'Nigeria',
    statusText: 'Available to connect on SparkSync ✨',
    equippedFlair: null,
    totalGiftsSent: 0,
  );

  // Active Lagos Event
  LagosRandomEvent? activeEvent;
  bool isNepaBlackout = false;

  // Active Hustle Timers
  final Map<String, int> activeHustleCooldowns = {};
  Timer? _ticker;

  // Catalog
  late List<HustleJob> hustles;
  late List<VenueSpot> venues;
  late final List<ShopItem> shopItems;
  late List<MatchProfile> discoveryProfiles;
  final List<MatchProfile> matches = [];
  final Set<String> blacklistedUserIds = {};
  final Map<String, int> inventory = {}; // itemId -> quantity

  // SparkSync Rooms & Chats
  late List<TwoGoChatRoom> twoGoRooms;
  final Map<String, List<TwoGoRoomMessage>> twoGoRoomChats = {};
  final List<DateTime> _recentMessageTimestamps = [];
  bool isUserMuted = false;
  DateTime? muteExpiry;
  final Map<String, int> moderationObjections = {}; // actionId -> vote count

  // Afrobeat Vibe Room Gamified DJ Deck & Soundboard State
  String afrobeatDjName = 'DJ Chinedu 👑';
  String afrobeatDjAvatar = '🎧';
  String afrobeatDjRank = 'Master Rank';
  String afrobeatTrackTitle = 'Burna Boy - City Boys (Ambiance Loop)';
  double afrobeatHypeProgress = 0.85; // 0.0 to 1.0
  int afrobeatHypeCount = 142;
  int afrobeatBooCount = 8;
  int afrobeatPartyGoers = 1402;
  final List<Map<String, String>> afrobeatDjQueue = [];

  // Afrobeat Vibe Room Live Karaoke Stage State
  String karaokeSingerName = 'Tunde 👑';
  String karaokeSingerAvatar = '🎤';
  String karaokeSingerRank = 'Master';
  String karaokeSingerId = 'user_tunde';
  KaraokeTrack karaokeCurrentTrack = KaraokeTrack.curatedTracks[0];
  int karaokeElapsedSeconds = 0;
  bool karaokeIsPlaying = true;
  int karaokeClapCount = 1420;
  int karaokeSprayedNairaTotal = 350;
  final List<Map<String, String>> karaokeMicQueue = [];
  bool isMoneyRainActive = false;

  // Venue live chat rooms: venueId -> List<ChatMessage>
  final Map<String, List<ChatMessage>> venueChats = {};

  void syncCity(String cityName) {
    final loc = LocationService();
    loc.switchCity(cityName);
    final config = loc.activeConfig;
    user.title = '${config.cityName} Resident';
    if (!config.neighborhoods.contains(user.neighborhood)) {
      user.neighborhood = config.neighborhoods.first;
    }
    venues = List.from(config.venues);
    hustles = List.from(config.hustles);
    discoveryProfiles = loc.getProfilesForCity(
      cityName,
      userLat: loc.userLatitude,
      userLon: loc.userLongitude,
    );
    _initVenueChats();
    syncWithSupabaseLive();
    notifyListeners();
  }

  Future<void> _initLocalPersistence() async {
    try {
      final local = LocalPersistenceService();
      await local.restoreUser(user);

      // Fix for previously verified user stuck with 0 coins or generic emoji:
      if (user.isVerified && user.walletBalance == 0) {
        user.walletBalance = 150;
      }
      if (user.isVerified && (user.avatarEmoji.isEmpty || user.avatarEmoji == '😎')) {
        user.avatarEmoji = '👨🏾‍💼';
      }

      // Clear stale mock or migration data to dynamic Abuja / GPS location
      if (user.neighborhood == 'Maitama' ||
          (user.stateName == 'Niger State' && user.areaName == 'Minna Central') ||
          user.neighborhood.isEmpty) {
        user.neighborhood = 'Central Business District';
        user.stateName = 'Federal Capital Territory (FCT)';
        user.lgaName = 'Abuja Municipal (AMAC)';
        user.areaName = 'Central Area';
        user.countryName = 'Nigeria';
        if (user.title == 'Niger Resident' || user.title.isEmpty) {
          user.title = 'Abuja Resident';
        }
        local.saveUser(user);
      }

      // Auto-detect live location in background on launch via location dependency
      detectLiveGpsLocation();

      // Restore room latest snippets onto twoGoRooms
      final snippets = await local.restoreRoomLatestSnippets();
      if (snippets.isNotEmpty) {
        twoGoRooms = twoGoRooms.map((r) {
          final snip = snippets[r.id];
          if (snip != null && snip.isNotEmpty) {
            return r.copyWith(latestMessage: snip);
          }
          return r;
        }).toList();
      }

      // Restore chat messages for all rooms (Option C: Rolling 25-message buffer)
      final currentUserId = SupabaseService().currentUser?.id ?? 'user_local';
      for (final room in twoGoRooms) {
        final cached = await local.restoreRoomMessages(room.id, currentUserId);
        if (cached.isNotEmpty) {
          twoGoRoomChats[room.id] = cached.length > 25 ? cached.sublist(cached.length - 25) : cached;
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('[GameState] _initLocalPersistence error: $e');
    }
  }

  Future<void> detectLiveGpsLocation() async {
    try {
      final loc = LocationService();
      final pos = await loc.requestLiveGpsUpdate();
      if (pos != null) {
        user.setDynamicLocation(
          state: loc.currentState,
          lga: loc.currentLga,
          area: loc.currentArea,
          country: loc.currentCountry,
        );
        user.title = '${loc.activeConfig.cityName} Resident';
        venues = List.from(loc.activeConfig.venues);
        hustles = List.from(loc.activeConfig.hustles);
        discoveryProfiles = loc.getProfilesForCity(
          loc.currentCity,
          userLat: loc.userLatitude,
          userLon: loc.userLongitude,
        );
        LocalPersistenceService().saveUser(user);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[GameState] detectLiveGpsLocation error: $e');
    }
  }

  void updateUserLocation({
    required String state,
    required String lga,
    required String area,
    String? city,
    String country = 'Nigeria',
  }) {
    user.setDynamicLocation(state: state, lga: lga, area: area, country: country);
    final loc = LocationService();
    loc.setCustomLocation(state: state, lga: lga, area: area, city: city, country: country);
    user.title = '${loc.activeConfig.cityName} Resident';
    venues = List.from(loc.activeConfig.venues);
    hustles = List.from(loc.activeConfig.hustles);
    discoveryProfiles = loc.getProfilesForCity(
      loc.currentCity,
      userLat: loc.userLatitude,
      userLon: loc.userLongitude,
    );
    LocalPersistenceService().saveUser(user);
    notifyListeners();
  }

  void _saveLatestSnippets() {
    try {
      final map = <String, String>{};
      for (final r in twoGoRooms) {
        if (r.latestMessage.isNotEmpty) {
          map[r.id] = r.latestMessage;
        }
      }
      LocalPersistenceService().saveRoomLatestSnippets(map);
    } catch (_) {}
  }

  Future<void> syncWithSupabaseLive() async {
    final supa = SupabaseService();
    if (!supa.isConfigured) return;
    try {
      final currentUser = supa.currentUser;
      if (currentUser != null) {
        final metaName = currentUser.userMetadata?['full_name'] as String? ??
            currentUser.userMetadata?['name'] as String? ??
            currentUser.userMetadata?['username'] as String? ??
            currentUser.email?.split('@').first;
        if (metaName != null && metaName.isNotEmpty) {
          user.username = metaName;
        }

        final profile = await supa.fetchProfile(currentUser.id);
        if (profile != null) {
          user.username = profile['username'] as String? ?? user.username;
          user.title = profile['title'] as String? ?? user.title;
          final remoteWallet = profile['wallet_balance'] as int? ?? 0;
          user.walletBalance = max(user.walletBalance, remoteWallet);
          user.energy = profile['energy'] as int? ?? user.energy;
          user.level = profile['level'] as int? ?? user.level;
          final remoteXp = profile['xp'] as int? ?? 0;
          user.xp = max(user.xp, remoteXp);
          user.neighborhood = profile['neighborhood'] as String? ?? user.neighborhood;
          user.currentStreakDays = profile['current_streak_days'] as int? ?? user.currentStreakDays;
          user.isVerified = (profile['is_verified'] as bool? ?? false) || user.isVerified;
          
          if (user.isVerified && user.walletBalance == 0) {
            user.walletBalance = 150;
          }

          final remotePhoto = profile['verified_photo_url'] as String?;
          if (remotePhoto != null && remotePhoto.isNotEmpty) {
            user.verifiedPhotoUrl = remotePhoto;
            // Cache remote photo into local vault in background so it's instantly available offline
            PhotoVaultService().cacheRemotePhoto(
              remoteUrl: remotePhoto,
              username: user.username,
            );
          } else {
            // Check if user already has a verified selfie in local vault
            final localVaultPhoto = await PhotoVaultService().getLocalVaultPhoto(user.username);
            if (localVaultPhoto != null) {
              user.verifiedPhotoUrl = localVaultPhoto.path;
              user.isVerified = true;
            }
          }
          if (profile['avatar_emoji'] != null) {
            user.avatarEmoji = profile['avatar_emoji'] as String;
          }
          if (profile['last_login_claim_at'] != null) {
            user.lastLoginClaimAt = DateTime.tryParse(profile['last_login_claim_at'].toString()) ?? user.lastLoginClaimAt;
          }
          // Persist merged user state locally
          LocalPersistenceService().saveUser(user);
        } else {
          // Initialize fresh profile in Supabase
          try {
            await supa.client?.from('profiles').upsert({
              'id': currentUser.id,
              'username': user.username,
              'neighborhood': user.neighborhood,
              'avatar_emoji': user.avatarEmoji,
              'is_verified': user.isVerified,
              'verified_photo_url': user.verifiedPhotoUrl,
              'wallet_balance': user.walletBalance,
              'energy': 100,
              'level': 1,
              'xp': user.xp,
            });
          } catch (_) {}
        }
        notifyListeners();
      }

      // Load real profiles from Supabase
      final rawProfiles = await supa.fetchLiveProfiles(city: LocationService().currentCity);
      if (rawProfiles.isNotEmpty) {
        discoveryProfiles = rawProfiles.map((row) {
          final p = MatchProfile(
            id: row['id'] as String,
            name: row['username'] as String? ?? 'Member',
            age: row['age'] as int? ?? 24,
            neighborhood: row['neighborhood'] as String? ?? LocationService().activeConfig.neighborhoods.first,
            city: LocationService().currentCity,
            occupation: row['title'] as String? ?? 'Verified Member',
            bio: row['bio'] as String? ?? 'Looking to connect and hustle together.',
            avatarEmoji: row['avatar_emoji'] as String? ?? '😎',
            distanceKm: 1.0,
            syncScore: 92,
            interests: ['Tech', 'Dining', 'Afrobeats'],
            favoriteVenueId: venues.isNotEmpty ? venues.first.id : 'central_spot',
          );
          p.updateLiveDistance(LocationService().userLatitude, LocationService().userLongitude);
          return p;
        }).toList();
        discoveryProfiles.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[GameState] syncWithSupabaseLive error: $e');
    }
  }

  void _initCatalog() {
    hustles = const [
      HustleJob(
        id: 'fintech_dev',
        title: 'Remote Fintech Dev Sprint',
        hood: 'Yaba Silicon Lagoon',
        iconEmoji: '💻',
        energyCost: 30,
        coinReward: 140,
        durationSeconds: 8,
        description: 'Ship payment webhooks for a Lagos crypto startup. Fast cash!',
      ),
      HustleJob(
        id: 'quilox_dj',
        title: 'Guest DJ Set at Quilox',
        hood: 'Victoria Island',
        iconEmoji: '🎧',
        energyCost: 25,
        coinReward: 110,
        durationSeconds: 6,
        description: 'Spin Afrobeats bangers till 4 AM. Tips from big ballers!',
      ),
      HustleJob(
        id: 'owambe_mc',
        title: 'Owambe Party Hype Man',
        hood: 'Surulere',
        iconEmoji: '🎤',
        energyCost: 20,
        coinReward: 85,
        durationSeconds: 5,
        description: 'Spray cash, hype aunties, and keep the dancefloor alive.',
      ),
      HustleJob(
        id: 'danfo_conductor',
        title: 'Danfo Conductor at Oshodi',
        hood: 'Oshodi Underbridge',
        iconEmoji: '🚐',
        energyCost: 15,
        coinReward: 50,
        durationSeconds: 4,
        description: '"Obalende direct! Enter with your 100 Naira change!"',
      ),
      HustleJob(
        id: 'content_creator',
        title: 'Lekki Lifestyle Vlog Shoot',
        hood: 'Admiralty Way, Lekki',
        iconEmoji: '📸',
        energyCost: 12,
        coinReward: 40,
        durationSeconds: 3,
        description: 'Record an aesthetic "Day in the Life of a Lagos Baller".',
      ),
    ];

    venues = const [
      VenueSpot(
        id: 'quilox',
        name: 'Quilox Nightclub',
        area: 'Victoria Island',
        category: 'Nightlife & VIP',
        iconEmoji: '🍾',
        activeSingles: 184,
        description: 'Where Lagos elite party till dawn. High-energy Afrobeats and bottle popping.',
        vibeTag: 'VIP & High Energy 🔥',
        popularDrinks: ['Ace of Spades', 'Don Julio 1942', 'Red Bull + Vodka'],
      ),
      VenueSpot(
        id: 'moist_beach',
        name: 'Moist Beach Club',
        area: 'Oniru Private Beach',
        category: 'Beach & Sunset',
        iconEmoji: '🌊',
        activeSingles: 126,
        description: 'Ocean waves, white sand, sunset cocktails, and effortless coastal vibes.',
        vibeTag: 'Romantic Breeze 🌅',
        popularDrinks: ['Fresh Coconut Mojito', 'Chapman Cooler', 'Chilled Rosé'],
      ),
      VenueSpot(
        id: 'terra_kulture',
        name: 'Terra Kulture Art Café',
        area: 'Victoria Island',
        category: 'Art, Books & Coffee',
        iconEmoji: '☕',
        activeSingles: 78,
        description: 'Nigerian art gallery, book readings, and authentic spicy Jollof rice.',
        vibeTag: 'Intellectual & Cozy 📚',
        popularDrinks: ['Nigerian Spiced Espresso', 'Zobo Hibiscus Tea', 'Palm Wine Fusion'],
      ),
      VenueSpot(
        id: 'lekki_canopy',
        name: 'Lekki Conservation Centre',
        area: 'Lekki Peninsula',
        category: 'Adventure & Nature',
        iconEmoji: '🌿',
        activeSingles: 95,
        description: 'Longest canopy walkway in Africa. Perfect for fun, adventurous couples.',
        vibeTag: 'Playful & Outdoors 🐒',
        popularDrinks: ['Cold Pressed Cane Juice', 'Bottled Coconut Water', 'Iced Hibiscus'],
      ),
      VenueSpot(
        id: 'glover_suya',
        name: 'Glover Court Suya',
        area: 'Ikoyi',
        category: 'Street Food & Hangout',
        iconEmoji: '🥩',
        activeSingles: 142,
        description: 'Legendary midnight spicy beef suya, onions, and cold drinks with soft vibes.',
        vibeTag: 'Midnight Chill 🌶️',
        popularDrinks: ['Ice Cold Star Radler', 'Maltina', 'Ginger Beer'],
      ),
    ];

    shopItems = const [
      ShopItem(
        id: 'amala_shitta',
        name: 'Hot Amala & Gbegiri',
        category: ItemCategory.consumable,
        tokenCost: 45,
        emoji: '🍲',
        description: 'Authentic steaming hot Amala from Shitta, Surulere with goat meat.',
        effectDescription: 'Restores +45 ⚡ Energy immediately.',
        energyBoost: 45,
      ),
      ShopItem(
        id: 'glover_suya_pack',
        name: 'Spicy Glover Suya Platter',
        category: ItemCategory.consumable,
        tokenCost: 35,
        emoji: '🥩',
        description: 'Well-seasoned beef suya with fresh red onions and yaji pepper.',
        effectDescription: 'Restores +35 ⚡ Energy immediately.',
        energyBoost: 35,
      ),
      ShopItem(
        id: 'gen_fuel',
        name: '20L Generator Diesel Jerrycan',
        category: ItemCategory.consumable,
        tokenCost: 70,
        emoji: '⛽',
        description: 'Keep the AC and lights freezing even when NEPA fails you.',
        effectDescription: 'Restores +70 ⚡ Energy & protects against blackouts.',
        energyBoost: 70,
      ),
      ShopItem(
        id: 'agbada_gold',
        name: 'Royal Agbada + Heavy Gold Chain',
        category: ItemCategory.fashion,
        tokenCost: 320,
        emoji: '👑',
        description: 'Crisp starched navy blue Agbada that screams "Federal Government Contractor".',
        effectDescription: '+30% Charisma boost in high-end venues.',
      ),
      ShopItem(
        id: 'tech_hoodie',
        name: 'Silicon Lagoon Tech Hoodie',
        category: ItemCategory.fashion,
        tokenCost: 180,
        emoji: '🧥',
        description: 'Minimalist designer black hoodie. Gives off Y Combinator funded energy.',
        effectDescription: '+15% extra coins on dev hustles.',
      ),
      ShopItem(
        id: 'red_roses',
        name: 'Bouquet of Red Roses',
        category: ItemCategory.romanticGift,
        tokenCost: 50,
        emoji: '🌹',
        description: 'A classic declaration of romantic intent.',
        effectDescription: '+1 Relationship Point with your match.',
      ),
      ShopItem(
        id: 'belgian_chocolates',
        name: 'Belgian Chocolate Truffles',
        category: ItemCategory.romanticGift,
        tokenCost: 80,
        emoji: '🍫',
        description: 'Imported silky luxury chocolates that melt instantly.',
        effectDescription: '+2 Relationship Points & unlocks sweet chat prompt.',
      ),
      ShopItem(
        id: 'moet_champagne',
        name: 'Moët & Chandon Nectar Impérial',
        category: ItemCategory.romanticGift,
        tokenCost: 200,
        emoji: '🍾',
        description: 'The golden standard of Lagos celebration and romantic flexing.',
        effectDescription: '+4 Relationship Points & VIP spark flare.',
      ),
      ShopItem(
        id: 'gwagon_keys',
        name: 'Mercedes G-Wagon Keys',
        category: ItemCategory.romanticGift,
        tokenCost: 650,
        emoji: '🗝️',
        description: 'The ultimate symbol of Lagos romance. Pure unadulterated luxury.',
        effectDescription: 'Instant couple unlock & "Owambe Official" eligibility!',
      ),
      // SparkSync Customizations
      ShopItem(
        id: 'neon_night_glow',
        name: 'Neon Night Glow Theme',
        category: ItemCategory.profileFlair,
        tokenCost: 350,
        emoji: '⭐',
        rarity: 'Rare 💎',
        description: 'Make your profile card pulse with a vibrant neon light effect inside every public chatroom. Lasts permanently once owned!',
        effectDescription: 'Pulsing cyber rainbow neon glow on profile mini-cards and chatrooms.',
      ),
      ShopItem(
        id: 'golden_vip_pass',
        name: 'Golden VIP Lounge Pass',
        category: ItemCategory.roomPass,
        tokenCost: 200,
        emoji: '🎟️',
        rarity: 'Epic 🔮',
        description: 'Gain immediate access to all exclusive high-clout VIP lounges regardless of your Star Rank.',
        effectDescription: 'Unlocks Billionaire\'s Club and Penthouse Lounges.',
      ),
      ShopItem(
        id: 'crown_of_lekki',
        name: 'Crown of Lekki Flair',
        category: ItemCategory.profileFlair,
        tokenCost: 500,
        emoji: '👑',
        rarity: 'Legendary 👑',
        description: 'Royal gold aura badge pinned to your name in every public room and swipe deck.',
        effectDescription: 'High-roller gold crown badge displayed with shimmering particles.',
      ),
      ShopItem(
        id: 'champagne_round',
        name: 'Room Champagne Round',
        category: ItemCategory.consumable,
        tokenCost: 100,
        emoji: '🍾',
        rarity: 'Rare 💎',
        description: 'Buy a round of virtual drinks for everyone in your active chatroom with full room banner announcement!',
        effectDescription: 'Awards +150 Clout XP and flashes room-wide banner announcement.',
      ),
      ShopItem(
        id: 'chilled_malt',
        name: 'Chilled Malt Drink',
        category: ItemCategory.consumable,
        tokenCost: 20,
        emoji: '🧃',
        rarity: 'Common ⚪',
        description: 'Ice-cold refreshing malt drink. Perfect afternoon pick-me-up.',
        effectDescription: 'Instantly replenishes +10 ⚡ Energy pool points.',
        energyBoost: 10,
      ),
      ShopItem(
        id: 'party_jollof',
        name: 'Party Jollof Feast',
        category: ItemCategory.consumable,
        tokenCost: 65,
        emoji: '🍲',
        rarity: 'Rare 💎',
        description: 'Smoky Lagos wedding party Jollof rice with fried plantain and peppered beef.',
        effectDescription: 'Maximizes stamina pool with +50 ⚡ Energy.',
        energyBoost: 50,
      ),
      ShopItem(
        id: 'neon_chat_flare',
        name: 'Exclusive Neon Chat Flare',
        category: ItemCategory.profileFlair,
        tokenCost: 250,
        emoji: '✨',
        rarity: 'Mythic 🌟',
        description: 'Exclusive animated neon text trail in public lounges and VIP rooms. Displays your clout!',
        effectDescription: 'Exclusive 24-hour animated neon chat flare text trail in lounges.',
      ),
    ];

    final loc = LocationService();
    venues = List.from(loc.activeConfig.venues);
    hustles = List.from(loc.activeConfig.hustles);
    discoveryProfiles = loc.getProfilesForCity(
      loc.currentCity,
      userLat: loc.userLatitude,
      userLon: loc.userLongitude,
    );

    // Give user initial items in inventory
    inventory['amala_shitta'] = 2;
    inventory['red_roses'] = 1;
    inventory['glover_suya_pack'] = 1;

    // Seed one starter match so the user can immediately experience the chat & gift mechanics
    final starterMatch = MatchProfile(
      id: 'starter_tiwa',
      name: 'Tiwa Savage (Vibe Sync)',
      age: 24,
      neighborhood: 'Lekki Phase 1',
      occupation: 'Fintech Product Lead & DJ',
      bio: 'You swiped right on me at Quilox! Let us make Lagos fun.',
      avatarEmoji: '💃',
      distanceKm: 2.1,
      syncScore: 96,
      interests: ['Quilox Nightlife', 'Afrobeats', 'Tech'],
      favoriteVenueId: 'quilox',
      relationshipStage: RelationshipStage.talkingStage,
      totalGiftsExchanged: 1,
    );
    starterMatch.chatMessages.addAll([
      ChatMessage(
        id: 'm1',
        senderName: 'Tiwa',
        senderAvatar: '💃',
        text: 'Hey Tunde! Saw you were chilling at Lekki Phase 1. Did you survive that heavy rain yesterday?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
        isUser: false,
      ),
      ChatMessage(
        id: 'm2',
        senderName: 'Tunde_Lagos',
        senderAvatar: '😎',
        text: 'Barely! Lagos drainage tested our faith, but we are standing strong lol.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
        isUser: true,
      ),
      ChatMessage(
        id: 'm3',
        senderName: 'Tiwa',
        senderAvatar: '💃',
        text: 'Haha typical Lagos! Are we hitting Quilox or getting spicy Suya this weekend? 😏',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        isUser: false,
      ),
    ]);
    matches.add(starterMatch);
  }

  void _initVenueChats() {
    venueChats['quilox'] = [
      ChatMessage(
        id: 'q1',
        senderName: 'Femi_VIP',
        senderAvatar: '🍾',
        text: 'Table 4 is popping tonight! Who is hearing this new Burna Boy track?! 🔥',
        timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
        isUser: false,
      ),
      ChatMessage(
        id: 'q2',
        senderName: 'Kemi_Lekki',
        senderAvatar: '👠',
        text: 'Just walked in. Need someone to buy me a chilled cocktail before I step on the dancefloor 🍸',
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
        isUser: false,
      ),
    ];

    venueChats['moist_beach'] = [
      ChatMessage(
        id: 'mb1',
        senderName: 'Tobi_Waves',
        senderAvatar: '🏄‍♂️',
        text: 'Sunset at Oniru hits different with cold coconut water 🥥',
        timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
        isUser: false,
      ),
      ChatMessage(
        id: 'mb2',
        senderName: 'Amaka_Beauty',
        senderAvatar: '🌊',
        text: 'Looking for a fellow beach lover to take aesthetic photos with me 📸',
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        isUser: false,
      ),
    ];

    venueChats['terra_kulture'] = [
      ChatMessage(
        id: 'tk1',
        senderName: 'Emeka_Books',
        senderAvatar: '📚',
        text: 'The new contemporary sculpture exhibition here is pure genius.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        isUser: false,
      ),
      ChatMessage(
        id: 'tk2',
        senderName: 'Zainab_Art',
        senderAvatar: '🎨',
        text: 'Having spiced ginger tea. Any fellow art souls around? 👋',
        timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
        isUser: false,
      ),
    ];

    venueChats['lekki_canopy'] = [
      ChatMessage(
        id: 'lc1',
        senderName: 'Chuka_Adv',
        senderAvatar: '🐒',
        text: 'That canopy walkway will test your bravery for your crush haha!',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        isUser: false,
      ),
    ];

    venueChats['glover_suya'] = [
      ChatMessage(
        id: 'gs1',
        senderName: 'Bayo_Grill',
        senderAvatar: '🌶️',
        text: 'The suya pepper tonight is no joke! Get cold Star Radler ready 🥩🍻',
        timestamp: DateTime.now().subtract(const Duration(minutes: 6)),
        isUser: false,
      ),
    ];
  }

  void _initTwoGoRooms() {
    twoGoRooms = List<TwoGoChatRoom>.from([
      TwoGoChatRoom(
        id: 'room_abuja_society',
        name: 'Abuja: Maitama High Society',
        category: 'city',
        city: 'Abuja',
        activeOnline: 0,
        minStarRank: TwoGoStarRank.novice,
        latestMessage: 'No messages yet — start the chat! ✨',
        description: 'Diplomatic vibes, cool Abuja evenings, and polished conversations.',
        iconEmoji: '🏛️',
      ),
      TwoGoChatRoom(
        id: 'room_lagos_mingle',
        name: 'Lagos: Flirt & Mingle',
        category: 'city',
        city: 'Lagos',
        activeOnline: 0,
        minStarRank: TwoGoStarRank.novice,
        latestMessage: 'No messages yet — start the chat! ✨',
        description: 'Rapid-fire Lagos dating banter, linkups, and weekend plans.',
        iconEmoji: '🔥',
      ),
      TwoGoChatRoom(
        id: 'room_ph_oil_city',
        name: 'Port Harcourt: Oil City Singles',
        category: 'city',
        city: 'Port Harcourt',
        activeOnline: 0,
        minStarRank: TwoGoStarRank.novice,
        latestMessage: 'No messages yet — start the chat! ✨',
        description: 'Garden city energy, bole discussions, and real connections.',
        iconEmoji: '⚓',
      ),
      TwoGoChatRoom(
        id: 'room_niger_state_connect',
        name: 'Niger: Minna & Suleja Vibe',
        category: 'city',
        city: 'Minna',
        activeOnline: 0,
        minStarRank: TwoGoStarRank.novice,
        latestMessage: 'No messages yet — start the chat! ✨',
        description: 'Zuma Rock energy, Minna singles, and weekend road trip plans.',
        iconEmoji: '⛰️',
      ),
      TwoGoChatRoom(
        id: 'room_global_diaspora',
        name: 'Global Diaspora Connect',
        category: 'city',
        activeOnline: 0,
        minStarRank: TwoGoStarRank.amateur,
        latestMessage: 'No messages yet — start the chat! ✨',
        description: 'Nigerians in London, Atlanta, Toronto, and Berlin vibing together.',
        iconEmoji: '🌍',
      ),
      TwoGoChatRoom(
        id: 'room_afrobeat_vibes',
        name: 'The Afrobeat Vibe Room',
        category: 'vibe',
        activeOnline: 0,
        minStarRank: TwoGoStarRank.novice,
        latestMessage: 'No messages yet — start the chat! ✨',
        description: 'Live DJ Deck, Beat Pad, and crowd voting! Drop beats and party till dawn. 🎵🔥',
        iconEmoji: '🎵',
      ),
      TwoGoChatRoom(
        id: 'room_late_night',
        name: 'Late Night Talk & Confessions',
        category: 'vibe',
        activeOnline: 0,
        minStarRank: TwoGoStarRank.novice,
        latestMessage: 'No messages yet — start the chat! ✨',
        description: 'Deep midnight conversations, relationship confessions, and cozy vibes.',
        iconEmoji: '💬',
      ),
      TwoGoChatRoom(
        id: 'room_naija_banter',
        name: 'Naija Banter & Premier League',
        category: 'vibe',
        activeOnline: 0,
        minStarRank: TwoGoStarRank.novice,
        latestMessage: 'No messages yet — start the chat! ✨',
        description: 'High-octane football arguments, street banter, and friendly rivalry.',
        iconEmoji: '⚽',
      ),
      TwoGoChatRoom(
        id: 'room_billionaires_vip',
        name: 'The Billionaire\'s Club (VIP)',
        category: 'vip',
        activeOnline: 0,
        minStarRank: TwoGoStarRank.master,
        creditEntryCost: 50,
        latestMessage: 'No messages yet — start the chat! ✨',
        description: 'Entry: 50 Coins OR Master Rank 🪙. Exclusive VIP space.',
        iconEmoji: '👑',
      ),
      TwoGoChatRoom(
        id: 'room_penthouse_sky',
        name: 'The Penthouse Sky Lounge',
        category: 'vip',
        activeOnline: 0,
        minStarRank: TwoGoStarRank.professional,
        creditEntryCost: 100,
        latestMessage: 'No messages yet — start the chat! ✨',
        description: 'Entry: 100 Coins OR Professional Rank 💎. Premium skyline lounge.',
        iconEmoji: '💎',
      ),
    ]);

    twoGoRoomChats.clear();
  }

  void _startEnergyTimer() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Hustle cooldown countdown
      final keys = activeHustleCooldowns.keys.toList();
      for (final id in keys) {
        final current = activeHustleCooldowns[id] ?? 0;
        if (current > 1) {
          activeHustleCooldowns[id] = current - 1;
        } else {
          activeHustleCooldowns.remove(id);
        }
      }

      // Energy slow natural regen every 45 seconds
      if (timer.tick % 45 == 0 && user.energy < user.maxEnergy) {
        user.energy = min(user.maxEnergy, user.energy + 2);
        notifyListeners();
      }

      // Random Lagos event every 90 seconds if none active
      if (timer.tick % 90 == 0 && activeEvent == null) {
        _triggerRandomLagosEvent();
      }

      // Live Karaoke synchronized lyric progression clock
      if (karaokeIsPlaying) {
        karaokeElapsedSeconds++;
        if (karaokeElapsedSeconds >= karaokeCurrentTrack.durationSeconds) {
          rotateKaraokeSinger();
        } else {
          notifyListeners();
        }
      }
    });
  }

  void _triggerRandomLagosEvent() {
    final rand = Random().nextInt(4);
    switch (rand) {
      case 0:
        isNepaBlackout = true;
        activeEvent = const LagosRandomEvent(
          id: 'nepa_drop',
          title: '⚡ Up NEPA! Power Grid Collapse',
          description: 'The whole neighborhood went pitch black! Your date is squinting in the dark.',
          emoji: '🕯️',
          actionText: 'Light Candles (Free Romance) or Buy Diesel (-₦30)',
          costOrReward: 30,
          isReward: false,
        );
        break;
      case 1:
        activeEvent = const LagosRandomEvent(
          id: 'traffic_jam',
          title: '🚐 Third Mainland Bridge "Go-Slow"',
          description: 'Trailer broke down at Adekunle! Traffic is standing still.',
          emoji: '🛵',
          actionText: 'Hire Dispatch Okada Rider (-₦20) to make your date on time',
          costOrReward: 20,
          isReward: false,
        );
        break;
      case 2:
        activeEvent = const LagosRandomEvent(
          id: 'suya_bonus',
          title: '🥩 Free Suya from Alhaji!',
          description: 'Your regular Suya master gave you extra kidney & beef as loyalty bonus!',
          emoji: '🔥',
          actionText: 'Chop Suya (+25 ⚡ Energy)',
          costOrReward: 25,
          isReward: true,
        );
        break;
      case 3:
        activeEvent = const LagosRandomEvent(
          id: 'owambe_spray',
          title: '💸 Unsolicited Cash Spray at Owambe',
          description: 'An Uncle sprayed fresh crisp 1,000 Naira notes on you while dancing!',
          emoji: '🎉',
          actionText: 'Pick Cash (+80 🪙)',
          costOrReward: 80,
          isReward: true,
        );
        break;
    }
    notifyListeners();
  }

  void resolveActiveEvent(bool takeAction) {
    if (activeEvent == null) return;
    final ev = activeEvent!;
    if (takeAction) {
      if (ev.isReward) {
        if (ev.id == 'suya_bonus') {
          user.energy = min(user.maxEnergy, user.energy + ev.costOrReward);
        } else {
          user.walletBalance += ev.costOrReward;
        }
      } else {
        if (user.walletBalance >= ev.costOrReward) {
          user.walletBalance -= ev.costOrReward;
        }
      }
    }
    isNepaBlackout = false;
    activeEvent = null;
    notifyListeners();
  }

  // Hustle execution
  bool startHustle(HustleJob job) {
    if (user.energy < job.energyCost) {
      return false; // Not enough energy
    }
    if (activeHustleCooldowns.containsKey(job.id)) {
      return false; // In progress
    }

    user.energy -= job.energyCost;
    user.walletBalance += job.coinReward;
    user.xp += 30;

    // Level up check
    if (user.xp >= user.level * 150) {
      user.level += 1;
      user.maxEnergy += 10;
      user.energy = user.maxEnergy;
      if (user.level >= 5) {
        user.title = 'Lagos Baller & Big Spender';
      } else if (user.level >= 4) {
        user.title = 'Certified Lekki Resident';
      }
    }

    activeHustleCooldowns[job.id] = job.durationSeconds;

    final currentUserId = SupabaseService().currentUser?.id;
    if (currentUserId != null && SupabaseService().isConfigured) {
      SupabaseService().completeHustleRPC(
        userId: currentUserId,
        energyCost: job.energyCost,
        coinReward: job.coinReward,
        jobId: job.id,
      );
    }

    LocalPersistenceService().saveUser(user);
    notifyListeners();
    return true;
  }

  // Shop & Inventory
  bool purchaseItem(ShopItem item) {
    if (user.walletBalance < item.tokenCost) {
      return false; // Insufficient funds
    }
    user.walletBalance -= item.tokenCost;
    inventory[item.id] = (inventory[item.id] ?? 0) + 1;

    final currentUserId = SupabaseService().currentUser?.id;
    if (currentUserId != null && SupabaseService().isConfigured) {
      SupabaseService().client?.from('profiles').update({
        'wallet_balance': user.walletBalance,
      }).eq('id', currentUserId);
    }

    LocalPersistenceService().saveUser(user);
    notifyListeners();
    return true;
  }

  // SparkSync Mall Customization Checkout
  Future<bool> purchaseCustomizationItem(ShopItem item, {bool autoEquip = true}) async {
    if (user.walletBalance < item.tokenCost) {
      return false; // Insufficient credits
    }
    user.walletBalance -= item.tokenCost;
    inventory[item.id] = (inventory[item.id] ?? 0) + 1;

    if (item.category == ItemCategory.profileFlair && autoEquip) {
      user.equippedFlair = item.id;
      user.equippedItemIds.add(item.id);
    } else if (item.category == ItemCategory.roomPass) {
      user.equippedItemIds.add(item.id);
    }

    // Award Social Clout XP
    user.xp += 100;

    final currentUserId = SupabaseService().currentUser?.id;
    if (currentUserId != null && SupabaseService().isConfigured) {
      await SupabaseService().purchaseCustomizationRPC(
        userId: currentUserId,
        itemId: item.id,
        autoEquip: autoEquip,
      );
    }

    notifyListeners();
    return true;
  }

  String? currentActiveRoomId;

  void enterTwoGoRoom(String roomId) {
    currentActiveRoomId = roomId;
    // If user is offline (stealth/appear offline), do not increment room count
    if (user.presence == TwoGoPresence.offline) {
      notifyListeners();
      return;
    }

    final roomIdx = twoGoRooms.indexWhere((r) => r.id == roomId);
    if (roomIdx != -1) {
      final old = twoGoRooms[roomIdx];
      final nextList = List<TwoGoChatRoom>.from(twoGoRooms);
      nextList[roomIdx] = old.copyWith(
        activeOnline: old.activeOnline + 1,
      );
      twoGoRooms = nextList;
      notifyListeners();
    }
  }

  void leaveTwoGoRoom(String roomId) {
    if (currentActiveRoomId == roomId) {
      currentActiveRoomId = null;
    }
    if (user.presence == TwoGoPresence.offline) {
      notifyListeners();
      return;
    }

    final roomIdx = twoGoRooms.indexWhere((r) => r.id == roomId);
    if (roomIdx != -1) {
      final old = twoGoRooms[roomIdx];
      final nextList = List<TwoGoChatRoom>.from(twoGoRooms);
      nextList[roomIdx] = old.copyWith(
        activeOnline: (old.activeOnline - 1).clamp(0, 9999),
      );
      twoGoRooms = nextList;
      notifyListeners();
    }
  }

  void updateUserPresence(TwoGoPresence newPresence) {
    final oldPresence = user.presence;
    if (oldPresence == newPresence) return;

    user.presence = newPresence;

    // If currently inside an active room, reflect presence change in online count
    if (currentActiveRoomId != null) {
      final roomIdx = twoGoRooms.indexWhere((r) => r.id == currentActiveRoomId);
      if (roomIdx != -1) {
        final old = twoGoRooms[roomIdx];
        final nextList = List<TwoGoChatRoom>.from(twoGoRooms);
        if (newPresence == TwoGoPresence.offline && oldPresence != TwoGoPresence.offline) {
          // Went into stealth/offline: decrement
          nextList[roomIdx] = old.copyWith(
            activeOnline: (old.activeOnline - 1).clamp(0, 9999),
          );
          twoGoRooms = nextList;
        } else if (oldPresence == TwoGoPresence.offline && newPresence != TwoGoPresence.offline) {
          // Came online while in room: increment
          nextList[roomIdx] = old.copyWith(
            activeOnline: old.activeOnline + 1,
          );
          twoGoRooms = nextList;
        }
      }
    }

    notifyListeners();
  }

  void updateStatusText(String newStatus) {
    user.statusText = newStatus;
    notifyListeners();
  }

  void updateRoomLatestMessage(String roomId, String latestMessage) {
    final roomIdx = twoGoRooms.indexWhere((r) => r.id == roomId);
    if (roomIdx != -1) {
      final old = twoGoRooms[roomIdx];
      final nextList = List<TwoGoChatRoom>.from(twoGoRooms);
      nextList[roomIdx] = old.copyWith(latestMessage: latestMessage);
      twoGoRooms = nextList;
      _saveLatestSnippets();
      notifyListeners();
    }
  }

  Future<void> verifyUserSelfie({
    required String avatarEmoji,
    String? photoUrl,
    String? avatarCartoonUrl,
    String? equippedFlair,
    AvatarFeatureProfile? avatarProfile,
    String? title,
  }) async {
    user.isVerified = true;
    user.avatarEmoji = (avatarEmoji == '👑' || avatarEmoji.isEmpty) ? '👨🏾‍💼' : avatarEmoji;
    user.verifiedPhotoUrl = photoUrl;
    if (avatarProfile != null) {
      if (avatarProfile.skinTone.isNotEmpty) {
        user.avatarSkinTone = avatarProfile.skinTone;
      }
      user.avatarHasBeard = avatarProfile.facialHair.contains('beard') || avatarProfile.facialHair.contains('goatee');
      user.avatarHasGlasses = avatarProfile.accessories.contains('glasses') || avatarProfile.accessories.contains('shades') || true;
      if (avatarProfile.hairStyle.isNotEmpty) {
        user.avatarHairStyle = avatarProfile.hairStyle;
      }
    }
    if (avatarCartoonUrl != null) {
      user.avatarCartoonUrl = avatarCartoonUrl;
    }
    user.verifiedAt = DateTime.now();
    if (title != null && title.isNotEmpty) {
      user.title = title;
    }
    if (equippedFlair != null) {
      user.equippedFlair = equippedFlair;
    }
    // Grant verification bonus (+150 XP and +150 Spark Coins/Credits)
    user.xp += 150;
    user.walletBalance += 150;

    // Persist immediately to local storage
    await LocalPersistenceService().saveUser(user);

    // Sync to Supabase
    final supa = SupabaseService();
    if (supa.isConfigured && supa.currentUser != null) {
      await supa.syncVerifiedAvatar(
        userId: supa.currentUser!.id,
        avatarEmoji: avatarEmoji,
        photoUrl: photoUrl ?? '',
        avatarProfile: avatarProfile?.toJson(),
        vibeTitle: title ?? user.title,
        xp: user.xp,
        walletBalance: user.walletBalance,
      );
    }
    notifyListeners();
  }

  void updateAvatarTraits({
    bool? glasses,
    bool? beard,
    String? skin,
    String? hair,
    String? outfit,
  }) {
    if (glasses != null) user.avatarHasGlasses = glasses;
    if (beard != null) user.avatarHasBeard = beard;
    if (skin != null) user.avatarSkinTone = skin;
    if (hair != null) user.avatarHairStyle = hair;
    if (outfit != null) user.avatarOutfit = outfit;
    user.avatarCartoonUrl = null;
    LocalPersistenceService().saveUser(user);
    notifyListeners();
  }

  void refillEnergy({int amount = 30}) {
    user.energy = (user.energy + amount).clamp(0, user.maxEnergy);
    LocalPersistenceService().saveUser(user);
    notifyListeners();
  }

  void consumeEnergy(int amount) {
    user.energy = (user.energy - amount).clamp(0, user.maxEnergy);
    LocalPersistenceService().saveUser(user);
    notifyListeners();
  }

  void updateProfileDetails({
    String? username,
    String? title,
    String? neighborhood,
    String? statusText,
  }) {
    if (username != null && username.trim().isNotEmpty) {
      user.username = username.trim();
    }
    if (title != null && title.trim().isNotEmpty) {
      user.title = title.trim();
    }
    if (neighborhood != null && neighborhood.trim().isNotEmpty) {
      user.neighborhood = neighborhood.trim();
    }
    if (statusText != null && statusText.trim().isNotEmpty) {
      user.statusText = statusText.trim();
    }

    final supa = SupabaseService();
    if (supa.isConfigured && supa.currentUser != null) {
      try {
        supa.client?.from('profiles').update({
          'username': user.username,
          'title': user.title,
          'neighborhood': user.neighborhood,
        }).eq('id', supa.currentUser!.id);
      } catch (_) {}
    }
    notifyListeners();
  }

  // SparkSync Chatroom Messaging & Governance
  String? sendTwoGoMessage(String roomId, String text) {
    if (text.trim().isEmpty) return null;

    // Check mute
    if (isUserMuted) {
      if (muteExpiry != null && DateTime.now().isBefore(muteExpiry!)) {
        final remaining = muteExpiry!.difference(DateTime.now()).inMinutes + 1;
        return 'You are muted for $remaining more minutes due to room policy violation.';
      } else {
        isUserMuted = false;
        muteExpiry = null;
      }
    }

    // Flood & Spam Protection (>4 messages within 3 seconds triggers auto-kick)
    final now = DateTime.now();
    _recentMessageTimestamps.removeWhere((t) => now.difference(t).inSeconds > 3);
    if (_recentMessageTimestamps.length >= 4) {
      isUserMuted = true;
      muteExpiry = now.add(const Duration(minutes: 5));
      notifyListeners();
      return 'SYSTEM BOT: Flood detected! (>4 msgs in 3s). You have been auto-muted for 5 minutes.';
    }
    _recentMessageTimestamps.add(now);

    final list = twoGoRoomChats[roomId] ?? [];
    final currentUserId = SupabaseService().currentUser?.id ?? 'user_${now.millisecondsSinceEpoch}';
    final newMsg = TwoGoRoomMessage(
      id: 'tg_${now.millisecondsSinceEpoch}',
      roomId: roomId,
      senderId: currentUserId,
      senderName: user.username,
      senderAvatar: user.avatarEmoji,
      senderRank: user.starRank,
      hasNeonGlow: user.equippedFlair == 'neon_night_glow',
      statusText: user.statusText,
      text: text.trim(),
      timestamp: now,
      isUser: true,
    );
    list.add(newMsg);
    // Option C: Rolling 25-message buffer
    final rolling = list.length > 25 ? list.sublist(list.length - 25) : list;
    twoGoRoomChats[roomId] = rolling;

    // Update room card snippet dynamically
    updateRoomLatestMessage(roomId, '${user.username}: "${text.trim()}"');

    // Active grind XP (+15 XP per room message)
    user.xp += 15;

    // Persist room messages and user stats locally immediately
    LocalPersistenceService().saveRoomMessages(roomId, rolling);
    LocalPersistenceService().saveUser(user);

    // Stream to Supabase
    if (SupabaseService().currentUser != null && SupabaseService().isConfigured) {
      SupabaseService().sendRoomMessage(
        roomId: roomId,
        senderId: currentUserId,
        senderName: user.username,
        senderAvatar: user.avatarEmoji,
        senderRank: user.starRank.name,
        text: text.trim(),
        hasNeonGlow: user.equippedFlair == 'neon_night_glow',
      );
    }

    notifyListeners();
    return null;
  }

  bool buyRoundOfDrinks(String roomId) {
    if (user.walletBalance < 50) return false;
    user.walletBalance -= 50;
    user.totalGiftsSent += 1;
    user.xp += 150; // Big Clout XP!

    final list = twoGoRoomChats[roomId] ?? [];
    list.add(TwoGoRoomMessage(
      id: 'ann_${DateTime.now().millisecondsSinceEpoch}',
      roomId: roomId,
      senderId: 'user_tunde',
      senderName: user.username,
      senderAvatar: '🍾',
      senderRank: user.starRank,
      hasNeonGlow: true,
      text: '🍾 VIP ANNOUNCEMENT: ${user.username} [${user.starRank.badgeTitle}] has just bought a round of virtual drinks for everyone in the room! 🥂✨',
      timestamp: DateTime.now(),
      isAnnouncement: true,
      isUser: true,
    ));
    final rolling = list.length > 25 ? list.sublist(list.length - 25) : list;
    twoGoRoomChats[roomId] = rolling;

    LocalPersistenceService().saveRoomMessages(roomId, rolling);
    LocalPersistenceService().saveUser(user);

    notifyListeners();
    return true;
  }

  bool sendDrinkToUser(String roomId, String targetUserName) {
    if (user.walletBalance < 50) return false;
    user.walletBalance -= 50;
    user.totalGiftsSent += 1;
    user.xp += 80;

    final list = twoGoRoomChats[roomId] ?? [];
    list.add(TwoGoRoomMessage(
      id: 'drink_${DateTime.now().millisecondsSinceEpoch}',
      roomId: roomId,
      senderId: 'user_tunde',
      senderName: user.username,
      senderAvatar: '🍸',
      senderRank: user.starRank,
      hasNeonGlow: user.equippedFlair == 'neon_night_glow',
      text: '🍸 PING: ${user.username} sent a chilled cocktail to $targetUserName! Cheers! 🥂',
      timestamp: DateTime.now(),
      isAnnouncement: true,
      isUser: true,
    ));
    final rolling = list.length > 25 ? list.sublist(list.length - 25) : list;
    twoGoRoomChats[roomId] = rolling;

    LocalPersistenceService().saveRoomMessages(roomId, rolling);
    LocalPersistenceService().saveUser(user);

    notifyListeners();
    return true;
  }

  // Decentralized Governance & Moderation
  void issueModeratorWarning(String roomId, String targetUserName) {
    final list = twoGoRoomChats[roomId] ?? [];
    list.add(TwoGoRoomMessage(
      id: 'warn_${DateTime.now().millisecondsSinceEpoch}',
      roomId: roomId,
      senderId: 'mod_bot',
      senderName: 'Room Moderator',
      senderAvatar: '🛡️',
      senderRank: TwoGoStarRank.professional,
      text: '⚠️ VERBAL WARNING: $targetUserName, please adhere to room rules and maintain good vibes.',
      timestamp: DateTime.now(),
      isAnnouncement: true,
      isSystem: true,
    ));
    final rolling = list.length > 25 ? list.sublist(list.length - 25) : list;
    twoGoRoomChats[roomId] = rolling;
    LocalPersistenceService().saveRoomMessages(roomId, rolling);
    notifyListeners();
  }

  void moderatorKickUser(String roomId, String targetUserName, {required String actionId}) {
    final list = twoGoRoomChats[roomId] ?? [];
    list.add(TwoGoRoomMessage(
      id: 'kick_${DateTime.now().millisecondsSinceEpoch}',
      roomId: roomId,
      senderId: 'mod_bot',
      senderName: 'Room Moderator',
      senderAvatar: '👢',
      senderRank: TwoGoStarRank.veteran,
      text: '👢 KICK NOTICE: $targetUserName was kicked from the room by Moderator. Tap to object if unfair.',
      timestamp: DateTime.now(),
      isAnnouncement: true,
      isSystem: true,
    ));
    final rolling = list.length > 25 ? list.sublist(list.length - 25) : list;
    twoGoRoomChats[roomId] = rolling;
    LocalPersistenceService().saveRoomMessages(roomId, rolling);
    moderationObjections[actionId] = 0;
    notifyListeners();
  }

  bool objectToModeratorAction(String actionId) {
    final current = moderationObjections[actionId] ?? 0;
    moderationObjections[actionId] = current + 1;
    if (moderationObjections[actionId]! >= 10) {
      notifyListeners();
      return true;
    }
    notifyListeners();
    return false;
  }

  // ==========================================
  // AFROBEAT VIBE ROOM GAMIFIED DJ & DRUM PAD
  // ==========================================

  /// Triggers a live beat/sample from the Afrobeat drum pad overlay.
  /// Deducts micro-credits, plays audio with zero latency, and broadcasts to room.
  String? triggerAfrobeatPad(String sampleId) {
    const padCosts = {
      'kick': 1,
      'conga': 1,
      'bell': 1,
      'sheesh': 2,
      'sax': 2,
      'airhorn': 5,
    };

    final cost = padCosts[sampleId.toLowerCase()] ?? 1;
    if (user.walletBalance < cost) {
      return 'Need $cost 🪙 to drop this sample! Complete hustles or check in to earn.';
    }

    // Deduct cost and award participation XP
    user.walletBalance -= cost;
    user.xp += 5;

    // Trigger instant local audio playback + haptics
    SoundService().playAfrobeatSample(sampleId);

    // Human-readable sample labels for room broadcast
    final sampleLabels = {
      'kick': '🥁 dropped a HEAVY LOG DRUM! 💥',
      'conga': '🪘 dropped a CONGA BEAT! ✨',
      'sheesh': '🗣️ shouted "SHEEEESH!" 🚀',
      'sax': '🎷 played a SWEET SAX LICK! 🎶',
      'bell': '🔔 struck the AGÔGO BELL! 🔔',
      'airhorn': '📣 blasted the CLUB AIRHORN! 🔥🔥🔥',
    };
    final actionLabel = sampleLabels[sampleId.toLowerCase()] ?? '🎶 played an ad-lib!';

    // Insert live beat event into Afrobeat room chat
    final roomId = 'room_afrobeat_vibes';
    final list = twoGoRoomChats[roomId] ?? [];
    final now = DateTime.now();
    final currentUserId = SupabaseService().currentUser?.id ?? 'user_${now.millisecondsSinceEpoch}';

    final beatMsg = TwoGoRoomMessage(
      id: 'beat_${now.millisecondsSinceEpoch}',
      roomId: roomId,
      senderId: currentUserId,
      senderName: user.username,
      senderAvatar: user.avatarEmoji,
      senderRank: user.starRank,
      hasNeonGlow: true,
      text: '$actionLabel (-$cost 🪙)',
      timestamp: now,
      isAnnouncement: true,
      isUser: true,
    );

    list.add(beatMsg);
    final rolling = list.length > 25 ? list.sublist(list.length - 25) : list;
    twoGoRoomChats[roomId] = rolling;
    updateRoomLatestMessage(roomId, '${user.username}: $actionLabel');

    // Persist changes
    LocalPersistenceService().saveRoomMessages(roomId, rolling);
    LocalPersistenceService().saveUser(user);

    // Broadcast over Supabase if connected
    if (SupabaseService().currentUser != null && SupabaseService().isConfigured) {
      SupabaseService().sendRoomMessage(
        roomId: roomId,
        senderId: currentUserId,
        senderName: user.username,
        senderAvatar: user.avatarEmoji,
        senderRank: user.starRank.name,
        text: actionLabel,
        hasNeonGlow: true,
        isAnnouncement: true,
      );
    }

    notifyListeners();
    return null;
  }

  /// Crowd tap: 🔥 HYPE the current DJ!
  void hypeAfrobeatDj() {
    afrobeatHypeCount++;
    afrobeatHypeProgress = (afrobeatHypeProgress + 0.05).clamp(0.0, 1.0);
    user.xp += 5;

    // Instant celebratory audio chime
    SoundService().playAfrobeatSample('cheer');

    // If current DJ is this user, reward passive XP and credits tips
    if (afrobeatDjName.contains(user.username)) {
      user.walletBalance += 2;
      user.xp += 15;
    }

    // Milestone announcement every 25 hypes
    if (afrobeatHypeCount % 25 == 0) {
      final roomId = 'room_afrobeat_vibes';
      final list = twoGoRoomChats[roomId] ?? [];
      final hypeMsg = TwoGoRoomMessage(
        id: 'hype_${DateTime.now().millisecondsSinceEpoch}',
        roomId: roomId,
        senderId: 'bot_hype',
        senderName: 'Party Bot',
        senderAvatar: '🔥',
        senderRank: TwoGoStarRank.master,
        hasNeonGlow: true,
        text: '🔥 CROWD HYPE: $afrobeatDjName is tearing down the decks! ${(afrobeatHypeProgress * 100).toInt()}% Hype for "$afrobeatTrackTitle"!',
        timestamp: DateTime.now(),
        isAnnouncement: true,
        isSystem: true,
      );
      list.add(hypeMsg);
      final rolling = list.length > 25 ? list.sublist(list.length - 25) : list;
      twoGoRoomChats[roomId] = rolling;
      LocalPersistenceService().saveRoomMessages(roomId, rolling);
    }

    LocalPersistenceService().saveUser(user);
    notifyListeners();
  }

  /// Crowd tap: 👎 BOO the current DJ! If boo reaches 60% or hype hits 0%, kick DJ off stage!
  void booAfrobeatDj() {
    afrobeatBooCount++;
    afrobeatHypeProgress = (afrobeatHypeProgress - 0.12).clamp(0.0, 1.0);

    // If hype drops below 0.05 or boo count reaches 8, trigger record scratch and stage kickout!
    if (afrobeatHypeProgress <= 0.05 || afrobeatBooCount >= 8) {
      rotateAfrobeatDj(wasBooed: true);
    } else {
      SoundService().playAfrobeatSample('scratch');
      notifyListeners();
    }
  }

  /// Rotates DJ deck to next DJ in queue or spins next resident DJ
  void rotateAfrobeatDj({bool wasBooed = false}) {
    final oldDj = afrobeatDjName;
    SoundService().playAfrobeatSample('scratch');

    if (afrobeatDjQueue.isNotEmpty) {
      final next = afrobeatDjQueue.removeAt(0);
      afrobeatDjName = next['name'] ?? 'Guest DJ';
      afrobeatDjAvatar = next['avatar'] ?? '🎧';
      afrobeatDjRank = next['rank'] ?? 'Master Rank';
      afrobeatTrackTitle = next['track'] ?? 'Burna Boy - City Boys (Loop)';
    } else {
      // Cycle resident AI DJs
      if (oldDj.contains('Chinedu')) {
        afrobeatDjName = 'DJ Spinall 🎧';
        afrobeatTrackTitle = 'Asake - Lonely At The Top (Log Drum Cut)';
      } else if (oldDj.contains('Spinall')) {
        afrobeatDjName = 'DJ Cuppy 🎀';
        afrobeatTrackTitle = 'Rema - Calm Down (Vibe Rhythms)';
      } else if (oldDj.contains('Cuppy')) {
        afrobeatDjName = 'DJ Neptune 🌊';
        afrobeatTrackTitle = 'Ayra Starr - Rush (Groove Edition)';
      } else {
        afrobeatDjName = 'DJ Chinedu 👑';
        afrobeatTrackTitle = 'Burna Boy - City Boys (Loop)';
      }
      afrobeatDjAvatar = '🎧';
      afrobeatDjRank = 'Master Rank';
    }

    afrobeatHypeProgress = 0.80;
    afrobeatBooCount = 0;
    afrobeatHypeCount = 40;

    final roomId = 'room_afrobeat_vibes';
    final list = twoGoRoomChats[roomId] ?? [];
    final text = wasBooed
        ? '🚨 RECORD SCRATCH! $oldDj was BOOED OFF the stage! 😂 The crowd demanded better vibes! Next up: $afrobeatDjName spinning "$afrobeatTrackTitle"!'
        : '🎧 DECK ROTATION: $afrobeatDjName is now live on the decks spinning "$afrobeatTrackTitle"! Drop your beats!';

    final rotationMsg = TwoGoRoomMessage(
      id: 'rot_${DateTime.now().millisecondsSinceEpoch}',
      roomId: roomId,
      senderId: 'bot_dj',
      senderName: 'Party Host',
      senderAvatar: '🎧',
      senderRank: TwoGoStarRank.master,
      hasNeonGlow: true,
      text: text,
      timestamp: DateTime.now(),
      isAnnouncement: true,
      isSystem: true,
    );

    list.add(rotationMsg);
    final rolling = list.length > 25 ? list.sublist(list.length - 25) : list;
    twoGoRoomChats[roomId] = rolling;
    updateRoomLatestMessage(roomId, 'Party Host: $text');
    LocalPersistenceService().saveRoomMessages(roomId, rolling);

    notifyListeners();
  }

  /// Spend 20 Credits to join the DJ Queue and choose a track
  String? joinAfrobeatDjQueue(String trackTitle) {
    if (user.walletBalance < 20) {
      return 'Need at least 20 🪙 to take the DJ Decks! Grind hustles to earn credits.';
    }

    user.walletBalance -= 20;
    user.xp += 50;

    final roomId = 'room_afrobeat_vibes';
    final list = twoGoRoomChats[roomId] ?? [];
    final now = DateTime.now();

    // If current DJ is a resident bot, take over the stage immediately!
    final isBotDj = afrobeatDjName.contains('DJ Chinedu') ||
        afrobeatDjName.contains('DJ Spinall') ||
        afrobeatDjName.contains('DJ Cuppy') ||
        afrobeatDjName.contains('DJ Neptune');

    if (isBotDj && afrobeatDjQueue.isEmpty) {
      afrobeatDjName = '${user.username} 👑';
      afrobeatDjAvatar = user.avatarEmoji;
      afrobeatDjRank = user.starRank.rankName;
      afrobeatTrackTitle = trackTitle;
      afrobeatHypeProgress = 0.85;
      afrobeatBooCount = 0;
      afrobeatHypeCount = 50;

      final takeoverMsg = TwoGoRoomMessage(
        id: 'takeover_${now.millisecondsSinceEpoch}',
        roomId: roomId,
        senderId: SupabaseService().currentUser?.id ?? 'user_local',
        senderName: user.username,
        senderAvatar: user.avatarEmoji,
        senderRank: user.starRank,
        hasNeonGlow: true,
        text: '👑 STAGE TAKEOVER: ${user.username} is now ON THE DECKS spinning "$trackTitle"! Tap 🔥 HYPE or 👎 BOO!',
        timestamp: now,
        isAnnouncement: true,
        isUser: true,
      );
      list.add(takeoverMsg);
    } else {
      afrobeatDjQueue.add({
        'name': '${user.username} 👑',
        'avatar': user.avatarEmoji,
        'rank': user.starRank.rankName,
        'track': trackTitle,
      });

      final queueMsg = TwoGoRoomMessage(
        id: 'queue_${now.millisecondsSinceEpoch}',
        roomId: roomId,
        senderId: SupabaseService().currentUser?.id ?? 'user_local',
        senderName: user.username,
        senderAvatar: user.avatarEmoji,
        senderRank: user.starRank,
        hasNeonGlow: true,
        text: '🎧 ${user.username} joined the DJ Queue at position #${afrobeatDjQueue.length} with "$trackTitle"!',
        timestamp: now,
        isAnnouncement: true,
        isUser: true,
      );
      list.add(queueMsg);
    }

    final rolling = list.length > 25 ? list.sublist(list.length - 25) : list;
    twoGoRoomChats[roomId] = rolling;
    LocalPersistenceService().saveRoomMessages(roomId, rolling);
    LocalPersistenceService().saveUser(user);

    SoundService().playCoinEarned();
    notifyListeners();
    return null;
  }

  // ==========================================
  // AFROBEAT LIVE KARAOKE LOUNGE & APPLAUSE
  // ==========================================

  void setMoneyRainActive(bool active) {
    isMoneyRainActive = active;
    notifyListeners();
  }

  /// Free dopamine tap: 👏 Audience Claps for the active singer
  void clapForKaraokeSinger() {
    karaokeClapCount++;
    // If singer is current user, award them performance XP
    if (karaokeSingerName.contains(user.username)) {
      user.xp += 10;
    }

    // Every 25 claps or milestone, play celebratory cheer sound
    if (karaokeClapCount % 25 == 0) {
      SoundService().playAfrobeatSample('cheer');
      final roomId = 'room_afrobeat_vibes';
      final list = twoGoRoomChats[roomId] ?? [];
      final cheerMsg = TwoGoRoomMessage(
        id: 'clap_${DateTime.now().millisecondsSinceEpoch}',
        roomId: roomId,
        senderId: 'bot_host',
        senderName: 'Lounge Host',
        senderAvatar: '👏',
        senderRank: TwoGoStarRank.master,
        hasNeonGlow: true,
        text: '👏 MASSIVE APPLAUSE: The crowd reached $karaokeClapCount claps for $karaokeSingerName singing "${karaokeCurrentTrack.title}"! 🔥',
        timestamp: DateTime.now(),
        isAnnouncement: true,
        isSystem: true,
      );
      list.add(cheerMsg);
      final rolling = list.length > 25 ? list.sublist(list.length - 25) : list;
      twoGoRoomChats[roomId] = rolling;
      LocalPersistenceService().saveRoomMessages(roomId, rolling);
    }

    notifyListeners();
  }

  /// Spray Naira (50 Credits): 70% deposited directly to Singer's wallet balance (35 🪙),
  /// 30% house cut (15 🪙), Spender gains +100 Clout XP, Singer gains +120 XP!
  String? sprayNairaOnSinger() {
    const fee = 50;
    if (user.walletBalance < fee) {
      return 'Need at least 50 🪙 to spray Naira on stage! Complete hustles to fund your balling.';
    }

    // Deduct fee and award spender Clout XP
    user.walletBalance -= fee;
    user.xp += 100;
    user.totalGiftsSent += 1;
    karaokeSprayedNairaTotal += fee;

    // 70% Revenue Split: 35 Credits to Singer
    const singerPayout = 35;
    if (karaokeSingerName.contains(user.username)) {
      // User is singing on stage! Deposit directly into active balance
      user.walletBalance += singerPayout;
      user.xp += 120;
    }

    isMoneyRainActive = true;
    SoundService().playCoinEarned();

    final roomId = 'room_afrobeat_vibes';
    final list = twoGoRoomChats[roomId] ?? [];
    final now = DateTime.now();

    final sprayMsg = TwoGoRoomMessage(
      id: 'spray_${now.millisecondsSinceEpoch}',
      roomId: roomId,
      senderId: SupabaseService().currentUser?.id ?? 'user_local',
      senderName: user.username,
      senderAvatar: '💸',
      senderRank: user.starRank,
      hasNeonGlow: true,
      text: '💸 [SPRAYS NAIRA]: ${user.username} sprayed 50 Credits on $karaokeSingerName! (+$singerPayout 🪙 directly deposited to singer) 💵✨',
      timestamp: now,
      isAnnouncement: true,
      isUser: true,
    );

    list.add(sprayMsg);
    final rolling = list.length > 25 ? list.sublist(list.length - 25) : list;
    twoGoRoomChats[roomId] = rolling;
    updateRoomLatestMessage(roomId, '${user.username} sprayed 50 Credits on $karaokeSingerName! 💸');

    LocalPersistenceService().saveRoomMessages(roomId, rolling);
    LocalPersistenceService().saveUser(user);

    if (SupabaseService().currentUser != null && SupabaseService().isConfigured) {
      SupabaseService().sendRoomMessage(
        roomId: roomId,
        senderId: SupabaseService().currentUser!.id,
        senderName: user.username,
        senderAvatar: '💸',
        senderRank: user.starRank.name,
        text: '💸 ${user.username} sprayed 50 Credits on $karaokeSingerName! (+35 🪙) 💵',
        hasNeonGlow: true,
        isAnnouncement: true,
      );
    }

    notifyListeners();
    return null;
  }

  /// Buy Singer a Cocktail (50 Credits, sends virtual drink, +150 XP)
  String? buySingerCocktail() {
    const fee = 50;
    if (user.walletBalance < fee) {
      return 'Need at least 50 🪙 for a signature cocktail!';
    }

    user.walletBalance -= fee;
    user.xp += 150;
    user.totalGiftsSent += 1;

    SoundService().playCoinEarned();

    final roomId = 'room_afrobeat_vibes';
    final list = twoGoRoomChats[roomId] ?? [];
    final now = DateTime.now();

    final drinkMsg = TwoGoRoomMessage(
      id: 'drink_${now.millisecondsSinceEpoch}',
      roomId: roomId,
      senderId: SupabaseService().currentUser?.id ?? 'user_local',
      senderName: user.username,
      senderAvatar: '🍹',
      senderRank: user.starRank,
      hasNeonGlow: true,
      text: '🍹 [VIP COCKTAIL]: ${user.username} sent a chilled signature cocktail to $karaokeSingerName on stage! 🥂✨',
      timestamp: now,
      isAnnouncement: true,
      isUser: true,
    );

    list.add(drinkMsg);
    final rolling = list.length > 25 ? list.sublist(list.length - 25) : list;
    twoGoRoomChats[roomId] = rolling;

    LocalPersistenceService().saveRoomMessages(roomId, rolling);
    LocalPersistenceService().saveUser(user);

    notifyListeners();
    return null;
  }

  /// Spend 30 Credits to request a song and join the Karaoke Mic Queue
  String? joinKaraokeMicQueue(KaraokeTrack track) {
    const fee = 30;
    if (user.walletBalance < fee) {
      return 'Need at least 30 🪙 to request a song and take the Mic!';
    }

    user.walletBalance -= fee;
    user.xp += 60;

    final roomId = 'room_afrobeat_vibes';
    final list = twoGoRoomChats[roomId] ?? [];
    final now = DateTime.now();

    // If current singer is a resident bot, take over the stage immediately!
    final isBotSinger = karaokeSingerName.contains('Tunde') ||
        karaokeSingerName.contains('Amaka') ||
        karaokeSingerName.contains('Chinedu');

    if (isBotSinger && karaokeMicQueue.isEmpty) {
      karaokeSingerName = '${user.username} 👑';
      karaokeSingerAvatar = user.avatarEmoji;
      karaokeSingerRank = user.starRank.rankName;
      karaokeSingerId = SupabaseService().currentUser?.id ?? 'user_local';
      karaokeCurrentTrack = track;
      karaokeElapsedSeconds = 0;

      final stageMsg = TwoGoRoomMessage(
        id: 'mic_takeover_${now.millisecondsSinceEpoch}',
        roomId: roomId,
        senderId: SupabaseService().currentUser?.id ?? 'user_local',
        senderName: user.username,
        senderAvatar: '🎤',
        senderRank: user.starRank,
        hasNeonGlow: true,
        text: '🎤 [STAGE TAKEOVER]: ${user.username} is now on the Karaoke Stage singing "${track.title}"! Show love or spray Naira! 🎶✨',
        timestamp: now,
        isAnnouncement: true,
        isUser: true,
      );
      list.add(stageMsg);
    } else {
      karaokeMicQueue.add({
        'name': '${user.username} 👑',
        'avatar': user.avatarEmoji,
        'rank': user.starRank.rankName,
        'trackId': track.id,
        'trackTitle': track.title,
      });

      final queueMsg = TwoGoRoomMessage(
        id: 'mic_queue_${now.millisecondsSinceEpoch}',
        roomId: roomId,
        senderId: SupabaseService().currentUser?.id ?? 'user_local',
        senderName: user.username,
        senderAvatar: '🎤',
        senderRank: user.starRank,
        hasNeonGlow: true,
        text: '🎤 ${user.username} signed up on the Mic Queue (#${karaokeMicQueue.length} in line) for "${track.title}"!',
        timestamp: now,
        isAnnouncement: true,
        isUser: true,
      );
      list.add(queueMsg);
    }

    final rolling = list.length > 25 ? list.sublist(list.length - 25) : list;
    twoGoRoomChats[roomId] = rolling;
    LocalPersistenceService().saveRoomMessages(roomId, rolling);
    LocalPersistenceService().saveUser(user);

    SoundService().playCoinEarned();
    notifyListeners();
    return null;
  }

  /// Rotates singer when current song completes
  void rotateKaraokeSinger() {
    karaokeElapsedSeconds = 0;
    if (karaokeMicQueue.isNotEmpty) {
      final next = karaokeMicQueue.removeAt(0);
      karaokeSingerName = next['name'] ?? 'Guest Singer';
      karaokeSingerAvatar = next['avatar'] ?? '🎤';
      karaokeSingerRank = next['rank'] ?? 'Master';
      final trackId = next['trackId'] ?? 'wizkid_essence';
      karaokeCurrentTrack = KaraokeTrack.curatedTracks.firstWhere(
        (t) => t.id == trackId,
        orElse: () => KaraokeTrack.curatedTracks[0],
      );
    } else {
      // Rotate resident AI singers
      if (karaokeSingerName.contains('Tunde')) {
        karaokeSingerName = 'Amaka 🎤';
        karaokeSingerAvatar = '💁‍♀️';
        karaokeSingerRank = 'Expert';
        karaokeCurrentTrack = KaraokeTrack.curatedTracks[1]; // Burna Boy - Last Last
      } else if (karaokeSingerName.contains('Amaka')) {
        karaokeSingerName = 'Chinedu 🌟';
        karaokeSingerAvatar = '😎';
        karaokeSingerRank = 'Veteran';
        karaokeCurrentTrack = KaraokeTrack.curatedTracks[2]; // Asake - Lonely At The Top
      } else {
        karaokeSingerName = 'Tunde 👑';
        karaokeSingerAvatar = '🎤';
        karaokeSingerRank = 'Master';
        karaokeCurrentTrack = KaraokeTrack.curatedTracks[0]; // Wizkid - Essence
      }
    }

    final roomId = 'room_afrobeat_vibes';
    final list = twoGoRoomChats[roomId] ?? [];
    final rotateMsg = TwoGoRoomMessage(
      id: 'k_rot_${DateTime.now().millisecondsSinceEpoch}',
      roomId: roomId,
      senderId: 'bot_host',
      senderName: 'Lounge Host',
      senderAvatar: '🎤',
      senderRank: TwoGoStarRank.master,
      hasNeonGlow: true,
      text: '🎤 NEXT SINGER: $karaokeSingerName just took the mic singing "${karaokeCurrentTrack.title}"! Clap or spray Naira! 🎶',
      timestamp: DateTime.now(),
      isAnnouncement: true,
      isSystem: true,
    );
    list.add(rotateMsg);
    final rolling = list.length > 25 ? list.sublist(list.length - 25) : list;
    twoGoRoomChats[roomId] = rolling;
    LocalPersistenceService().saveRoomMessages(roomId, rolling);

    notifyListeners();
  }

  bool useConsumable(ShopItem item) {
    final count = inventory[item.id] ?? 0;
    if (count <= 0) return false;

    inventory[item.id] = count - 1;
    if (inventory[item.id] == 0) {
      inventory.remove(item.id);
    }

    user.energy = min(user.maxEnergy, user.energy + item.energyBoost);
    notifyListeners();
    return true;
  }

  void toggleEquipItem(String itemId) {
    if (user.equippedItemIds.contains(itemId)) {
      user.equippedItemIds.remove(itemId);
    } else {
      user.equippedItemIds.add(itemId);
    }
    notifyListeners();
  }

  // Matchmaking & SparkDeck
  bool swipeProfile(MatchProfile profile, bool isSpark, {ShopItem? superSparkGift}) {
    if (isSpark) {
      if (user.energy < 5) return false;
      user.energy -= 5;
    }

    if (superSparkGift != null) {
      if (user.walletBalance < superSparkGift.tokenCost) return false;
      user.walletBalance -= superSparkGift.tokenCost;
    }

    discoveryProfiles.removeWhere((p) => p.id == profile.id);

    // Mutual match probability (90% for high sync)
    final isMutual = isSpark || superSparkGift != null;
    if (isMutual) {
      final newMatch = MatchProfile(
        id: profile.id,
        name: profile.name,
        age: profile.age,
        neighborhood: profile.neighborhood,
        occupation: profile.occupation,
        bio: profile.bio,
        avatarEmoji: profile.avatarEmoji,
        verifiedBadge: profile.verifiedBadge,
        distanceKm: profile.distanceKm,
        syncScore: profile.syncScore,
        interests: profile.interests,
        favoriteVenueId: profile.favoriteVenueId,
        relationshipStage: superSparkGift != null ? RelationshipStage.situationship : RelationshipStage.talkingStage,
        totalGiftsExchanged: superSparkGift != null ? 1 : 0,
      );

      newMatch.chatMessages.add(ChatMessage(
        id: 'auto_${DateTime.now().millisecondsSinceEpoch}',
        senderName: profile.name,
        senderAvatar: profile.avatarEmoji,
        text: superSparkGift != null
            ? 'OMG! You sent me ${superSparkGift.name} ${superSparkGift.emoji}?! You already know the way to my heart! 😍'
            : 'We matched! Your Lagos vibe score is ${profile.syncScore}%. Where are we taking this vibe? 😉',
        timestamp: DateTime.now(),
        isUser: false,
        attachedGift: superSparkGift,
      ));

      matches.insert(0, newMatch);
    }

    notifyListeners();
    return true;
  }

  // Venue live chat
  void sendVenueChatMessage(String venueId, String text) {
    if (text.trim().isEmpty) return;
    final list = venueChats[venueId] ?? [];
    list.add(ChatMessage(
      id: 'v_${DateTime.now().millisecondsSinceEpoch}',
      senderName: user.username,
      senderAvatar: user.avatarEmoji,
      text: text.trim(),
      timestamp: DateTime.now(),
      isUser: true,
    ));
    venueChats[venueId] = list;

    // Simulate community reply after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      final replies = [
        'Pure facts! Lagos always has the best energy!',
        'Who is ordering the next round? Table 2 is ready! 🥂',
        'Drop your SparkSync tag, let us connect!',
        'No place like Lagos on a Friday night 🔥',
      ];
      final fakeSender = ['Chioma_VI', 'DJ_Kayce', 'Tade_Lekki', 'Funke_Glam'][Random().nextInt(4)];
      final fakeAvatar = ['💅', '🎧', '🚗', '🍹'][Random().nextInt(4)];
      list.add(ChatMessage(
        id: 'v_reply_${DateTime.now().millisecondsSinceEpoch}',
        senderName: fakeSender,
        senderAvatar: fakeAvatar,
        text: replies[Random().nextInt(replies.length)],
        timestamp: DateTime.now(),
        isUser: false,
      ));
      notifyListeners();
    });

    notifyListeners();
  }

  // Private DMs & Gifts
  void sendDirectMessage(MatchProfile match, String text) {
    if (text.trim().isEmpty) return;
    match.chatMessages.add(ChatMessage(
      id: 'dm_${DateTime.now().millisecondsSinceEpoch}',
      senderName: user.username,
      senderAvatar: user.avatarEmoji,
      text: text.trim(),
      timestamp: DateTime.now(),
      isUser: true,
    ));
    user.xp += 10;

    // Check relationship progression based on chatting activity
    final userMsgsCount = match.chatMessages.where((m) => m.isUser).length;
    if (userMsgsCount >= 4 && match.relationshipStage == RelationshipStage.situationship) {
      match.relationshipStage = RelationshipStage.mainSqueeze;
    } else if (userMsgsCount >= 2 && match.relationshipStage == RelationshipStage.talkingStage) {
      match.relationshipStage = RelationshipStage.situationship;
    }

    // Vault Unlock Check at Tier 3 (Good Vibe 🍃) or above
    if (match.relationshipStage.index >= RelationshipStage.mainSqueeze.index && !match.vaultUnlocked) {
      match.vaultUnlocked = true;
      match.chatMessages.add(ChatMessage(
        id: 'vault_unlocked_${DateTime.now().millisecondsSinceEpoch}',
        senderName: 'SparkSync System ⚡',
        senderAvatar: '🔓',
        text: '🔓 VAULT UNLOCKED! You two reached Relationship Tier 3 (Good Vibe 🍃)! Real high-resolution photo galleries are now revealed across both devices! 🎉✨',
        timestamp: DateTime.now(),
        isUser: false,
      ));
    }
    notifyListeners();

    // Contextual bot reply after 1.5 seconds
    Future.delayed(const Duration(milliseconds: 1500), () {
      final answers = [
        'You have sharp mouth o! 😂 I like your humor.',
        'You really know our hood inside out. Tell me more!',
        'That sounds like a date plan. Just do not let NEPA interrupt us! 😜',
        'Honestly, you are the most interesting person on this app today.',
        'I am really feeling this vibe between us. 💫',
      ];
      match.chatMessages.add(ChatMessage(
        id: 'dm_reply_${DateTime.now().millisecondsSinceEpoch}',
        senderName: match.name,
        senderAvatar: match.avatarEmoji,
        text: answers[Random().nextInt(answers.length)],
        timestamp: DateTime.now(),
        isUser: false,
      ));

      // Check progression again after match reply
      final totalChatCount = match.chatMessages.length;
      if (totalChatCount >= 6 && match.relationshipStage.index < RelationshipStage.mainSqueeze.index) {
        match.relationshipStage = RelationshipStage.mainSqueeze;
        if (!match.vaultUnlocked) {
          match.vaultUnlocked = true;
          match.chatMessages.add(ChatMessage(
            id: 'vault_unlocked_${DateTime.now().millisecondsSinceEpoch}',
            senderName: 'SparkSync System ⚡',
            senderAvatar: '🔓',
            text: '🔓 VAULT UNLOCKED! You two reached Relationship Tier 3 (Good Vibe 🍃)! Real high-resolution photo galleries are now revealed across both devices! 🎉✨',
            timestamp: DateTime.now(),
            isUser: false,
          ));
        }
      }
      notifyListeners();
    });
  }

  bool sendGiftToMatch(MatchProfile match, ShopItem gift) {
    // Check if user has it in inventory or can buy with coins
    final ownedCount = inventory[gift.id] ?? 0;
    if (ownedCount > 0) {
      inventory[gift.id] = ownedCount - 1;
      if (inventory[gift.id] == 0) inventory.remove(gift.id);
    } else {
      if (user.walletBalance < gift.tokenCost) return false;
      user.walletBalance -= gift.tokenCost;
    }

    match.totalGiftsExchanged += 1;
    user.xp += 50;

    // Update relationship stage based on gifts
    if (match.totalGiftsExchanged >= 10) {
      match.relationshipStage = RelationshipStage.owambeOfficial;
    } else if (match.totalGiftsExchanged >= 4) {
      match.relationshipStage = RelationshipStage.mainSqueeze;
    } else if (match.totalGiftsExchanged >= 2) {
      match.relationshipStage = RelationshipStage.situationship;
    }

    // Vault Unlock Check at Tier 3 or above
    if (match.relationshipStage.index >= RelationshipStage.mainSqueeze.index && !match.vaultUnlocked) {
      match.vaultUnlocked = true;
      match.chatMessages.add(ChatMessage(
        id: 'vault_unlocked_${DateTime.now().millisecondsSinceEpoch}',
        senderName: 'SparkSync System ⚡',
        senderAvatar: '🔓',
        text: '🔓 VAULT UNLOCKED! You two reached Relationship Tier 3 (Good Vibe 🍃)! Real high-resolution photo galleries are now revealed across both devices! 🎉✨',
        timestamp: DateTime.now(),
        isUser: false,
      ));
    }

    // Live Supabase RPC call for atomic ledger deduction and connection progression
    final currentUserId = SupabaseService().currentUser?.id;
    if (currentUserId != null && SupabaseService().isConfigured) {
      SupabaseService().sendGiftRPC(
        senderId: currentUserId,
        matchId: match.id,
        itemId: gift.id,
      ).then((rpcRes) {
        if (rpcRes != null && rpcRes['success'] == true) {
          if (rpcRes['new_balance'] is num) {
            user.walletBalance = (rpcRes['new_balance'] as num).toInt();
          }
          final stageStr = rpcRes['relationship_stage'] as String?;
          if (stageStr != null) {
            if (stageStr == 'owambeOfficial') {
              match.relationshipStage = RelationshipStage.owambeOfficial;
            } else if (stageStr == 'mainSqueeze') {
              match.relationshipStage = RelationshipStage.mainSqueeze;
            } else if (stageStr == 'situationship') {
              match.relationshipStage = RelationshipStage.situationship;
            }
            if (match.relationshipStage.index >= RelationshipStage.mainSqueeze.index && !match.vaultUnlocked) {
              match.vaultUnlocked = true;
              match.chatMessages.add(ChatMessage(
                id: 'vault_unlocked_${DateTime.now().millisecondsSinceEpoch}',
                senderName: 'SparkSync System ⚡',
                senderAvatar: '🔓',
                text: '🔓 VAULT UNLOCKED! You two reached Relationship Tier 3 (Good Vibe 🍃)! Real high-resolution photo galleries are now revealed across both devices! 🎉✨',
                timestamp: DateTime.now(),
                isUser: false,
              ));
            }
          }
          notifyListeners();
        }
      });
    }

    match.chatMessages.add(ChatMessage(
      id: 'gift_${DateTime.now().millisecondsSinceEpoch}',
      senderName: user.username,
      senderAvatar: user.avatarEmoji,
      text: 'Sent you ${gift.name} ${gift.emoji}!',
      timestamp: DateTime.now(),
      isUser: true,
      attachedGift: gift,
    ));

    // Match's joyful response
    Future.delayed(const Duration(milliseconds: 1200), () {
      match.chatMessages.add(ChatMessage(
        id: 'gift_resp_${DateTime.now().millisecondsSinceEpoch}',
        senderName: match.name,
        senderAvatar: match.avatarEmoji,
        text: 'Awww ${gift.emoji}! You are spoiling me! Our relationship just upgraded to ${match.relationshipStage.displayName} ❤️',
        timestamp: DateTime.now(),
        isUser: false,
      ));
      notifyListeners();
    });

    notifyListeners();
    return true;
  }

  // Daily Gacha Spin Transaction
  Future<Map<String, dynamic>> spinDailyGacha() async {
    final supa = SupabaseService();
    final currentUser = supa.currentUser;

    if (supa.isConfigured && currentUser != null) {
      try {
        final result = await supa.spinDailyGachaBoxRPC(currentUser.id);
        if (result['success'] == true) {
          final newWallet = result['new_wallet'] as int?;
          final newStreak = result['new_streak'] as int?;
          final rolledTier = result['rolled_tier'] as String? ?? 'Common';
          final rewardTitle = result['reward_title'] as String? ?? 'Daily Reward';

          if (newWallet != null) user.walletBalance = newWallet;
          if (newStreak != null) user.currentStreakDays = newStreak;
          user.lastLoginClaimAt = DateTime.now();

          // Apply local energy and item inventory if items were rolled
          if (rewardTitle.contains('Chilled Malt')) {
            user.energy = min(user.maxEnergy, user.energy + 10);
            inventory['chilled_malt'] = (inventory['chilled_malt'] ?? 0) + 1;
          } else if (rewardTitle.contains('Party Jollof')) {
            user.energy = min(user.maxEnergy, user.energy + 50);
            inventory['party_jollof'] = (inventory['party_jollof'] ?? 0) + 1;
          } else if (rewardTitle.contains('Neon Chat Flare')) {
            inventory['neon_chat_flare'] = (inventory['neon_chat_flare'] ?? 0) + 1;
            user.equippedFlair = 'neon_chat_flare';
          }

          notifyListeners();
          return {
            'success': true,
            'tier': rolledTier,
            'title': rewardTitle,
            'streak': user.currentStreakDays,
            'wallet': user.walletBalance,
          };
        } else if (result['message'] != null && result['message'].toString().contains('already claimed')) {
          return {
            'success': false,
            'alreadyClaimed': true,
            'message': result['message'].toString(),
          };
        }
      } catch (e) {
        debugPrint('[GameState] spinDailyGacha RPC failed, using offline fallback: $e');
      }
    }

    // Offline / Local fallback with identical probability matrix
    if (!user.canClaimDailyGacha) {
      return {
        'success': false,
        'alreadyClaimed': true,
        'message': 'You have already claimed today\'s daily reward! Come back tomorrow.',
      };
    }

    // Streak increment logic
    if (user.lastLoginClaimAt != null &&
        DateTime.now().difference(user.lastLoginClaimAt!).inHours > 48) {
      user.currentStreakDays = 1;
    } else {
      user.currentStreakDays += 1;
    }
    user.lastLoginClaimAt = DateTime.now();

    final roll = Random().nextInt(100) + 1; // 1 to 100
    String tier;
    String title;

    if (roll <= 50) {
      tier = 'Common';
      title = '🪙 20 Credits Box';
      user.walletBalance += 20;
    } else if (roll <= 80) {
      tier = 'Common';
      title = '🧃 Chilled Malt Drink';
      user.energy = min(user.maxEnergy, user.energy + 10);
      inventory['chilled_malt'] = (inventory['chilled_malt'] ?? 0) + 1;
    } else if (roll <= 93) {
      tier = 'Rare';
      title = '🪙 150 Credits Jackpot!';
      user.walletBalance += 150;
    } else if (roll <= 98) {
      tier = 'Rare';
      title = '🍲 Party Jollof Feast';
      user.energy = min(user.maxEnergy, user.energy + 50);
      inventory['party_jollof'] = (inventory['party_jollof'] ?? 0) + 1;
    } else {
      tier = 'Mythic';
      title = '✨ Exclusive Neon Chat Flare (24h)';
      inventory['neon_chat_flare'] = (inventory['neon_chat_flare'] ?? 0) + 1;
      user.equippedFlair = 'neon_chat_flare';
    }

    user.xp += 25;
    notifyListeners();
    return {
      'success': true,
      'tier': tier,
      'title': title,
      'streak': user.currentStreakDays,
      'wallet': user.walletBalance,
    };
  }

  // Legacy convenience method
  Future<bool> claimDailyGacha() async {
    final res = await spinDailyGacha();
    return res['success'] == true;
  }

  // Date Co-op Quiz (Icebreaker sync)
  void recordTriviaResults(MatchProfile match, int score) {
    user.walletBalance += score * 20;
    user.xp += score * 15;
    match.totalGiftsExchanged += 1;

    match.chatMessages.add(ChatMessage(
      id: 'trivia_${DateTime.now().millisecondsSinceEpoch}',
      senderName: 'Lagos Date Sync Bot 🤖',
      senderAvatar: '🎯',
      text: 'Vibe Sync Quiz Complete! You scored $score/3 compatibility! Relationship bond increased! 💖',
      timestamp: DateTime.now(),
      isUser: false,
    ));
    notifyListeners();
  }

  // Anti-Ghosting Penalty & Sever Connection
  Future<Map<String, dynamic>> severMatchConnection(
    MatchProfile match, {
    required String actionType, // 'unmatch' or 'block'
    String reason = 'general',
  }) async {
    final isHighTier = match.relationshipStage.index >= RelationshipStage.mainSqueeze.index;
    final isExempt = reason == 'harassment' || reason == 'scam';

    // Anti-Ghosting penalty check (50 Cr if Tier 3+ and not harassment/scam)
    if (isHighTier && !isExempt) {
      if (user.walletBalance < 50) {
        return {
          'success': false,
          'message':
              'Insufficient credits! Severing a Tier ${match.relationshipStage.index + 1} connection incurs a 50 Cr emotional damages penalty.',
        };
      }
      user.walletBalance -= 50;
    }

    // Purge local connection
    matches.removeWhere((m) => m.id == match.id);
    match.vaultUnlocked = false;
    match.isSevered = true;

    if (actionType == 'block') {
      blacklistedUserIds.add(match.id);
      discoveryProfiles.removeWhere((p) => p.id == match.id);
    }

    // Call Supabase RPC if configured
    final currentUserId = SupabaseService().currentUser?.id;
    if (currentUserId != null && SupabaseService().isConfigured) {
      SupabaseService().severMatchConnectionRPC(
        userId: currentUserId,
        targetId: match.id,
        actionType: actionType,
        reason: reason,
      );
    }

    notifyListeners();
    return {
      'success': true,
      'message': actionType == 'block'
          ? 'User blocked and blacklisted. Photo Vault relocked and chat purged.'
          : 'Connection severed cleanly. Photo Vault relocked and histories purged.',
    };
  }

  // Bypass grind: Instant Vault Reveal Ticket (100 Cr)
  bool unlockVaultWithTicket(MatchProfile match) {
    if (user.walletBalance < 100) return false;
    user.walletBalance -= 100;
    match.vaultUnlocked = true;
    notifyListeners();
    return true;
  }

  void stopTimer() {
    _ticker?.cancel();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
