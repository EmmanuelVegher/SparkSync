import 'package:flutter/material.dart';

class ProfileCardModal extends StatefulWidget {
  final String username;
  final String rankName;
  final String statusText;
  final String location;
  final int giftsSent;
  final bool hasNeonGlow;
  final VoidCallback? onSendMessage;
  final VoidCallback? onBuyDrink;

  const ProfileCardModal({
    super.key,
    required this.username,
    required this.rankName,
    required this.statusText,
    required this.location,
    required this.giftsSent,
    this.hasNeonGlow = true,
    this.onSendMessage,
    this.onBuyDrink,
  });

  @override
  State<ProfileCardModal> createState() => _ProfileCardModalState();
}

class _ProfileCardModalState extends State<ProfileCardModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  // Flutter does not have Colors.magentaAccent by default, so we define it here:
  static const Color neonMagenta = Color(0xFFFF007F);
  static const Color neonCyan = Color(0xFF00E5FF);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true); // Continuous breathing pulse loop

    _pulseAnimation = Tween<double>(begin: 2.0, end: 12.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFF121224), // Background panel
              borderRadius: BorderRadius.circular(20),
              border: widget.hasNeonGlow
                  ? Border.all(
                      color: neonMagenta.withValues(alpha: 0.8),
                      width: 2,
                    )
                  : null,
              boxShadow: widget.hasNeonGlow
                  ? [
                      BoxShadow(
                        color: neonMagenta.withValues(alpha: 0.4),
                        blurRadius: _pulseAnimation.value,
                        spreadRadius: _pulseAnimation.value / 3,
                      ),
                      BoxShadow(
                        color: neonCyan.withValues(alpha: 0.3),
                        blurRadius: _pulseAnimation.value * 1.5,
                      ),
                    ]
                  : [],
            ),
            child: child,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "⚡ PING INTERACTION LOUNGE",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Profile Canvas Info Row
              Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: const Color(0xFF252545),
                        child: Text(
                          widget.username.isNotEmpty
                              ? widget.username[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 28,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF121224),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.username,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.verified,
                                color: neonCyan, size: 18),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "👑 ${widget.rankName.toUpperCase()}",
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '"${widget.statusText}"',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: Color(0xFF252545)),
              const SizedBox(height: 10),

              // Stats Deck Layout Elements
              const Text(
                "📊 STATS DECK",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildStatRow(Icons.location_on, "Location", widget.location),
              _buildStatRow(
                Icons.favorite,
                "Relationship Level",
                "Tier 2 (Good Vibe 🍃)",
              ),
              _buildStatRow(
                Icons.card_giftcard,
                "Generosity Score",
                "🎁 ${widget.giftsSent} Gifts Sent",
              ),

              const SizedBox(height: 25),

              // Action Buttons Row Footer
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: widget.onSendMessage ??
                          () {
                            Navigator.of(context).pop();
                          },
                      child: const Text(
                        "💬 SEND MESSAGE",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.amber),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: widget.onBuyDrink ??
                          () {
                            Navigator.of(context).pop();
                          },
                      child: const Text(
                        "🎁 BUY A DRINK (50 Cr)",
                        style: TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white38, size: 16),
          const SizedBox(width: 8),
          Text("$title: ",
              style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
