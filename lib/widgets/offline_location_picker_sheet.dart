import 'package:flutter/material.dart';
import '../models/nigeria_locations.dart';
import '../services/game_state.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';

class TravelModeSheet extends StatefulWidget {
  final GameState gameState;

  const TravelModeSheet({super.key, required this.gameState});

  @override
  State<TravelModeSheet> createState() => _TravelModeSheetState();
}

typedef OfflineLocationPickerSheet = TravelModeSheet;

class _TravelModeSheetState extends State<TravelModeSheet> {
  late String _selectedState;
  late String _selectedLga;
  late String _selectedArea;
  bool _isGpsLocating = false;

  // Preset popular travel hubs for 1-tap teleportation
  static const List<Map<String, String>> _travelHotspots = [
    {
      'label': 'Lagos (VI)',
      'emoji': '🏙️',
      'state': 'Lagos State',
      'lga': 'Eti-Osa',
      'area': 'Victoria Island (VI)',
    },
    {
      'label': 'Abuja (Maitama)',
      'emoji': '🏛️',
      'state': 'Federal Capital Territory (FCT)',
      'lga': 'Abuja Municipal (AMAC)',
      'area': 'Maitama',
    },
    {
      'label': 'Port Harcourt',
      'emoji': '⚓',
      'state': 'Rivers State',
      'lga': 'Port-Harcourt',
      'area': 'Old GRA',
    },
    {
      'label': 'Minna',
      'emoji': '⛰️',
      'state': 'Niger State',
      'lga': 'Chanchaga',
      'area': 'Minna Central',
    },
    {
      'label': 'Kano',
      'emoji': '🕌',
      'state': 'Kano State',
      'lga': 'Nassarawa',
      'area': 'Bompai',
    },
    {
      'label': 'Enugu',
      'emoji': '⛰️',
      'state': 'Enugu State',
      'lga': 'Enugu North',
      'area': 'Independence Layout',
    },
    {
      'label': 'Jos',
      'emoji': '🌲',
      'state': 'Plateau State',
      'lga': 'Jos South',
      'area': 'Rayfield',
    },
    {
      'label': 'Ibadan',
      'emoji': '🏛️',
      'state': 'Oyo State',
      'lga': 'Ibadan North',
      'area': 'Bodija',
    },
    {
      'label': 'Benin City',
      'emoji': '👑',
      'state': 'Edo State',
      'lga': 'Oredo',
      'area': 'GRA',
    },
    {
      'label': 'Uyo',
      'emoji': '⚡',
      'state': 'Akwa Ibom State',
      'lga': 'Uyo',
      'area': 'Ewet Housing Estate',
    },
  ];

  @override
  void initState() {
    super.initState();
    final user = widget.gameState.user;
    _selectedState = user.stateName.isNotEmpty ? user.stateName : 'Federal Capital Territory (FCT)';
    _selectedLga = user.lgaName.isNotEmpty ? user.lgaName : 'Abuja Municipal (AMAC)';
    _selectedArea = user.areaName.isNotEmpty ? user.areaName : 'Central Area';

    _validateStateAndLga();
  }

  void _validateStateAndLga() {
    final stateMatch = nigeriaStates.where(
      (s) => s.name.toLowerCase() == _selectedState.toLowerCase() ||
             s.name.toLowerCase().contains(_selectedState.toLowerCase()) ||
             _selectedState.toLowerCase().contains(s.name.toLowerCase()),
    );
    final stateObj = stateMatch.isNotEmpty ? stateMatch.first : nigeriaStates.first;
    _selectedState = stateObj.name;

    final lgaMatch = stateObj.lgas.where(
      (l) => l.name.toLowerCase() == _selectedLga.toLowerCase() ||
             l.name.toLowerCase().contains(_selectedLga.toLowerCase()) ||
             _selectedLga.toLowerCase().contains(l.name.toLowerCase()),
    );
    final lgaObj = lgaMatch.isNotEmpty ? lgaMatch.first : stateObj.lgas.first;
    _selectedLga = lgaObj.name;

    final areaMatch = lgaObj.areas.where(
      (a) => a.toLowerCase() == _selectedArea.toLowerCase() ||
             a.toLowerCase().contains(_selectedArea.toLowerCase()) ||
             _selectedArea.toLowerCase().contains(a.toLowerCase()),
    );
    if (areaMatch.isNotEmpty) {
      _selectedArea = areaMatch.first;
    } else {
      _selectedArea = lgaObj.areas.isNotEmpty ? lgaObj.areas.first : 'Central Ward';
    }
  }

  List<NigeriaLga> get _currentLgas {
    final stateMatch = nigeriaStates.where((s) => s.name == _selectedState);
    final stateObj = stateMatch.isNotEmpty ? stateMatch.first : nigeriaStates.first;
    return stateObj.lgas;
  }

  List<String> get _currentAreas {
    final lgaMatch = _currentLgas.where((l) => l.name == _selectedLga);
    final lgaObj = lgaMatch.isNotEmpty ? lgaMatch.first : (_currentLgas.isNotEmpty ? _currentLgas.first : null);
    return lgaObj?.areas ?? const ['Central Ward'];
  }

  void _selectHotspot(Map<String, String> spot) {
    setState(() {
      _selectedState = spot['state']!;
      _selectedLga = spot['lga']!;
      _selectedArea = spot['area']!;
      _validateStateAndLga();
    });
  }

  Future<void> _returnToLiveGps() async {
    setState(() => _isGpsLocating = true);
    try {
      await widget.gameState.detectLiveGpsLocation();
      final loc = LocationService();
      setState(() {
        _selectedState = loc.currentState;
        _selectedLga = loc.currentLga;
        _selectedArea = loc.currentArea;
        _validateStateAndLga();
      });
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.neonEmerald,
            content: Text('📍 Live GPS Restored: ${widget.gameState.user.dynamicLocationDisplay}'),
          ),
        );
      }
    } catch (e) {
      debugPrint('[TravelModeSheet] Live GPS error: $e');
    } finally {
      if (mounted) setState(() => _isGpsLocating = false);
    }
  }

  void _activateTravelMode() {
    widget.gameState.updateUserLocation(
      state: _selectedState,
      lga: _selectedLga,
      area: _selectedArea,
      country: widget.gameState.user.countryName,
      isTravelMode: true,
    );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0071E3),
        content: Text('✈️ Teleported to ${widget.gameState.user.dynamicLocationDisplay}! Chat rooms & venues updated.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTravelMode = widget.gameState.user.isTravelMode;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF101524) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : const Color(0xFFD1D1D6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title & Travel Mode Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '✈️ Travel Mode',
                              style: TextStyle(
                                color: isDark ? Colors.white : AppTheme.textDark,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Teleport to any city • Meet locals & sync chatrooms',
                          style: TextStyle(
                            color: isDark ? AppTheme.textMuted : const Color(0xFF8E8E93),
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                    decoration: BoxDecoration(
                      color: isTravelMode
                          ? (isDark ? Colors.cyanAccent.withValues(alpha: 0.18) : const Color(0xFF0071E3).withValues(alpha: 0.12))
                          : (isDark ? AppTheme.neonEmerald.withValues(alpha: 0.15) : const Color(0xFF34C759).withValues(alpha: 0.12)),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isTravelMode
                            ? (isDark ? Colors.cyanAccent.withValues(alpha: 0.5) : const Color(0xFF0071E3).withValues(alpha: 0.4))
                            : (isDark ? AppTheme.neonEmerald.withValues(alpha: 0.4) : const Color(0xFF34C759).withValues(alpha: 0.4)),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isTravelMode ? '✈️ TRAVELING' : '📍 LIVE GPS',
                          style: TextStyle(
                            color: isTravelMode
                                ? (isDark ? Colors.cyanAccent : const Color(0xFF0071E3))
                                : (isDark ? AppTheme.neonEmerald : const Color(0xFF1B873F)),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Active Travel Status Banner (with 1-tap Return to GPS)
              if (isTravelMode) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF161F36) : const Color(0xFFF0F6FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? Colors.cyanAccent.withValues(alpha: 0.3) : const Color(0xFF0071E3).withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text('✈️', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Currently Traveling',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : const Color(0xFF0071E3),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              widget.gameState.user.dynamicLocationDisplay,
                              style: TextStyle(
                                color: isDark ? Colors.white : AppTheme.textDark,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: _isGpsLocating ? null : _returnToLiveGps,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.brandCoral.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.brandCoral.withValues(alpha: 0.35)),
                          ),
                          child: Text(
                            _isGpsLocating ? 'Detecting...' : '📍 Exit Travel',
                            style: const TextStyle(
                              color: AppTheme.brandCoral,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Quick Teleport Hubs Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'QUICK TELEPORT DESTINATIONS',
                    style: TextStyle(
                      color: isDark ? AppTheme.textMuted : const Color(0xFF6E6E73),
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    '1-Tap Teleport',
                    style: TextStyle(
                      color: isDark ? Colors.cyanAccent : const Color(0xFF0071E3),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Quick Teleport Chips (Horizontal Scroll)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _travelHotspots.map((spot) {
                    final isCurrentSpot = _selectedState == spot['state'] && _selectedLga == spot['lga'];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => _selectHotspot(spot),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                          decoration: BoxDecoration(
                            color: isCurrentSpot
                                ? (isDark ? Colors.cyanAccent.withValues(alpha: 0.2) : const Color(0xFF0071E3).withValues(alpha: 0.12))
                                : (isDark ? AppTheme.cardSurface : const Color(0xFFF2F2F7)),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isCurrentSpot
                                  ? (isDark ? Colors.cyanAccent : const Color(0xFF0071E3))
                                  : (isDark ? AppTheme.cardBorder : const Color(0xFFE5E5EA)),
                              width: isCurrentSpot ? 1.5 : 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(spot['emoji']!, style: const TextStyle(fontSize: 13)),
                              const SizedBox(width: 5),
                              Text(
                                spot['label']!,
                                style: TextStyle(
                                  color: isCurrentSpot
                                      ? (isDark ? Colors.cyanAccent : const Color(0xFF0071E3))
                                      : (isDark ? Colors.white : AppTheme.textDark),
                                  fontSize: 11.5,
                                  fontWeight: isCurrentSpot ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 18),

              // 1. STATE SELECTOR
              Text(
                '1. DESTINATION STATE (${nigeriaStates.length} AVAILABLE)',
                style: TextStyle(
                  color: isDark ? AppTheme.textMuted : const Color(0xFF6E6E73),
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.cardSurface : const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? AppTheme.cardBorder : const Color(0xFFE5E5EA),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: nigeriaStates.any((s) => s.name == _selectedState)
                        ? _selectedState
                        : nigeriaStates.first.name,
                    isExpanded: true,
                    dropdownColor: isDark ? const Color(0xFF181F30) : Colors.white,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: isDark ? AppTheme.textMuted : const Color(0xFF8E8E93),
                    ),
                    style: TextStyle(
                      color: isDark ? Colors.white : AppTheme.textDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    items: nigeriaStates.map((s) {
                      return DropdownMenuItem<String>(
                        value: s.name,
                        child: Text(s.name, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedState = val;
                          final stateObj = nigeriaStates.firstWhere(
                            (s) => s.name == val,
                            orElse: () => nigeriaStates.first,
                          );
                          _selectedLga = stateObj.lgas.first.name;
                          _selectedArea = stateObj.lgas.first.areas.isNotEmpty
                              ? stateObj.lgas.first.areas.first
                              : 'Central Ward';
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 2. LGA SELECTOR
              Text(
                '2. LOCAL GOVERNMENT AREA (LGA) (${_currentLgas.length} IN $_selectedState)',
                style: TextStyle(
                  color: isDark ? AppTheme.textMuted : const Color(0xFF6E6E73),
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.cardSurface : const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? AppTheme.cardBorder : const Color(0xFFE5E5EA),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _currentLgas.any((l) => l.name == _selectedLga)
                        ? _selectedLga
                        : (_currentLgas.isNotEmpty ? _currentLgas.first.name : null),
                    isExpanded: true,
                    dropdownColor: isDark ? const Color(0xFF181F30) : Colors.white,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: isDark ? AppTheme.textMuted : const Color(0xFF8E8E93),
                    ),
                    style: TextStyle(
                      color: isDark ? Colors.white : AppTheme.textDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    items: _currentLgas.map((lga) {
                      return DropdownMenuItem<String>(
                        value: lga.name,
                        child: Text(lga.name, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedLga = val;
                          final lgaObj = _currentLgas.firstWhere(
                            (l) => l.name == val,
                            orElse: () => _currentLgas.first,
                          );
                          _selectedArea = lgaObj.areas.isNotEmpty
                              ? lgaObj.areas.first
                              : 'Central Ward';
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 3. AREA / WARD SELECTOR
              Text(
                '3. WARD / NEIGHBORHOOD (${_currentAreas.length} IN $_selectedLga)',
                style: TextStyle(
                  color: isDark ? AppTheme.textMuted : const Color(0xFF6E6E73),
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.cardSurface : const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? AppTheme.cardBorder : const Color(0xFFE5E5EA),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _currentAreas.contains(_selectedArea)
                        ? _selectedArea
                        : (_currentAreas.isNotEmpty ? _currentAreas.first : null),
                    isExpanded: true,
                    dropdownColor: isDark ? const Color(0xFF181F30) : Colors.white,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: isDark ? AppTheme.textMuted : const Color(0xFF8E8E93),
                    ),
                    style: TextStyle(
                      color: isDark ? Colors.white : AppTheme.textDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    items: _currentAreas.map((area) {
                      return DropdownMenuItem<String>(
                        value: area,
                        child: Text(area, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedArea = val;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Primary Action: Travel to Destination & Sync Rooms
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0071E3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: _activateTravelMode,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.flight_takeoff_rounded, size: 18),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Travel to $_selectedLga & Sync Rooms',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Secondary Action: GPS Real Location Auto-Detect
              SizedBox(
                width: double.infinity,
                height: 42,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? Colors.white70 : AppTheme.textDark,
                    side: BorderSide(
                      color: isDark ? AppTheme.cardBorder : const Color(0xFFD1D1D6),
                      width: 0.8,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isGpsLocating ? null : _returnToLiveGps,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (_isGpsLocating)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.brandCoral),
                        )
                      else
                        const Icon(Icons.my_location_rounded, size: 15, color: AppTheme.brandCoral),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _isGpsLocating ? 'Detecting Live GPS...' : 'Return to Real Location (Live GPS)',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
