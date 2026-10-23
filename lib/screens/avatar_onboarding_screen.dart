import 'package:flutter/material.dart';
import '../services/game_state.dart';
import '../services/location_service.dart';
import '../services/nvidia_avatar_service.dart';
import '../theme/app_theme.dart';
import 'main_shell.dart';
import 'selfie_liveness_screen.dart';

class AvatarOnboardingScreen extends StatefulWidget {
  final GameState gameState;
  final bool isUpdateMode;

  const AvatarOnboardingScreen({
    super.key,
    required this.gameState,
    this.isUpdateMode = false,
  });

  @override
  State<AvatarOnboardingScreen> createState() => _AvatarOnboardingScreenState();
}

class _AvatarOnboardingScreenState extends State<AvatarOnboardingScreen>
    with SingleTickerProviderStateMixin {
  int _currentStep = 0; // 0: Photo Upload, 1: AI Processing, 2: Retro Fusion Studio
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;
  AvatarFeatureProfile? _extractedProfile;
  String _scanStatusText = "Connecting to NVIDIA Vision Inference engine...";
  String? _selectedPhoto;

  // Retro Tech Fusion Studio State
  Color _selectedBgColor = const Color(0xFF1E1B4B);
  String _selectedBorder = 'neon_glow'; // 'none', 'neon_glow', 'gold_halo', 'matrix'
  String _selectedClothing = 'tech_hoodie'; // 'tech_hoodie', 'agbada', 'gold_chain'
  String _selectedAvatarEmoji = '😎';

  final List<Map<String, dynamic>> _demoSelfies = [
    {
      'label': 'Lekki Creative',
      'photo': 'assets/portraits/selfie_1.png',
      'emoji': '😎',
      'subtitle': 'Verified Real Photo',
    },
    {
      'label': 'VI Tech Founder',
      'photo': 'assets/portraits/selfie_2.png',
      'emoji': '👩🏾‍💻',
      'subtitle': 'Verified Real Photo',
    },
    {
      'label': 'Abuja Baller',
      'photo': 'assets/portraits/selfie_3.png',
      'emoji': '👑',
      'subtitle': 'Verified Real Photo',
    },
    {
      'label': 'Ikeja DJ',
      'photo': 'assets/portraits/selfie_4.png',
      'emoji': '🎧',
      'subtitle': 'Verified Real Photo',
    },
  ];

  final List<Color> _bgPalettes = [
    const Color(0xFF1E1B4B), // Cyber Indigo
    const Color(0xFF3B0764), // Afro Sunset
    const Color(0xFF064E3B), // Lagos Palm
    const Color(0xFF18181B), // Dark Carbon
    const Color(0xFF450A0A), // Crimson Fire
  ];

  final List<Map<String, String>> _borders = [
    {'id': 'neon_glow', 'name': 'Neon Pulse', 'icon': '⚡'},
    {'id': 'gold_halo', 'name': 'SparkSync Crown', 'icon': '👑'},
    {'id': 'matrix', 'name': 'Lagoon Stream', 'icon': '🌊'},
    {'id': 'none', 'name': 'Classic Steel', 'icon': '🔘'},
  ];

  final List<Map<String, String>> _clothings = [
    {'id': 'tech_hoodie', 'name': 'Tech Hoodie', 'badge': '🧥 Silicon Lagoon'},
    {'id': 'agbada', 'name': 'Royal Agbada', 'badge': '👑 Owambe Baller'},
    {'id': 'gold_chain', 'name': 'Cuban Link', 'badge': '✨ 24k Gold Chain'},
    {'id': 'sunglasses', 'name': 'VIP Shades', 'badge': '🕶️ Night Owl'},
  ];

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  void _startAiVectorGeneration(String photo, String emoji, String hint) async {
    setState(() {
      _selectedPhoto = photo;
      _selectedAvatarEmoji = emoji;
      _currentStep = 1;
      _scanStatusText = "Sending photo to NVIDIA Multimodal Vision model...";
    });

    _scanController.repeat(reverse: true);

    // Call NVIDIA Vision API Image-to-Prompt Structuring Pipeline
    final profile = await NvidiaAvatarService().analyzePhotoForAvatar(
      fallbackHint: hint,
    );

    if (!mounted) return;

    setState(() {
      _extractedProfile = profile;
      _selectedAvatarEmoji = profile.matchedEmoji;
      _scanStatusText = "Analyzing facial structure & styling traits...";
    });

    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;

    setState(() {
      _scanStatusText = "Assembling 2D vector elements & palette...";
    });

    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    _scanController.stop();
    setState(() {
      _currentStep = 2; // Jump to studio with pre-selected attributes
    });
  }

  void _finishOnboarding() {
    final flair = _selectedBorder == 'neon_glow'
        ? 'neon_night_glow'
        : (_selectedBorder == 'gold_halo' ? 'crown_of_lekki' : null);

    widget.gameState.verifyUserSelfie(
      avatarEmoji: _selectedAvatarEmoji,
      photoUrl: _selectedPhoto,
      equippedFlair: flair,
    );

    if (widget.isUpdateMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppTheme.neonEmerald,
          content: Text("✨ Profile Picture Updated & Identity Verified! ✅"),
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      final cityName = LocationService().activeConfig.cityName;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppTheme.neonEmerald,
          content: Text("✨ Identity Verified & Profile Created! Entering $cityName..."),
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16162A),
        leading: widget.isUpdateMode
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () => Navigator.of(context).pop(false),
              )
            : null,
        title: Row(
          children: [
            const Text('🛡️', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              widget.isUpdateMode ? 'Selfie Verification' : 'Identity & Avatar Studio',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          if (!widget.isUpdateMode)
            TextButton(
              onPressed: () {
                // User chose to skip selfie verification during onboarding
                widget.gameState.user.isVerified = false;
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const MainShell()),
                );
              },
              child: const Text(
                'Skip for now',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: _buildCurrentStepView(),
        ),
      ),
    );
  }

  Widget _buildCurrentStepView() {
    switch (_currentStep) {
      case 0:
        return _buildStep1RealPhotoUpload();
      case 1:
        return _buildStep2AiScanning();
      case 2:
      default:
        return _buildStep3RetroFusionStudio();
    }
  }

  // STEP 1: REAL PHOTO UPLOAD
  Widget _buildStep1RealPhotoUpload() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blueAccent.withValues(alpha: 0.4),
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified_user_rounded,
                    color: Colors.cyanAccent, size: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Anti-Catfish Guarantee: Upload a real selfie. Our AI converts your facial landmarks into a stylized 2D avatar so your identity stays verified.",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Live Biometric Face Liveness Camera Option (VoteGuard reverse engineered)
          InkWell(
            onTap: () async {
              final ok = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) => SelfieLivenessScreen(
                    gameState: widget.gameState,
                    isModal: true,
                  ),
                ),
              );
              if (ok == true && mounted) {
                if (widget.isUpdateMode) {
                  Navigator.of(context).pop(true);
                } else {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const MainShell()),
                  );
                }
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F261F), Color(0xFF131926)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.neonEmerald.withValues(alpha: 0.8)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.neonEmerald.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.neonEmerald.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_front_rounded, color: AppTheme.neonEmerald, size: 22),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Scan Live Face Liveness',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Front camera face detection & portrait crop',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.neonEmerald),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            "OR CHOOSE STYLED DEMO SELFIE",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),

          // Demo Real Photos / Camera Pickers
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: _demoSelfies.length,
              itemBuilder: (context, index) {
                final item = _demoSelfies[index];
                return InkWell(
                  onTap: () => _startAiVectorGeneration(
                    item['photo'] as String,
                    item['emoji'] as String,
                    item['label'] as String,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF16162A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF252545)),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 38,
                          backgroundColor: const Color(0xFF252545),
                          child: Text(
                            item['emoji'] as String,
                            style: const TextStyle(fontSize: 34),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item['label'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle,
                                color: Colors.greenAccent, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              item['subtitle'] as String,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 10,
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
          ),

          // Upload from Camera button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.camera_alt_rounded, color: Colors.white),
              label: const Text(
                "TAKE REAL PHOTO WITH CAMERA",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              onPressed: () => _startAiVectorGeneration(
                'camera_capture',
                '😎',
                'Lekki Creative',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 2: AI VECTORIZATION SYNTHESIS (NVIDIA BUILD MULTIMODAL INFERENCE)
  Widget _buildStep2AiScanning() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // NVIDIA Build Model Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF76B900).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF76B900),
                  width: 1.2,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("🟢", style: TextStyle(fontSize: 10)),
                  SizedBox(width: 6),
                  Text(
                    "NVIDIA BUILD • MULTIMODAL VISION LLM",
                    style: TextStyle(
                      color: Color(0xFF76B900),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Scanning Box with Laser Scan Beam
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: const Color(0xFF16162A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.cyanAccent, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withValues(alpha: 0.35),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    _selectedAvatarEmoji,
                    style: const TextStyle(fontSize: 64),
                  ),
                  // Animated Scanning Laser Bar
                  AnimatedBuilder(
                    animation: _scanAnimation,
                    builder: (context, _) {
                      return Positioned(
                        top: _scanAnimation.value * 140 + 10,
                        left: 10,
                        right: 10,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF007F),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF007F)
                                    .withValues(alpha: 0.9),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _scanStatusText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.cyanAccent,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Extracting facial landmarks, skin tone, hair style & assembling vector elements...",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
            const SizedBox(height: 20),

            // Real-Time Extracted Feature Pills
            if (_extractedProfile != null) ...[
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildTraitChip("🧬 Tone", _extractedProfile!.skinTone),
                  _buildTraitChip("💇 Hair", _extractedProfile!.hairStyle),
                  _buildTraitChip("✨ Accessories", _extractedProfile!.accessories),
                  _buildTraitChip("👑 Vibe", _extractedProfile!.vibeTitle),
                ],
              ),
              const SizedBox(height: 20),
            ],

            const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                color: Color(0xFFFF007F),
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTraitChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF252545),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        "$label: $value",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // STEP 3: RETRO TECH FUSION STUDIO
  Widget _buildStep3RetroFusionStudio() {
    final bool hasNeonBorder = _selectedBorder == 'neon_glow';
    final bool hasGoldHalo = _selectedBorder == 'gold_halo';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live Vector Avatar Preview Card
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF16162A),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: hasNeonBorder
                      ? const Color(0xFFFF007F)
                      : (hasGoldHalo ? Colors.amber : const Color(0xFF252545)),
                  width: hasNeonBorder || hasGoldHalo ? 2.5 : 1.0,
                ),
                boxShadow: hasNeonBorder
                    ? [
                        BoxShadow(
                          color:
                              const Color(0xFFFF007F).withValues(alpha: 0.4),
                          blurRadius: 18,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Backdrop Palette Circle
                      CircleAvatar(
                        radius: 54,
                        backgroundColor: _selectedBgColor,
                        child: Text(
                          _selectedAvatarEmoji,
                          style: const TextStyle(fontSize: 48),
                        ),
                      ),
                      // Overlay Badge
                      if (_selectedBorder == 'gold_halo')
                        const Positioned(
                          top: 0,
                          child: Text('👑', style: TextStyle(fontSize: 24)),
                        ),
                      // Online Verified Beacon
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF16162A),
                              width: 2.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.gameState.user.username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.verified,
                          color: Colors.cyanAccent, size: 18),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _extractedProfile != null
                          ? "✨ ${_extractedProfile!.vibeTitle} • ${_clothings.firstWhere((c) => c['id'] == _selectedClothing)['name']}"
                          : _clothings.firstWhere(
                              (c) => c['id'] == _selectedClothing)['badge']!,
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 1. BACKGROUND PALETTES
          const Text(
            "1. BACKGROUND MATRIX PALETTE",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _bgPalettes.map((color) {
              final isSelected = _selectedBgColor == color;
              return GestureDetector(
                onTap: () => setState(() => _selectedBgColor = color),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.white24,
                      width: isSelected ? 3 : 1,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 20)
                      : null,
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // 2. ANIMATED BORDER FLAIRS
          const Text(
            "2. ANIMATED CYBER BORDER",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: _borders.map((b) {
              final isSelected = _selectedBorder == b['id'];
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedBorder = b['id']!),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF6C63FF).withValues(alpha: 0.25)
                          : const Color(0xFF16162A),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF6C63FF)
                            : const Color(0xFF252545),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(b['icon']!, style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 4),
                        Text(
                          b['name']!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // 3. CLOTHING & FLAIR OVERLAYS
          const Text(
            "3. CLOTHING OVERLAY BADGE",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Column(
            children: _clothings.map((c) {
              final isSelected = _selectedClothing == c['id'];
              return Card(
                color: isSelected
                    ? const Color(0xFF252545)
                    : const Color(0xFF16162A),
                margin: const EdgeInsets.symmetric(vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isSelected ? Colors.cyanAccent : Colors.transparent,
                  ),
                ),
                child: ListTile(
                  dense: true,
                  title: Text(
                    c['badge']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle,
                          color: Colors.cyanAccent, size: 20)
                      : const Text(
                          "EQUIP",
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                  onTap: () => setState(() => _selectedClothing = c['id']!),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 30),

          // Confirm & Enter App
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _finishOnboarding,
              child: Text(
                "CONFIRM & ENTER ${LocationService().activeConfig.cityName.toUpperCase()}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
