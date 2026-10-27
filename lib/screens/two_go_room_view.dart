import 'dart:async';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/game_state.dart';
import '../services/local_persistence_service.dart';
import '../services/sound_service.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/acapella_challenge_arena_modal.dart';
import '../widgets/afrobeat_deck_widget.dart';
import '../widgets/credit_top_up_sheet.dart';
import '../widgets/money_rain_overlay.dart';
import '../widgets/naija_banter_deck_widget.dart';
import '../widgets/room_schedule_banner.dart';
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

    // Cleanse any stale simulated bot or phantom messages from memory & disk
    bool isStale(TwoGoRoomMessage m) {
      final t = m.text.toLowerCase();
      return m.senderId == 'bot_host' ||
          m.text.contains('NEXT SINGER:') ||
          t.contains('sheesh') ||
          t.contains('shouted');
    }

    final currentList = widget.gameState.twoGoRoomChats[widget.room.id];
    if (currentList != null && currentList.isNotEmpty) {
      currentList.removeWhere(isStale);
      LocalPersistenceService().saveRoomMessages(widget.room.id, currentList);
    }

    // Fallback: restore from local cache if memory list is currently empty (Option C: Rolling 25-message buffer)
    final currentUserId = SupabaseService().currentUser?.id ?? 'user_local';
    if ((widget.gameState.twoGoRoomChats[widget.room.id] ?? []).isEmpty) {
      LocalPersistenceService().restoreRoomMessages(widget.room.id, currentUserId).then((cached) {
        if (cached.isNotEmpty && mounted) {
          final clean = cached.where((m) => !isStale(m)).toList();
          final rolling = clean.length > 25 ? clean.sublist(clean.length - 25) : clean;
          widget.gameState.twoGoRoomChats[widget.room.id] = rolling;
          LocalPersistenceService().saveRoomMessages(widget.room.id, rolling);
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
      SoundService().stopKaraokeAudio();
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

  void _openAfrobeatStageModal() {
    SoundService().playButtonTap();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F1522),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.50,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  AfrobeatDeckWidget(
                    gameState: widget.gameState,
                    roomId: widget.room.id,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openNaijaBanterModal() {
    SoundService().playButtonTap();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F1522),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.82,
          minChildSize: 0.45,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  NaijaBanterDeckWidget(
                    gameState: widget.gameState,
                    roomId: widget.room.id,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openRoomActionMenu() {
    SoundService().playButtonTap();
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141A28),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final isAfrobeat = widget.room.id == 'room_afrobeat_vibes';
        final isBanter = widget.room.id == 'room_naija_banter';

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${widget.room.name} Features',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '🪙 ${widget.gameState.user.walletBalance} Cr',
                      style: const TextStyle(
                        color: AppTheme.lagosYellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tap any feature to interact with the room',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 11.5),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    if (isAfrobeat) ...[
                      _buildActionItem(
                        icon: '🎤',
                        title: 'Live Stage',
                        subtitle: 'Sing on Mic & Lyrics',
                        color: AppTheme.lagosYellow,
                        onTap: () {
                          Navigator.pop(ctx);
                          _openAfrobeatStageModal();
                        },
                      ),
                      _buildActionItem(
                        icon: '🎧',
                        title: 'DJ Decks',
                        subtitle: 'Beats, Hype & Boo',
                        color: AppTheme.skyCyan,
                        onTap: () {
                          Navigator.pop(ctx);
                          _openAfrobeatStageModal();
                        },
                      ),
                    ],
                    if (isBanter) ...[
                      _buildActionItem(
                        icon: '⚽',
                        title: 'Match Predictions',
                        subtitle: 'Stake 10 🪙 Pool',
                        color: AppTheme.lagosYellow,
                        onTap: () {
                          Navigator.pop(ctx);
                          _openNaijaBanterModal();
                        },
                      ),
                      _buildActionItem(
                        icon: '📢',
                        title: 'Banter Sound FX',
                        subtitle: 'Whistle, Vuvuzela',
                        color: AppTheme.neonEmerald,
                        onTap: () {
                          Navigator.pop(ctx);
                          _openNaijaBanterModal();
                        },
                      ),
                    ],
                    _buildActionItem(
                      icon: '💸',
                      title: 'Spray Naira',
                      subtitle: '50 🪙 (+100 XP)',
                      color: AppTheme.neonEmerald,
                      onTap: () {
                        Navigator.pop(ctx);
                        final err = widget.gameState.sprayNairaOnSinger();
                        if (err != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(backgroundColor: Colors.redAccent, content: Text(err)),
                          );
                        }
                      },
                    ),
                    _buildActionItem(
                      icon: '🥂',
                      title: 'Round of Drinks',
                      subtitle: '50 🪙 (+150 XP)',
                      color: AppTheme.electricPink,
                      onTap: () {
                        Navigator.pop(ctx);
                        final ok = widget.gameState.buyRoundOfDrinks(widget.room.id);
                        if (ok) {
                          SoundService().playCoinEarned();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: AppTheme.neonEmerald,
                              content: Text('🍾 Bought a round of drinks for the entire room!'),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Colors.redAccent,
                              content: Text('Need at least 50 Credits to buy a round!'),
                            ),
                          );
                        }
                      },
                    ),
                    _buildActionItem(
                      icon: '📅',
                      title: 'Weekly Schedule',
                      subtitle: 'Events & Challenges',
                      color: AppTheme.skyCyan,
                      onTap: () {
                        Navigator.pop(ctx);
                        RoomScheduleBanner.showScheduleModal(context, widget.gameState);
                      },
                    ),
                    _buildActionItem(
                      icon: '🏆',
                      title: 'Acapella Arena',
                      subtitle: 'Saturday Challenge',
                      color: Colors.amberAccent,
                      onTap: () {
                        Navigator.pop(ctx);
                        AcapellaChallengeArenaModal.launch(context, widget.gameState, roomId: widget.room.id);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionItem({
    required String icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 160,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2638),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: color, fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveAudioMiniBar() {
    final track = widget.gameState.karaokeCurrentTrack;
    if (track == null || !widget.gameState.karaokeIsPlaying) {
      return const SizedBox.shrink();
    }
    final singer = widget.gameState.karaokeSingerName ?? 'Live Singer';
    final isMuted = SoundService().isKaraokeMuted;

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 4, 10, 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF161F30),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.lagosYellow.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: AppTheme.lagosYellow.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Text('🎤', style: TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  track.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$singer • 👏 ${widget.gameState.karaokeClapCount} claps',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          // Quick Clap button
          InkWell(
            onTap: () => widget.gameState.clapForKaraokeSinger(),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text('👏 Clap', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 4),
          // Mute / Unmute
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            icon: Icon(
              isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
              color: isMuted ? Colors.white38 : AppTheme.lagosYellow,
              size: 18,
            ),
            onPressed: () async {
              await SoundService().toggleKaraokeMute();
              setState(() {});
            },
          ),
          // Expand stage button
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            icon: const Icon(Icons.open_in_full_rounded, color: AppTheme.skyCyan, size: 16),
            onPressed: _openAfrobeatStageModal,
          ),
        ],
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
          backgroundColor: const Color(0xFF000000), // Apple OLED pure black
          appBar: AppBar(
            backgroundColor: const Color(0xFF121214), // Apple iOS bar
            elevation: 0,
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
                              Text(
                                '${liveRoom.activeOnline} active',
                                style: TextStyle(
                                  color: isOnline ? AppTheme.neonEmerald : AppTheme.textMuted,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
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
              if (widget.room.id == 'room_afrobeat_vibes') ...[
                Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      backgroundColor: AppTheme.lagosYellow.withValues(alpha: 0.16),
                      foregroundColor: AppTheme.lagosYellow,
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Text('🎤', style: TextStyle(fontSize: 12)),
                    label: const Text(
                      'Stage & DJ',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                    onPressed: _openAfrobeatStageModal,
                  ),
                ),
              ] else if (widget.room.id == 'room_naija_banter') ...[
                Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      backgroundColor: AppTheme.neonEmerald.withValues(alpha: 0.16),
                      foregroundColor: AppTheme.neonEmerald,
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Text('⚽', style: TextStyle(fontSize: 12)),
                    label: const Text(
                      'Matchday & FX',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                    onPressed: _openNaijaBanterModal,
                  ),
                ),
              ],

              // Wallet Credits Button
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: InkWell(
                  onTap: () => CreditTopUpSheet.show(context, widget.gameState),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E283E),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.lagosYellow.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🪙 ', style: TextStyle(fontSize: 11)),
                        Text(
                          '${widget.gameState.user.walletBalance}',
                          style: const TextStyle(
                            color: AppTheme.lagosYellow,
                            fontWeight: FontWeight.bold,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
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
                  // Live Audio Mini Bar (only shown when a song is actively singing/playing in Afrobeat room)
                  if (widget.room.id == 'room_afrobeat_vibes')
                    _buildLiveAudioMiniBar(),

                  // Room Schedule Banner (shows current mode and allows instant 1-tap inspection of the weekly schedule)
                  if (widget.room.id == 'room_afrobeat_vibes')
                    RoomScheduleBanner(gameState: widget.gameState),

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

              // Input Bar with Apple / WhatsApp minimal action button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFF121214),
                  border: Border(top: BorderSide(color: Color(0xFF242426), width: 0.5)),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      // Action Menu (+) button
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.brandCoral, size: 24),
                        tooltip: 'Room Features',
                        onPressed: _openRoomActionMenu,
                      ),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C1C1E),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF2C2C2E), width: 0.5),
                          ),
                          child: TextField(
                            controller: _msgController,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            textCapitalization: TextCapitalization.sentences,
                            decoration: const InputDecoration(
                              hintText: 'Message...',
                              hintStyle: TextStyle(color: Color(0xFF86868B), fontSize: 13.5),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: const BoxDecoration(
                          color: AppTheme.brandCoral, // Apple Signature Blue
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
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

                  // Message text bubble (Apple iMessage style: Apple Blue for user, Space Gray for others)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8.5),
                    decoration: BoxDecoration(
                      color: msg.isUser ? const Color(0xFF0071E3) : const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(16),
                      border: msg.isUser
                          ? null
                          : Border.all(color: const Color(0xFF2C2C2E), width: 0.5),
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
