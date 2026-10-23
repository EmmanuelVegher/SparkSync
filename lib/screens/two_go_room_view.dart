import 'dart:async';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/game_state.dart';
import '../services/local_persistence_service.dart';
import '../services/sound_service.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/afrobeat_deck_widget.dart';
import '../widgets/money_rain_overlay.dart';
import '../widgets/two_go_profile_mini_card.dart';

class TwoGoRoomView extends StatefulWidget {
  final TwoGoChatRoom room;
  final GameState gameState;

  const TwoGoRoomView({
    super.key,
    required this.room,
    required this.gameState,
  });

  @override
  State<TwoGoRoomView> createState() => _TwoGoRoomViewState();
}

class _TwoGoRoomViewState extends State<TwoGoRoomView> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showEntryFlare = false;
  StreamSubscription? _roomMsgSub;

  @override
  void initState() {
    super.initState();

    // Increment active online count upon entering room after initial build frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.gameState.enterTwoGoRoom(widget.room.id);
      }
    });

    // Fallback: restore from local cache if memory list is currently empty (Option C: Rolling 25-message buffer)
    final currentUserId = SupabaseService().currentUser?.id ?? 'user_local';
    if ((widget.gameState.twoGoRoomChats[widget.room.id] ?? []).isEmpty) {
      LocalPersistenceService().restoreRoomMessages(widget.room.id, currentUserId).then((cached) {
        if (cached.isNotEmpty && mounted) {
          final rolling = cached.length > 25 ? cached.sublist(cached.length - 25) : cached;
          widget.gameState.twoGoRoomChats[widget.room.id] = rolling;
          setState(() {});
        }
      });
    }

    // High rank entry flare (Professional, Expert, Veteran, Ultimate)
    if (widget.gameState.user.starRank.index >= TwoGoStarRank.professional.index) {
      _showEntryFlare = true;
      Future.delayed(const Duration(milliseconds: 3000), () {
        if (mounted) {
          setState(() {
            _showEntryFlare = false;
          });
        }
      });
    }

    // Subscribe to live Supabase room messages (Option C: Rolling 25-message buffer)
    if (SupabaseService().isConfigured) {
      _roomMsgSub = SupabaseService().streamRoomMessages(widget.room.id).listen((rows) {
        if (!mounted) return;
        final currentUserId = SupabaseService().currentUser?.id;
        final msgs = rows.map((r) {
          final sId = r['sender_id'] as String? ?? '';
          return TwoGoRoomMessage(
            id: r['id']?.toString() ?? 'msg_${DateTime.now().millisecondsSinceEpoch}',
            roomId: widget.room.id,
            senderId: sId,
            senderName: r['sender_name'] as String? ?? 'Spark Member',
            senderAvatar: r['sender_avatar'] as String? ?? '😎',
            senderRank: TwoGoStarRank.values.firstWhere(
              (rk) => rk.name == (r['sender_rank'] as String? ?? ''),
              orElse: () => TwoGoStarRank.novice,
            ),
            hasNeonGlow: r['has_neon_glow'] as bool? ?? false,
            isAnnouncement: r['is_announcement'] as bool? ?? false,
            statusText: r['status_text'] as String?,
            text: r['content'] as String? ?? '',
            timestamp: DateTime.tryParse(r['created_at']?.toString() ?? '') ?? DateTime.now(),
            isUser: currentUserId != null && sId == currentUserId,
          );
        }).toList();

        if (msgs.isNotEmpty) {
          // Option C: Rolling 25-message buffer enforced by default
          final rollingBuffer = msgs.length > 25 ? msgs.sublist(msgs.length - 25) : msgs;
          widget.gameState.twoGoRoomChats[widget.room.id] = rollingBuffer;
          final last = rollingBuffer.last;
          widget.gameState.updateRoomLatestMessage(
            widget.room.id,
            '${last.senderName}: "${last.text}"',
          );
          LocalPersistenceService().saveRoomMessages(widget.room.id, rollingBuffer);
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.gameState.leaveTwoGoRoom(widget.room.id);
    });
    _roomMsgSub?.cancel();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    final errorNotice = widget.gameState.sendTwoGoMessage(widget.room.id, text);
    if (errorNotice != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(errorNotice, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      );
    } else {
      _msgController.clear();
      SoundService().playMessageSent();
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent + 60,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _openMiniCard({
    required String senderId,
    required String name,
    required String avatar,
    required TwoGoStarRank rank,
    String? statusText,
    bool hasNeonGlow = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TwoGoProfileMiniCard(
        senderId: senderId,
        name: name,
        avatar: avatar,
        starRank: rank,
        statusText: statusText,
        hasNeonGlow: hasNeonGlow,
        roomId: widget.room.id,
        gameState: widget.gameState,
        onDirectMessage: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppTheme.neonEmerald,
              content: Text('Starting private DM channel with $name...'),
            ),
          );
        },
      ),
    );
  }

  void _showModeratorMenu(String targetUserName) {
    final isModEligible = widget.gameState.user.starRank.index >= TwoGoStarRank.professional.index;
    if (!isModEligible) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orange,
          content: Text('Moderator powers unlock at Professional Rank (20,000 XP) 💎'),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131926),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.shield_rounded, color: AppTheme.brandCoral, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'MODERATOR POLICE: $targetUserName',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.warning_amber_rounded, color: AppTheme.lagosYellow),
                title: const Text('Issue Verbal Warning', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Sends visible system warning to the user', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                onTap: () {
                  widget.gameState.issueModeratorWarning(widget.room.id, targetUserName);
                  Navigator.of(ctx).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.volume_off_rounded, color: Colors.orange),
                title: const Text('Room Mute (5 Minutes)', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Prevents typing for 5 minutes', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                onTap: () {
                  widget.gameState.issueModeratorWarning(widget.room.id, '$targetUserName (MUTED 5 MIN)');
                  Navigator.of(ctx).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                title: const Text('Room Kick (15 Minutes)', style: TextStyle(color: Colors.white)),
                subtitle: const Text('Forcibly disconnects user. Nearby chatters can vote to object.', style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                onTap: () {
                  final actionId = 'kick_${DateTime.now().millisecondsSinceEpoch}';
                  widget.gameState.moderatorKickUser(widget.room.id, targetUserName, actionId: actionId);
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.gameState,
      builder: (context, _) {
        final messages = widget.gameState.twoGoRoomChats[widget.room.id] ?? [];

        return Scaffold(
          backgroundColor: const Color(0xFF0C101A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF141A28),
            elevation: 1,
            titleSpacing: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Row(
              children: [
                Text(widget.room.iconEmoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.room.name,
                        style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Builder(
                        builder: (context) {
                          final liveRoom = widget.gameState.twoGoRooms.firstWhere(
                            (r) => r.id == widget.room.id,
                            orElse: () => widget.room,
                          );
                          final isOnline = liveRoom.activeOnline > 0;
                          return Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isOnline ? AppTheme.neonEmerald : AppTheme.textMuted,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  '${liveRoom.activeOnline} Online • ⚡ 25 Buffer',
                                  style: TextStyle(
                                    color: isOnline ? AppTheme.neonEmerald : AppTheme.textMuted,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              // Buy Round of Drinks button (Compact sizing to prevent overflow)
              Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: AppTheme.lagosYellow.withValues(alpha: 0.15),
                    foregroundColor: AppTheme.lagosYellow,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Text('🥂', style: TextStyle(fontSize: 12)),
                  label: const Text(
                    'Round (50 Cr)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5),
                  ),
                  onPressed: () {
                    final ok = widget.gameState.buyRoundOfDrinks(widget.room.id);
                    if (ok) {
                      SoundService().playCoinEarned();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: AppTheme.neonEmerald,
                          content: Text(
                            '🍾 Bought a round of virtual drinks for everyone! +150 Clout XP!',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.redAccent,
                          content: Text('Insufficient Credits! Need at least 50 🪙.'),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(2.5),
              child: Builder(
                builder: (context) {
                  final user = widget.gameState.user;
                  final currentRank = user.starRank;
                  final progress = currentRank.progressToNext(user.xp);
                  final rankColor = AppTheme.getRankColor(currentRank.rankName);
                  return LinearProgressIndicator(
                    value: progress,
                    minHeight: 2.5,
                    backgroundColor: Colors.white10,
                    valueColor: AlwaysStoppedAnimation<Color>(rankColor.withValues(alpha: 0.85)),
                  );
                },
              ),
            ),
          ),
          body: Stack(
            children: [
              Column(
                children: [
              // Gamified Afrobeat Live DJ Deck & Interactive Beat Pad Overlay
              if (widget.room.id == 'room_afrobeat_vibes')
                AfrobeatDeckWidget(
                  gameState: widget.gameState,
                  roomId: widget.room.id,
                ),

              // Option C: Rolling 25-Message Privacy Buffer Badge
              Container(
                margin: const EdgeInsets.only(top: 6, bottom: 2),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF141A28).withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history_toggle_off_rounded, size: 12, color: AppTheme.textMuted),
                    SizedBox(width: 4),
                    Text(
                      'Option C • Rolling 25-Message Buffer Active',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

              // Room Entry Flare Banner
              if (_showEntryFlare)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.cyanAccent, Color(0xFF00E5FF), Colors.blueAccent],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyanAccent.withValues(alpha: 0.4),
                        blurRadius: 10,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('⚡ ', style: TextStyle(fontSize: 16)),
                      Text(
                        'VIP FLARE: ${widget.gameState.user.username} has stepped into the room!',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

              // Chat Messages Stream
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF141A28),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFF222C42)),
                                ),
                                alignment: Alignment.center,
                                child: Text(widget.room.iconEmoji, style: const TextStyle(fontSize: 30)),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Welcome to ${widget.room.name}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'No messages yet in this room.\nBe the first to spark the conversation! ✨',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          return _buildMessageTile(msg);
                        },
                      ),
              ),

              // Objections Micro-Banner (if active)
              ...widget.gameState.moderationObjections.entries.map((entry) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  color: const Color(0xFF1F132B),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Moderation in review: ${entry.value}/10 votes to overturn kick',
                          style: const TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.electricPink,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Vote to Object', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          final overturned = widget.gameState.objectToModeratorAction(entry.key);
                          if (overturned) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: AppTheme.neonEmerald,
                                content: Text('Kick OVERTURNED by room community vote! 🎉'),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                );
              }),

              // Input Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFF141A28),
                  border: Border(top: BorderSide(color: Color(0xFF222C42), width: 1)),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0C101A),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: const Color(0xFF222C42)),
                          ),
                          child: TextField(
                            controller: _msgController,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              hintText: 'Type into room... (+15 Clout XP)',
                              hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: const BoxDecoration(
                          color: AppTheme.brandCoral,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send_rounded, color: Colors.white, size: 19),
                          onPressed: _sendMessage,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Screen-wide Money Rain Vector Overlay (Spraying Naira!)
          if (widget.room.id == 'room_afrobeat_vibes')
            MoneyRainOverlay(
              triggerAnimation: widget.gameState.isMoneyRainActive,
              onFinished: () {
                widget.gameState.setMoneyRainActive(false);
              },
            ),
        ],
      ),
    );
  },
);
  }

  Widget _buildMessageTile(TwoGoRoomMessage msg) {
    if (msg.isAnnouncement) {
      final isNaira = msg.text.contains('SPRAYS NAIRA') || msg.text.contains('sprayed 50 Credits');
      final isKaraoke = msg.text.contains('KARAOKE') ||
          msg.text.contains('NEXT SINGER') ||
          msg.text.contains('STAGE TAKEOVER') ||
          msg.text.contains('VIP COCKTAIL') ||
          msg.text.contains('MASSIVE APPLAUSE') ||
          msg.text.contains('Mic Queue');
      final isBeat = msg.text.contains('LOG DRUM') ||
          msg.text.contains('AIRHORN') ||
          msg.text.contains('CONGA') ||
          msg.text.contains('SHEEEESH') ||
          msg.text.contains('SAX') ||
          msg.text.contains('AGÔGO');
      final isDjEvent = msg.text.contains('ON THE DECKS') ||
          msg.text.contains('RECORD SCRATCH') ||
          msg.text.contains('CROWD HYPE');

      return Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          gradient: isNaira
              ? const LinearGradient(
                  colors: [Color(0xFF0F3627), Color(0xFF142C44)],
                )
              : (isKaraoke
                  ? const LinearGradient(
                      colors: [Color(0xFF38153A), Color(0xFF1B1838)],
                    )
                  : (isBeat
                      ? const LinearGradient(
                          colors: [Color(0xFF28183B), Color(0xFF161F38)],
                        )
                      : (isDjEvent
                          ? LinearGradient(
                              colors: msg.text.contains('RECORD SCRATCH')
                                  ? [const Color(0xFF38141F), const Color(0xFF200F17)]
                                  : [const Color(0xFF2E2413), const Color(0xFF19172A)],
                            )
                          : null))),
          color: (!isNaira && !isKaraoke && !isBeat && !isDjEvent) ? const Color(0xFF251A3A) : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isNaira
                ? AppTheme.neonEmerald.withValues(alpha: 0.7)
                : (isKaraoke
                    ? const Color(0xFFFF2A6D).withValues(alpha: 0.6)
                    : (isBeat
                        ? Colors.pinkAccent.withValues(alpha: 0.5)
                        : (isDjEvent
                            ? (msg.text.contains('RECORD SCRATCH')
                                ? Colors.redAccent.withValues(alpha: 0.6)
                                : AppTheme.lagosYellow.withValues(alpha: 0.6))
                            : AppTheme.purpleRoyal.withValues(alpha: 0.5)))),
            width: isNaira || isKaraoke || isBeat || isDjEvent ? 1.3 : 1.0,
          ),
          boxShadow: isNaira || isKaraoke || isBeat || isDjEvent
              ? [
                  BoxShadow(
                    color: (isNaira
                            ? AppTheme.neonEmerald
                            : (isKaraoke
                                ? const Color(0xFFFF2A6D)
                                : (isBeat
                                    ? Colors.pinkAccent
                                    : (msg.text.contains('RECORD SCRATCH') ? Colors.redAccent : AppTheme.lagosYellow))))
                        .withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Text(msg.senderAvatar, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg.text,
                style: TextStyle(
                  color: isNaira
                      ? AppTheme.neonEmerald
                      : (isKaraoke
                          ? const Color(0xFFFF80AB)
                          : (isBeat
                              ? const Color(0xFFFF80AB)
                              : (msg.text.contains('RECORD SCRATCH') ? const Color(0xFFFF8A80) : Colors.white))),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final rankColor = AppTheme.getRankColor(msg.senderRank.rankName);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onLongPress: () {
          if (!msg.isUser) {
            _showModeratorMenu(msg.senderName);
          }
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chatter Avatar
            GestureDetector(
              onTap: () => _openMiniCard(
                senderId: msg.senderId,
                name: msg.senderName,
                avatar: msg.senderAvatar,
                rank: msg.senderRank,
                statusText: msg.statusText,
                hasNeonGlow: msg.hasNeonGlow,
              ),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1B2334),
                  border: Border.all(
                    color: msg.hasNeonGlow ? Colors.cyanAccent : rankColor,
                    width: 1.5,
                  ),
                  boxShadow: msg.hasNeonGlow
                      ? [
                          BoxShadow(
                            color: Colors.cyanAccent.withValues(alpha: 0.35),
                            blurRadius: 8,
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(msg.senderAvatar, style: const TextStyle(fontSize: 18)),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Message Bubble & Rank Header
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _openMiniCard(
                          senderId: msg.senderId,
                          name: msg.senderName,
                          avatar: msg.senderAvatar,
                          rank: msg.senderRank,
                          statusText: msg.statusText,
                          hasNeonGlow: msg.hasNeonGlow,
                        ),
                        child: Text(
                          msg.senderName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // SparkSync Star Rank Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: rankColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: rankColor.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          msg.senderRank.badgeTitle,
                          style: TextStyle(
                            color: rankColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 9,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Message text bubble
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: msg.isUser ? const Color(0xFF1E283C) : const Color(0xFF151C2A),
                      borderRadius: BorderRadius.circular(10),
                      border: msg.hasNeonGlow
                          ? Border.all(color: Colors.cyanAccent.withValues(alpha: 0.4), width: 1)
                          : null,
                    ),
                    child: Text(
                      msg.text,
                      style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
