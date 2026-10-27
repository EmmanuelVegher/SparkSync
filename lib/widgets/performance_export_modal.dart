import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/game_state.dart';
import '../services/performance_upload_service.dart';
import '../services/social_share_service.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';

/// Modal overlay for exporting performance clips to WhatsApp Status, TikTok, Instagram, and saving to user profile
class PerformanceExportModal extends StatefulWidget {
  final GameState gameState;
  final String performerName;
  final String performerAvatar;
  final String performerRank;
  final String trackTitle;
  final String trackArtist;
  final int totalVotes;
  final int xpEarned;
  final bool isAcapella;
  final Map<String, int> voteBreakdown;

  const PerformanceExportModal({
    super.key,
    required this.gameState,
    required this.performerName,
    required this.performerAvatar,
    required this.performerRank,
    required this.trackTitle,
    required this.trackArtist,
    required this.totalVotes,
    required this.xpEarned,
    this.isAcapella = false,
    this.voteBreakdown = const {},
  });

  @override
  State<PerformanceExportModal> createState() => _PerformanceExportModalState();
}

class _PerformanceExportModalState extends State<PerformanceExportModal> {
  bool _isSavingToProfile = false;
  bool _isSaved = false;

  Future<void> _shareToSocials({String? platformTag}) async {
    SoundService().playButtonTap();

    await SocialShareService().sharePerformance(
      performerName: widget.performerName,
      trackTitle: widget.trackTitle,
      trackArtist: widget.trackArtist,
      rankName: widget.performerRank,
      totalVotes: widget.totalVotes,
      xpEarned: widget.xpEarned,
      isAcapella: widget.isAcapella,
    );
  }

  void _copyWhatsAppCaption() {
    SoundService().playButtonTap();
    final caption = SocialShareService().generateWhatsAppStatusCaption(
      performerName: widget.performerName,
      trackTitle: widget.trackTitle,
      totalVotes: widget.totalVotes,
      rankName: widget.performerRank,
    );
    Clipboard.setData(ClipboardData(text: caption));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF25D366),
        content: Text(
          '📋 Viral WhatsApp Status caption copied! Paste straight to Status.',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _saveToProfile() async {
    if (_isSavingToProfile || _isSaved) return;

    setState(() {
      _isSavingToProfile = true;
    });

    final perf = await PerformanceUploadService().saveClipToUserProfile(
      userId: widget.gameState.user.username,
      username: widget.performerName,
      userAvatar: widget.performerAvatar,
      trackTitle: widget.trackTitle,
      trackArtist: widget.trackArtist,
      totalVotes: widget.totalVotes,
      xpEarned: widget.xpEarned,
      rankTitle: widget.performerRank,
      isAcapella: widget.isAcapella,
      voteBreakdown: widget.voteBreakdown,
    );

    if (perf != null) {
      widget.gameState.user.savedPerformances.insert(0, perf);
      widget.gameState.notifyListeners();
    }

    if (mounted) {
      setState(() {
        _isSavingToProfile = false;
        _isSaved = true;
      });
      SoundService().playSparkMatch();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.neonEmerald,
          content: Text(
            '🌟 Performance saved to your Profile Showcase! Fans can watch it anytime.',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 24),
      decoration: const BoxDecoration(
        color: Color(0xFF141928),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Text(
                    widget.isAcapella ? 'ACAPELLA SHOWCASE' : 'ROUND CONCLUDED!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Round Overview Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E1B4B), Color(0xFF101726)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF6C63FF).withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('🎉', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 6),
                    Text(
                      'PERFORMANCE STATS',
                      style: TextStyle(
                        color: Color(0xFF818CF8),
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _statColumn(
                        label: 'Votes Received',
                        value: '🗳️ ${widget.totalVotes}',
                        color: AppTheme.lagosYellow,
                      ),
                    ),
                    Expanded(
                      child: _statColumn(
                        label: 'Clout Earned',
                        value: '+${widget.xpEarned} XP',
                        color: AppTheme.neonEmerald,
                      ),
                    ),
                    Expanded(
                      child: _statColumn(
                        label: 'Status',
                        value: '🔥 On Fire',
                        color: Colors.cyanAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Clout Export Station Title
          const Row(
            children: [
              Text('📥', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Text(
                'CLOUT EXPORT STATION',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Share your vibe with your real-world circles to pull more votes and climb to Ultimate rank!',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
          ),
          const SizedBox(height: 16),

          // Action Grid: WhatsApp, TikTok, IG, Profile Save
          Row(
            children: [
              // WhatsApp Status
              Expanded(
                child: _socialTile(
                  title: 'WhatsApp Status',
                  subtitle: 'Post Video & Copy Link',
                  icon: Icons.chat_rounded,
                  color: const Color(0xFF25D366),
                  onTap: () => _shareToSocials(platformTag: 'whatsapp'),
                ),
              ),
              const SizedBox(width: 10),
              // TikTok
              Expanded(
                child: _socialTile(
                  title: 'TikTok Export',
                  subtitle: 'Trending Soundbite',
                  icon: Icons.music_note_rounded,
                  color: const Color(0xFF00F2FE),
                  onTap: () => _shareToSocials(platformTag: 'tiktok'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            children: [
              // Instagram Stories
              Expanded(
                child: _socialTile(
                  title: 'Instagram Stories',
                  subtitle: 'Share Video Reel',
                  icon: Icons.camera_alt_rounded,
                  color: const Color(0xFFE1306C),
                  onTap: () => _shareToSocials(platformTag: 'instagram'),
                ),
              ),
              const SizedBox(width: 10),
              // Save to Profile Showcase
              Expanded(
                child: _socialTile(
                  title: _isSaved ? 'Saved to Profile' : 'Save to Profile',
                  subtitle: _isSaved ? 'Visible on Profile' : 'Add to Star Showcase',
                  icon: _isSaved ? Icons.check_circle : Icons.bookmark_add_rounded,
                  color: _isSaved ? AppTheme.neonEmerald : Colors.amberAccent,
                  isLoading: _isSavingToProfile,
                  onTap: _saveToProfile,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Quick Copy Status Caption Helper Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF25D366), width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 11),
              ),
              icon: const Text('📋', style: TextStyle(fontSize: 14)),
              label: const Text(
                'Copy Pre-Formatted WhatsApp Status Caption',
                style: TextStyle(
                  color: Color(0xFF25D366),
                  fontWeight: FontWeight.bold,
                  fontSize: 11.5,
                ),
              ),
              onPressed: _copyWhatsAppCaption,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statColumn({required String label, required String value, required Color color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  Widget _socialTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 20),
                if (isLoading)
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: color),
                  )
                else
                  Icon(Icons.arrow_forward_ios_rounded, color: color.withValues(alpha: 0.7), size: 10),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
            ),
            Text(
              subtitle,
              style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 9.5),
            ),
          ],
        ),
      ),
    );
  }
}
