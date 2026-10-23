import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/coop_trivia_sheet.dart';
import '../widgets/gift_selection_sheet.dart';
import '../widgets/photo_vault_reveal_card.dart';

class MatchesScreen extends StatefulWidget {
  final GameState gameState;

  const MatchesScreen({super.key, required this.gameState});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  MatchProfile? activeChatMatch;
  final TextEditingController _msgController = TextEditingController();

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  void _openPhotoVaultModal(MatchProfile match) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: PhotoVaultRevealCard(
          profile: match,
          isUnlocked: match.isVaultUnlocked,
          userCredits: widget.gameState.user.walletBalance,
          onUnlockWithTicket: !match.isVaultUnlocked
              ? () {
                  final ok = widget.gameState.unlockVaultWithTicket(match);
                  Navigator.pop(ctx);
                  if (ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: AppTheme.neonEmerald,
                        content: Text('🎉 Photo unlocked! You can now view their real photo!'),
                      ),
                    );
                    setState(() {});
                    _openPhotoVaultModal(match);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: Colors.redAccent,
                        content: Text('Not enough coins! Unlocking costs 100 Coins.'),
                      ),
                    );
                  }
                }
              : null,
        ),
      ),
    );
  }

  void _showSeverConnectionDialog(MatchProfile match, {required bool isBlock}) {
    String selectedReason = 'boring';
    final isHighTier = match.relationshipStage.index >= RelationshipStage.mainSqueeze.index;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isExempt = selectedReason == 'harassment' || selectedReason == 'scam';
          final penaltyCredits = (isHighTier && !isExempt) ? 50 : 0;
          final userCredits = widget.gameState.user.walletBalance;
          final canAfford = penaltyCredits == 0 || userCredits >= penaltyCredits;

          return AlertDialog(
            backgroundColor: const Color(0xFF16162A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(
                  isBlock ? Icons.block : Icons.link_off_rounded,
                  color: isBlock ? Colors.redAccent : AppTheme.electricPink,
                ),
                const SizedBox(width: 8),
                Text(
                  isBlock ? 'Block & Blacklist' : 'Sever Connection',
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isBlock
                      ? 'Blacklist ${match.name}? They will be completely hidden from swipe decks and chatrooms, and your real photos will immediately relock into the vault.'
                      : 'Sever your connection with ${match.name}? Your private chat history will be purged and photos relocked into the vault.',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Reason:',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedReason,
                  dropdownColor: const Color(0xFF1E2638),
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    filled: true,
                    fillColor: Colors.black38,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'boring', child: Text('😴 Lost interest / boring vibe')),
                    DropdownMenuItem(value: 'changed_mind', child: Text('🤔 Changed my mind')),
                    DropdownMenuItem(value: 'harassment', child: Text('🚨 Report Harassment / Scam (100% Free)')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() {
                        selectedReason = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 14),

                // Anti-Ghosting Penalty Card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: penaltyCredits > 0
                        ? Colors.orangeAccent.withValues(alpha: 0.12)
                        : AppTheme.neonEmerald.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: penaltyCredits > 0 ? Colors.orangeAccent : AppTheme.neonEmerald,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        penaltyCredits > 0 ? Icons.warning_amber_rounded : Icons.verified_user_rounded,
                        color: penaltyCredits > 0 ? Colors.orangeAccent : AppTheme.neonEmerald,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          penaltyCredits > 0
                              ? '⚠️ Anti-Ghosting Fee: $penaltyCredits Cr\nBreaking a high-tier (${match.relationshipStage.displayName}) connection requires 50 Cr emotional damages.'
                              : (isExempt
                                  ? '🛡️ Safety Exception: 100% Free\nHarassment reports are never penalized.'
                                  : '✅ Free Unmatch\nTier 1/2 connections can be severed at zero cost.'),
                          style: TextStyle(
                            color: penaltyCredits > 0 ? Colors.orangeAccent : AppTheme.neonEmerald,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isBlock ? Colors.redAccent : AppTheme.brandCoral,
                  foregroundColor: Colors.white,
                ),
                onPressed: canAfford
                    ? () async {
                        final messenger = ScaffoldMessenger.of(context);
                        Navigator.pop(ctx);
                        final res = await widget.gameState.severMatchConnection(
                          match,
                          actionType: isBlock ? 'block' : 'unmatch',
                          reason: selectedReason,
                        );

                        if (mounted) {
                          if (res['success'] == true) {
                            setState(() {
                              activeChatMatch = null;
                            });
                            messenger.showSnackBar(
                              SnackBar(
                                backgroundColor: isBlock ? Colors.redAccent : AppTheme.neonEmerald,
                                content: Text(
                                  res['message'] ?? 'Connection severed.',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            );
                          } else {
                            messenger.showSnackBar(
                              SnackBar(
                                backgroundColor: Colors.redAccent,
                                content: Text(res['message'] ?? 'Failed to sever connection.'),
                              ),
                            );
                          }
                        }
                      }
                    : null,
                child: Text(isBlock ? 'Block & Purge' : 'Sever (Confirm)'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (activeChatMatch != null) {
      return _buildChatView(activeChatMatch!);
    }

    final matches = widget.gameState.matches;

    if (matches.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('💌', style: TextStyle(fontSize: 48)),
              SizedBox(height: 16),
              Text(
                'No Sparks Yet!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Head over to the SparkDeck to discover Lagos singles, or check in at a live venue to mingle!',
                style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Row(
          children: [
            Text('💬', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text(
              'Matches & Dates',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: matches.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final match = matches[index];
          final lastMessage = match.chatMessages.isNotEmpty
              ? match.chatMessages.last.text
              : 'Started a new connection!';

          return InkWell(
            onTap: () {
              setState(() {
                activeChatMatch = match;
              });
            },
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.cardSurface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: AppTheme.nightObsidian,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: match.relationshipStage == RelationshipStage.owambeOfficial
                                ? AppTheme.lagosYellow
                                : AppTheme.brandCoral,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(match.avatarEmoji, style: const TextStyle(fontSize: 28)),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: const BoxDecoration(
                            color: AppTheme.neonEmerald,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                match.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.brandCoral.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                match.relationshipStage.displayName,
                                style: const TextStyle(
                                  color: AppTheme.brandCoral,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          lastMessage,
                          style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '🎁 ${match.totalGiftsExchanged} Gifts',
                              style: const TextStyle(fontSize: 10, color: AppTheme.lagosYellow),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${match.syncScore}% Chemistry',
                              style: const TextStyle(fontSize: 10, color: AppTheme.neonEmerald),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: match.isVaultUnlocked
                                    ? AppTheme.neonEmerald.withValues(alpha: 0.15)
                                    : Colors.orangeAccent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: match.isVaultUnlocked
                                      ? AppTheme.neonEmerald.withValues(alpha: 0.6)
                                      : Colors.orangeAccent.withValues(alpha: 0.4),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    match.isVaultUnlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
                                    size: 9,
                                    color: match.isVaultUnlocked ? AppTheme.neonEmerald : Colors.orangeAccent,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    match.isVaultUnlocked ? 'Vault Open' : 'Vault Locked',
                                    style: TextStyle(
                                      color: match.isVaultUnlocked ? AppTheme.neonEmerald : Colors.orangeAccent,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppTheme.textMuted),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatView(MatchProfile match) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              activeChatMatch = null;
            });
          },
        ),
        title: InkWell(
          onTap: () => _openPhotoVaultModal(match),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppTheme.darkShimmer,
                      child: Text(match.avatarEmoji, style: const TextStyle(fontSize: 20)),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Color(0xFF16162A),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          match.isVaultUnlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
                          size: 10,
                          color: match.isVaultUnlocked ? AppTheme.neonEmerald : Colors.orangeAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              match.name,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_drop_down, color: AppTheme.textMuted, size: 16),
                        ],
                      ),
                      Text(
                        '${match.relationshipStage.displayName} • ${match.isVaultUnlocked ? "Vault Open 🔓" : "Vault Locked 🔒"}',
                        style: TextStyle(
                          fontSize: 10,
                          color: match.isVaultUnlocked ? AppTheme.neonEmerald : AppTheme.brandCoral,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Text('🎯', style: TextStyle(fontSize: 20)),
            tooltip: 'Play Lagos Sync Quiz',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => CoopTriviaSheet(
                  match: match,
                  gameState: widget.gameState,
                ),
              );
            },
          ),
          IconButton(
            icon: const Text('🎁', style: TextStyle(fontSize: 20)),
            tooltip: 'Send Romantic Gift',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (_) => GiftSelectionSheet(
                  match: match,
                  gameState: widget.gameState,
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: const Color(0xFF1E2638),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onSelected: (val) {
              if (val == 'vault') {
                _openPhotoVaultModal(match);
              } else if (val == 'unmatch') {
                _showSeverConnectionDialog(match, isBlock: false);
              } else if (val == 'block') {
                _showSeverConnectionDialog(match, isBlock: true);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'vault',
                child: Row(
                  children: [
                    Icon(
                      match.isVaultUnlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
                      color: match.isVaultUnlocked ? AppTheme.neonEmerald : Colors.orangeAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      match.isVaultUnlocked ? 'View Photo Vault (🔓)' : 'Inspect Vault (🔒)',
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'unmatch',
                child: Row(
                  children: [
                    Icon(Icons.link_off_rounded, color: AppTheme.brandCoral, size: 18),
                    SizedBox(width: 10),
                    Text('Sever Connection', style: TextStyle(color: Colors.white, fontSize: 13)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    Icon(Icons.block_rounded, color: Colors.redAccent, size: 18),
                    SizedBox(width: 10),
                    Text('Block & Blacklist', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Relationship Stage Progress Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: AppTheme.cardSurface,
              border: Border(bottom: BorderSide(color: AppTheme.cardBorder)),
            ),
            child: Row(
              children: [
                const Text('🔒 Couple Status: ', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                Text(
                  match.relationshipStage.displayName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.brandCoral,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (_) => GiftSelectionSheet(
                        match: match,
                        gameState: widget.gameState,
                      ),
                    );
                  },
                  child: const Text(
                    '+ Upgrade Status',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.lagosYellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Interactive Photo Vault Reveal Banner
          GestureDetector(
            onTap: () => _openPhotoVaultModal(match),
            child: Container(
              margin: const EdgeInsets.fromLTRB(14, 8, 14, 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: match.isVaultUnlocked
                      ? [
                          AppTheme.neonEmerald.withValues(alpha: 0.25),
                          const Color(0xFF142426),
                        ]
                      : [
                          Colors.orangeAccent.withValues(alpha: 0.18),
                          const Color(0xFF261914),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: match.isVaultUnlocked
                      ? AppTheme.neonEmerald.withValues(alpha: 0.8)
                      : Colors.orangeAccent.withValues(alpha: 0.5),
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    match.isVaultUnlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
                    color: match.isVaultUnlocked ? AppTheme.neonEmerald : Colors.orangeAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          match.isVaultUnlocked
                              ? '🔓 PHOTO VAULT UNLOCKED • REAL IDENTITY'
                              : '🔒 PHOTO VAULT: LOCKED (${match.realPhotos.length} Photos)',
                          style: TextStyle(
                            color: match.isVaultUnlocked ? AppTheme.neonEmerald : Colors.orangeAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          match.isVaultUnlocked
                              ? 'Real verified face revealed! Tap to view gallery.'
                              : 'Unlocks at Tier 3 (Good Vibe 🍃) or with Reveal Ticket.',
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 12),
                ],
              ),
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: match.chatMessages.length,
              itemBuilder: (context, index) {
                final msg = match.chatMessages[index];
                final isUser = msg.isUser;

                if (msg.text.contains('VAULT UNLOCKED')) {
                  return Center(
                    child: GestureDetector(
                      onTap: () => _openPhotoVaultModal(match),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 14),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0C241E), Color(0xFF131D26)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.neonEmerald, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.neonEmerald.withValues(alpha: 0.35),
                              blurRadius: 14,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.lock_open_rounded, color: AppTheme.neonEmerald, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'RELATIONSHIP TIER 3 ACHIEVED! 🍃',
                                  style: TextStyle(
                                    color: AppTheme.neonEmerald,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              msg.text,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.neonEmerald.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Tap here to view unlocked High-Res Gallery 📸',
                                style: TextStyle(
                                  color: AppTheme.neonEmerald,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isUser ? AppTheme.brandCoral : AppTheme.cardSurface,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                        bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                      ),
                      border: isUser ? null : Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment:
                          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        if (msg.attachedGift != null) ...[
                          Container(
                            padding: const EdgeInsets.all(8),
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(msg.attachedGift!.emoji, style: const TextStyle(fontSize: 20)),
                                const SizedBox(width: 6),
                                Text(
                                  msg.attachedGift!.name,
                                  style: const TextStyle(
                                    color: AppTheme.lagosYellow,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        Text(
                          msg.text,
                          style: TextStyle(
                            fontSize: 13,
                            color: isUser ? Colors.white : AppTheme.textLight,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${msg.timestamp.hour}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 9,
                            color: isUser ? Colors.white70 : AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Input Bar with Icebreaker helpers
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: AppTheme.cardSurface,
              border: Border(top: BorderSide(color: AppTheme.cardBorder)),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Quick Lagos Icebreaker suggestions
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _icebreakerChip('Are you a 33KV industrial line? Because our spark is real ⚡'),
                        _icebreakerChip('Amala at Shitta or Suya in Ikoyi this Friday? 🥩'),
                        _icebreakerChip('Did you survive that Third Mainland Bridge traffic? 🚐'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _msgController,
                          style: const TextStyle(fontSize: 14, color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Message ${match.name}...',
                            hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                            filled: true,
                            fillColor: AppTheme.nightObsidian,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (val) {
                            widget.gameState.sendDirectMessage(match, val);
                            _msgController.clear();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send_rounded, color: AppTheme.brandCoral),
                        onPressed: () {
                          widget.gameState.sendDirectMessage(match, _msgController.text);
                          _msgController.clear();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _icebreakerChip(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 6.0),
      child: ActionChip(
        backgroundColor: AppTheme.darkShimmer,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        label: Text(
          text,
          style: const TextStyle(fontSize: 11, color: AppTheme.textLight),
        ),
        onPressed: () {
          _msgController.text = text;
        },
      ),
    );
  }
}
