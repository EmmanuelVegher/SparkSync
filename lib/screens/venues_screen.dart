import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/game_state.dart';
import '../theme/app_theme.dart';

class VenuesScreen extends StatefulWidget {
  final GameState gameState;

  const VenuesScreen({super.key, required this.gameState});

  @override
  State<VenuesScreen> createState() => _VenuesScreenState();
}

class _VenuesScreenState extends State<VenuesScreen> {
  VenueSpot? selectedVenue;
  final TextEditingController _chatController = TextEditingController();

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (selectedVenue != null) {
      return _buildVenueRoom(selectedVenue!);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Row(
          children: [
            const Text('🥂', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 8),
            Text(
              'Lagos Dating Hotspots',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppTheme.getTextColor(isDark),
              ),
            ),
          ],
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: widget.gameState.venues.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final venue = widget.gameState.venues[index];
          return InkWell(
            onTap: () {
              setState(() {
                selectedVenue = venue;
              });
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.getCardSurface(isDark),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.getCardBorder(isDark), width: 0.5),
                boxShadow: AppTheme.getCardShadow(isDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppTheme.getSecondarySurface(isDark),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(venue.iconEmoji, style: const TextStyle(fontSize: 28)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              venue.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.getTextColor(isDark),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${venue.category} • ${venue.area}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.getSubtextColor(isDark),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.brandCoral.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.people, size: 12, color: AppTheme.brandCoral),
                            const SizedBox(width: 4),
                            Text(
                              '${venue.activeSingles}',
                              style: const TextStyle(
                                color: AppTheme.brandCoral,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    venue.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppTheme.textLight : AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.lagosYellow.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            venue.vibeTag,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.lagosYellow,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Enter Lounge →',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.neonEmerald,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVenueRoom(VenueSpot venue) {
    final messages = widget.gameState.venueChats[venue.id] ?? [];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              selectedVenue = null;
            });
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              venue.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${venue.activeSingles} singles checked in now',
              style: const TextStyle(fontSize: 11, color: AppTheme.neonEmerald),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Chip(
              backgroundColor: AppTheme.darkShimmer,
              label: Text(venue.iconEmoji, style: const TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Popular drinks ticker
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppTheme.cardSurface,
            child: Row(
              children: [
                const Text('🍹 Bar Menu: ', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: venue.popularDrinks
                          .map((d) => Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: Text(
                                  '• $d',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.lagosYellow,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Live Chat Feed
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              reverse: false,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: const BoxDecoration(
                          color: AppTheme.cardSurface,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(msg.senderAvatar, style: const TextStyle(fontSize: 18)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  msg.senderName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: msg.isUser ? AppTheme.brandCoral : Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${msg.timestamp.hour}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: msg.isUser
                                    ? AppTheme.brandCoral.withValues(alpha: 0.18)
                                    : AppTheme.cardSurface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: msg.isUser
                                      ? AppTheme.brandCoral.withValues(alpha: 0.3)
                                      : AppTheme.cardBorder,
                                ),
                              ),
                              child: Text(
                                msg.text,
                                style: const TextStyle(fontSize: 13, color: AppTheme.textLight),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Message Input Field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: AppTheme.cardSurface,
              border: Border(top: BorderSide(color: AppTheme.cardBorder)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _chatController,
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Chat with singles in ${venue.name}...',
                        hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                        filled: true,
                        fillColor: AppTheme.nightObsidian,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (val) {
                        widget.gameState.sendVenueChatMessage(venue.id, val);
                        _chatController.clear();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: AppTheme.brandCoral),
                    onPressed: () {
                      widget.gameState.sendVenueChatMessage(venue.id, _chatController.text);
                      _chatController.clear();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
