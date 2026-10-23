import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/game_state.dart';
import '../services/sound_service.dart';
import '../theme/app_theme.dart';

class TwoGoPresenceSheet extends StatefulWidget {
  final GameState gameState;

  const TwoGoPresenceSheet({super.key, required this.gameState});

  @override
  State<TwoGoPresenceSheet> createState() => _TwoGoPresenceSheetState();
}

class _TwoGoPresenceSheetState extends State<TwoGoPresenceSheet> {
  late TwoGoPresence _selectedPresence;
  late TextEditingController _statusController;

  final List<String> _quickStatusPresets = [
    'Available to connect ✨',
    'Chilling at Landmark Beach 🏖️',
    'Suya run in progress 🍢',
    'Football banter mode ⚽',
    'In a meeting, ping me later 📵',
    'Looking for my Main Squeeze 🔒',
    'Lagos traffic got me 🚗💨',
    'Stealth mode on 🕶️',
  ];

  @override
  void initState() {
    super.initState();
    _selectedPresence = widget.gameState.user.presence;
    _statusController = TextEditingController(text: widget.gameState.user.statusText);
  }

  @override
  void dispose() {
    _statusController.dispose();
    super.dispose();
  }

  void _savePresenceAndStatus() {
    widget.gameState.updateUserPresence(_selectedPresence);
    if (_statusController.text.trim().isNotEmpty) {
      widget.gameState.updateStatusText(_statusController.text.trim());
    }
    SoundService().playCoinEarned();
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.cardSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: _getPresenceColor(_selectedPresence), width: 1.5),
        ),
        content: Row(
          children: [
            Text(_selectedPresence.indicatorEmoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Status updated to "${_selectedPresence.label}"',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPresenceColor(TwoGoPresence p) {
    switch (p) {
      case TwoGoPresence.online:
        return AppTheme.neonEmerald;
      case TwoGoPresence.busy:
        return const Color(0xFFFF3B30);
      case TwoGoPresence.away:
        return AppTheme.lagosYellow;
      case TwoGoPresence.offline:
        return AppTheme.textMuted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.gameState.user;

    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF111726),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Color(0xFF222C42), width: 1.5),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Grab Handle
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
            const SizedBox(height: 18),

            // User Header Row
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppTheme.skyCyan, AppTheme.purpleRoyal],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _getPresenceColor(_selectedPresence).withValues(alpha: 0.35),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(user.avatarEmoji, style: const TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _getPresenceColor(_selectedPresence),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Current: ${_selectedPresence.label}',
                            style: TextStyle(
                              color: _getPresenceColor(_selectedPresence),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.cardSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.cardBorder),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('SparkSync Style', style: TextStyle(color: AppTheme.lagosYellow, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // Presence Options Title
            const Text(
              'SET YOUR PRESENCE (SPARKSYNC STATUS)',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 12),

            // 4 Presence Radios
            ...TwoGoPresence.values.map((presence) {
              final isSelected = _selectedPresence == presence;
              final pColor = _getPresenceColor(presence);

              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedPresence = presence;
                    });
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? pColor.withValues(alpha: 0.12) : AppTheme.cardSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? pColor : AppTheme.cardBorder,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(presence.indicatorEmoji, style: const TextStyle(fontSize: 18)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                presence.label,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                presence.description,
                                style: const TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle_rounded, color: pColor, size: 20)
                        else
                          Icon(Icons.radio_button_unchecked, color: Colors.white24, size: 18),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 18),

            // Custom Status Text Section
            const Text(
              '1-LINE STATUS MESSAGE',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _statusController,
              maxLength: 60,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.cardSurface,
                hintText: 'What is on your mind? (e.g. Suya & banter tonight)',
                hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                counterStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.cardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.skyCyan, width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Quick Presets Pills
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _quickStatusPresets.map((preset) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      _statusController.text = preset;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.cardSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.cardBorder),
                    ),
                    child: Text(
                      preset,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textLight),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _savePresenceAndStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getPresenceColor(_selectedPresence),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'Update Status & Presence',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
