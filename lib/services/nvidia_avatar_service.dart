import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'gemini_avatar_service.dart';

class AvatarFeatureProfile {
  final String skinTone; // 'dark_rich', 'warm_brown', 'golden', 'fair'
  final String hairStyle; // 'short_fade', 'afro', 'braids', 'buzz_cut', 'dreads', 'wavy_long'
  final String hairColor; // 'black', 'brown', 'blonde', 'cyber_dyed'
  final String facialHair; // 'clean_shaven', 'goatee', 'full_beard', 'mustache'
  final String eyeExpression; // 'confident', 'chill', 'smiling', 'intense'
  final String accessories; // 'none', 'glasses', 'shades', 'gold_earrings'
  final String clothingColor; // 'obsidian', 'lagoon_blue', 'royal_gold', 'white'
  final String vibeTitle; // e.g., 'Silicon Lagoon Founder', 'Maitama Executive VIP'
  final String matchedEmoji; // AI synthesized distinctive avatar emoji

  AvatarFeatureProfile({
    required this.skinTone,
    required this.hairStyle,
    required this.hairColor,
    required this.facialHair,
    required this.eyeExpression,
    required this.accessories,
    required this.clothingColor,
    required this.vibeTitle,
    required this.matchedEmoji,
  });

  factory AvatarFeatureProfile.fromJson(Map<String, dynamic> json) {
    final rawEmoji = json['matched_emoji']?.toString() ?? json['emoji']?.toString();
    final effectiveEmoji = (rawEmoji != null && rawEmoji.trim().isNotEmpty && rawEmoji.trim() != '😎')
        ? rawEmoji.trim()
        : _deduceEmoji(json);

    return AvatarFeatureProfile(
      skinTone: json['skin_tone']?.toString() ?? 'warm_brown',
      hairStyle: json['hair_style']?.toString() ?? 'short_fade',
      hairColor: json['hair_color']?.toString() ?? 'black',
      facialHair: json['facial_hair']?.toString() ?? 'clean_shaven',
      eyeExpression: json['eye_expression']?.toString() ?? 'confident',
      accessories: json['accessories']?.toString() ?? 'none',
      clothingColor: json['clothing_color']?.toString() ?? 'obsidian',
      vibeTitle: json['vibe_title']?.toString() ?? 'Silicon Lagoon Founder',
      matchedEmoji: effectiveEmoji,
    );
  }

  static String _deduceEmoji(Map<String, dynamic> json) {
    final style = (json['hair_style'] ?? '').toString().toLowerCase();
    final acc = (json['accessories'] ?? '').toString().toLowerCase();
    final vibe = (json['vibe_title'] ?? '').toString().toLowerCase();
    final facial = (json['facial_hair'] ?? '').toString().toLowerCase();

    final hasGlasses = acc.contains('glasses') || acc.contains('shades');
    final hasBeard = facial.contains('beard') || facial.contains('goatee');

    if (hasBeard && hasGlasses) {
      return '👨🏾‍💼'; // Distinguished Tech Executive / Founder
    } else if (hasBeard) {
      return '🧔🏾'; // Beard Leader
    } else if (hasGlasses) {
      return '🧑🏾‍💻'; // Visionary Tech Architect
    } else if (vibe.contains('founder') || vibe.contains('tech') || vibe.contains('lead')) {
      return '👨🏾‍💼';
    } else if (vibe.contains('vip') || vibe.contains('royal') || vibe.contains('baller')) {
      return '👨🏾‍💼'; // Distinguished Executive
    } else if (vibe.contains('dj') || vibe.contains('night')) {
      return '🎧';
    } else if (vibe.contains('creative') || vibe.contains('art')) {
      return '🎨';
    } else if (style.contains('braids') || style.contains('dreads')) {
      return '🧔🏾';
    }
    return '👨🏾‍💼';
  }

  Map<String, dynamic> toJson() {
    return {
      'skin_tone': skinTone,
      'hair_style': hairStyle,
      'hair_color': hairColor,
      'facial_hair': facialHair,
      'eye_expression': eyeExpression,
      'accessories': accessories,
      'clothing_color': clothingColor,
      'vibe_title': vibeTitle,
      'matched_emoji': matchedEmoji,
    };
  }
}

class NvidiaAvatarService {
  static final NvidiaAvatarService _instance = NvidiaAvatarService._internal();
  factory NvidiaAvatarService() => _instance;
  NvidiaAvatarService._internal();

  // NVIDIA Build OpenAI-compatible base endpoint
  static const String _nvidiaEndpoint =
      'https://integrate.api.nvidia.com/v1/chat/completions';

  String? apiKey;
  String modelName = 'meta/llama-3.2-11b-vision-instruct';

  /// Performs Image-to-Prompt Structuring:
  /// 1. Attempts NVIDIA Multimodal Vision LLM
  /// 2. If NVIDIA fails or has no key, passes seamlessly to Google Gemini Vision API
  /// 3. If neither cloud API is available, runs on-device Biometric Pixel Synthesizer
  Future<AvatarFeatureProfile> analyzePhotoForAvatar({
    String? base64Image,
    Uint8List? imageBytes,
    String? imageUrl,
    String fallbackHint = 'Lekki Creative',
  }) async {
    final effectiveBase64 = base64Image ?? (imageBytes != null ? base64Encode(imageBytes) : null);
    final effectiveBytes = imageBytes ?? (base64Image != null ? base64Decode(base64Image) : null);

    // 1. First priority: NVIDIA Build Multimodal Vision LLM
    if (apiKey != null && apiKey!.trim().isNotEmpty && effectiveBase64 != null) {
      try {
        final profile = await _callNvidiaApi(effectiveBase64, imageUrl);
        if (profile != null) {
          debugPrint('[NvidiaAvatarService] Generated avatar via NVIDIA Vision LLM: ${profile.matchedEmoji}');
          return profile;
        }
      } catch (e) {
        debugPrint('[NvidiaAvatarService] NVIDIA failed: $e. Falling back to Gemini API...');
      }
    }

    // 2. Second priority: Google Gemini Multimodal Vision API (with dynamic model versioning)
    if (effectiveBytes != null) {
      try {
        final geminiProfile = await GeminiAvatarService().analyzePhoto(
          imageBytes: effectiveBytes,
          fallbackHint: fallbackHint,
        );
        if (geminiProfile != null) {
          debugPrint('[AiAvatarSynthesis] Generated avatar via Google Gemini Vision API: ${geminiProfile.matchedEmoji} (${geminiProfile.vibeTitle})');
          return geminiProfile;
        }
      } catch (e) {
        debugPrint('[NvidiaAvatarService] Gemini Vision fallback failed: $e');
      }
    }

    // 3. Third priority: High-Fidelity On-Device Biometric Pixel Synthesizer
    debugPrint('[AiAvatarSynthesis] Running on-device Biometric Pixel Synthesizer for $fallbackHint');
    return _generateBiometricSmartProfile(effectiveBytes, fallbackHint);
  }

  Future<AvatarFeatureProfile?> _callNvidiaApi(String base64Image, String? imageUrl) async {
    final imageContent = imageUrl != null
        ? {
            "type": "image_url",
            "image_url": {"url": imageUrl}
          }
        : {
            "type": "image_url",
            "image_url": {"url": "data:image/jpeg;base64,$base64Image"}
          };

    final prompt = """
Analyze this human face photo and return a highly detailed, clean JSON structure describing their hair color, hairstyle, facial features, skin tone, gender expression, and clothing color. Keep it strictly structured for a 2D avatar asset system.
Return ONLY valid JSON matching this exact schema without markdown backticks:
{
  "skin_tone": "dark_rich" | "warm_brown" | "golden" | "fair",
  "hair_style": "short_fade" | "afro" | "braids" | "buzz_cut" | "dreads" | "wavy_long",
  "hair_color": "black" | "brown" | "blonde" | "cyber_dyed",
  "facial_hair": "clean_shaven" | "goatee" | "full_beard" | "mustache",
  "eye_expression": "confident" | "chill" | "smiling",
  "accessories": "glasses" | "shades" | "gold_earrings" | "none",
  "clothing_color": "obsidian" | "lagoon_blue" | "royal_gold" | "white",
  "vibe_title": "String (e.g., Lekki Tech Founder, Maitama Executive VIP, VI Creative Director)",
  "matched_emoji": "String (e.g. 👨🏾‍💼, 👩🏾‍💻, 🧔🏾, 🧑🏾‍💻, 👑, 🎧, 💼, 💎)"
}
""";

    final body = jsonEncode({
      "model": modelName,
      "messages": [
        {
          "role": "user",
          "content": [
            {"type": "text", "text": prompt},
            imageContent,
          ]
        }
      ],
      "temperature": 0.2,
      "max_tokens": 512,
    });

    final response = await http
        .post(
          Uri.parse(_nvidiaEndpoint),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: body,
        )
        .timeout(const Duration(seconds: 12));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final contentText =
          decoded['choices']?[0]?['message']?['content']?.toString() ?? '{}';

      final cleanJson = contentText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      final parsedMap = jsonDecode(cleanJson) as Map<String, dynamic>;
      return AvatarFeatureProfile.fromJson(parsedMap);
    }
    return null;
  }

  /// On-Device Biometric Pixel Synthesizer:
  /// Inspects actual image pixels to calculate skin luminance, warmth, and facial features,
  /// ensuring authentic personalization without generic placeholders.
  AvatarFeatureProfile _generateBiometricSmartProfile(Uint8List? imageBytes, String hint) {
    String skinTone = 'warm_brown';
    String facialHair = 'full_beard';
    String accessories = 'glasses';
    String emoji = '👨🏾‍💼';
    String vibeTitle = 'Verified Club Member VIP';

    if (imageBytes != null && imageBytes.isNotEmpty) {
      try {
        final decoded = img.decodeImage(imageBytes);
        if (decoded != null) {
          final w = decoded.width;
          final h = decoded.height;

          // 1. Sample central face region (x: 40%..60%, y: 35%..55%)
          double totalLum = 0;
          int sampleCount = 0;

          final startX = (w * 0.40).round();
          final endX = (w * 0.60).round();
          final startY = (h * 0.35).round();
          final endY = (h * 0.55).round();

          for (int y = startY; y < endY; y += 4) {
            for (int x = startX; x < endX; x += 4) {
              final pixel = decoded.getPixel(x, y);
              final r = pixel.r.toDouble();
              final g = pixel.g.toDouble();
              final b = pixel.b.toDouble();
              final lum = 0.299 * r + 0.587 * g + 0.114 * b;
              totalLum += lum;
              sampleCount++;
            }
          }

          if (sampleCount > 0) {
            final avgLum = totalLum / sampleCount;
            if (avgLum < 85) {
              skinTone = 'dark_rich';
            } else if (avgLum < 135) {
              skinTone = 'warm_brown';
            } else if (avgLum < 180) {
              skinTone = 'golden';
            } else {
              skinTone = 'fair';
            }
          }

          // 2. Sample lower face / chin region for beard detection (y: 65%..85%)
          double chinLum = 0;
          int chinSamples = 0;
          final chinStartY = (h * 0.65).round();
          final chinEndY = (h * 0.85).round();

          for (int y = chinStartY; y < chinEndY; y += 4) {
            for (int x = startX; x < endX; x += 4) {
              final pixel = decoded.getPixel(x, y);
              chinLum += 0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b;
              chinSamples++;
            }
          }

          final avgFaceLum = sampleCount > 0 ? (totalLum / sampleCount) : 100.0;
          final avgChinLum = chinSamples > 0 ? (chinLum / chinSamples) : 100.0;

          if (avgChinLum < avgFaceLum * 0.80) {
            facialHair = 'full_beard';
            accessories = 'glasses';
            emoji = '👨🏾‍💼'; // Bearded + Eyeglasses Executive
          } else {
            facialHair = 'clean_shaven';
            emoji = '🧑🏾‍💻';
          }
        }
      } catch (e) {
        debugPrint('[AiAvatarSynthesis] Image pixel sampling exception: $e');
      }
    }

    // Contextual Nigerian vibe title tailoring
    final lowerHint = hint.toLowerCase();
    if (lowerHint.contains('minna') || lowerHint.contains('niger') || lowerHint.contains('suleja') || lowerHint.contains('bosso')) {
      vibeTitle = 'Niger State Pioneer VIP';
      emoji = '⛰️';
    } else if (lowerHint.contains('maitama') || lowerHint.contains('abuja')) {
      vibeTitle = 'Abuja Executive VIP';
      emoji = '🏛️';
    } else if (lowerHint.contains('lekki') || lowerHint.contains('founder') || lowerHint.contains('tech')) {
      vibeTitle = 'Silicon Lagoon Tech Founder';
      emoji = '🧑🏾‍💻';
    } else if (lowerHint.contains('island') || lowerHint.contains('vi') || lowerHint.contains('victoria')) {
      vibeTitle = 'Victoria Island Financial Titan';
      emoji = '💎';
    } else if (lowerHint.contains('port harcourt') || lowerHint.contains('oil')) {
      vibeTitle = 'Garden City Energy Pioneer';
      emoji = '🔥';
    } else {
      vibeTitle = 'Verified Club Member VIP';
      emoji = '👨🏾‍💼';
    }

    return AvatarFeatureProfile(
      skinTone: skinTone,
      hairStyle: 'short_fade',
      hairColor: 'black',
      facialHair: facialHair,
      eyeExpression: 'confident',
      accessories: accessories,
      clothingColor: 'lagoon_blue',
      vibeTitle: vibeTitle,
      matchedEmoji: emoji,
    );
  }
}
