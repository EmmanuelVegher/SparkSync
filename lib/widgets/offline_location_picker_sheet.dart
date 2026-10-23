import 'package:flutter/material.dart';
import '../models/nigeria_locations.dart';
import '../services/game_state.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';

class OfflineLocationPickerSheet extends StatefulWidget {
  final GameState gameState;

  const OfflineLocationPickerSheet({super.key, required this.gameState});

  @override
  State<OfflineLocationPickerSheet> createState() => _OfflineLocationPickerSheetState();
}

class _OfflineLocationPickerSheetState extends State<OfflineLocationPickerSheet> {
  late String _selectedState;
  late String _selectedLga;
  late String _selectedArea;
  bool _isGpsLocating = false;

  @override
  void initState() {
    super.initState();
    final user = widget.gameState.user;
    _selectedState = user.stateName.isNotEmpty ? user.stateName : 'Federal Capital Territory (FCT)';
    _selectedLga = user.lgaName.isNotEmpty ? user.lgaName : 'Abuja Municipal (AMAC)';
    _selectedArea = user.areaName.isNotEmpty ? user.areaName : 'Central Area';

    // Ensure valid selections from offline database
    _validateStateAndLga();
  }

  void _validateStateAndLga() {
    final stateObj = nigeriaStates.firstWhere(
      (s) => s.name.toLowerCase() == _selectedState.toLowerCase(),
      orElse: () => nigeriaStates.first,
    );
    _selectedState = stateObj.name;

    final lgaObj = stateObj.lgas.firstWhere(
      (l) => l.name.toLowerCase() == _selectedLga.toLowerCase(),
      orElse: () => stateObj.lgas.first,
    );
    _selectedLga = lgaObj.name;

    if (!lgaObj.areas.any((a) => a.toLowerCase() == _selectedArea.toLowerCase())) {
      _selectedArea = lgaObj.areas.isNotEmpty ? lgaObj.areas.first : 'Central Area';
    }
  }

  List<NigeriaLga> get _currentLgas {
    final stateObj = nigeriaStates.firstWhere(
      (s) => s.name == _selectedState,
      orElse: () => nigeriaStates.first,
    );
    return stateObj.lgas;
  }

  List<String> get _currentAreas {
    final lgaObj = _currentLgas.firstWhere(
      (l) => l.name == _selectedLga,
      orElse: () => _currentLgas.first,
    );
    return lgaObj.areas;
  }

  Future<void> _detectGpsOffline() async {
    setState(() => _isGpsLocating = true);
    try {
      final pos = await LocationService().requestLiveGpsUpdate();
      if (pos != null) {
        final loc = LocationService();
        widget.gameState.updateUserLocation(
          state: loc.currentState,
          lga: loc.currentLga,
          area: loc.currentArea,
          country: loc.currentCountry,
        );
        setState(() {
          _selectedState = loc.currentState;
          _selectedLga = loc.currentLga;
          _selectedArea = loc.currentArea;
          _validateStateAndLga();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppTheme.neonEmerald,
              content: Text('📍 Live Location: ${widget.gameState.user.dynamicLocationDisplay}'),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppTheme.lagosYellow,
              content: Text('Please enable GPS/Location in device settings.'),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('[LocationPicker] GPS error: $e');
    } finally {
      if (mounted) setState(() => _isGpsLocating = false);
    }
  }

  void _saveLocation() {
    widget.gameState.updateUserLocation(
      state: _selectedState,
      lga: _selectedLga,
      area: _selectedArea,
      country: widget.gameState.user.countryName,
    );
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.neonEmerald,
        content: Text('✅ Location updated to ${widget.gameState.user.dynamicLocationDisplay}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF101524),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
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
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title & Subtitle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📍 Your Dynamic Location',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Offline-First • State, LGA & Ward Level',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.neonEmerald.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.neonEmerald.withValues(alpha: 0.3)),
                  ),
                  child: const Text(
                    '⚡ OFFLINE READY',
                    style: TextStyle(color: AppTheme.neonEmerald, fontSize: 9.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // GPS Quick Auto-Detect Button
            InkWell(
              onTap: _isGpsLocating ? null : _detectGpsOffline,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.brandCoral.withValues(alpha: 0.2),
                      AppTheme.lagosYellow.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.brandCoral.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isGpsLocating)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.brandCoral),
                      )
                    else
                      const Icon(Icons.my_location_rounded, color: AppTheme.brandCoral, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _isGpsLocating ? 'Querying Device GPS Hardware...' : 'Auto-Detect via GPS (Satellite / Offline)',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 1. STATE SELECTOR
            const Text(
              '1. STATE',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 10.5, fontWeight: FontWeight.bold, letterSpacing: 0.8),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppTheme.cardSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedState,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF181F30),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textMuted),
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                  items: nigeriaStates.map((s) {
                    return DropdownMenuItem<String>(
                      value: s.name,
                      child: Text(s.name),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedState = val;
                        final stateObj = nigeriaStates.firstWhere((s) => s.name == val);
                        _selectedLga = stateObj.lgas.first.name;
                        _selectedArea = stateObj.lgas.first.areas.first;
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 2. LGA SELECTOR
            const Text(
              '2. LOCAL GOVERNMENT AREA (LGA)',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 10.5, fontWeight: FontWeight.bold, letterSpacing: 0.8),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppTheme.cardSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLga,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF181F30),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textMuted),
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                  items: _currentLgas.map((lga) {
                    return DropdownMenuItem<String>(
                      value: lga.name,
                      child: Text(lga.name),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedLga = val;
                        final lgaObj = _currentLgas.firstWhere((l) => l.name == val);
                        _selectedArea = lgaObj.areas.isNotEmpty ? lgaObj.areas.first : 'Central Area';
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 3. AREA / WARD SELECTOR
            const Text(
              '3. PART OF LGA / WARD / NEIGHBORHOOD',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 10.5, fontWeight: FontWeight.bold, letterSpacing: 0.8),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppTheme.cardSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.cardBorder),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _currentAreas.contains(_selectedArea) ? _selectedArea : _currentAreas.first,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF181F30),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textMuted),
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                  items: _currentAreas.map((area) {
                    return DropdownMenuItem<String>(
                      value: area,
                      child: Text(area),
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

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.brandCoral,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: _saveLocation,
                child: const Text(
                  '✓ Update Location & Sync Rooms',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
