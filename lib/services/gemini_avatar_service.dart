import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'nvidia_avatar_service.dart';

/// Service for Google Gemini Multimodal Vision API with dynamic model discovery
/// and graceful fallback across retiring/evolving model versions.
class GeminiAvatarService {
  static final GeminiAvatarService _instance = GeminiAvatarService._internal();
  factory GeminiAvatarService() => _instance;
  GeminiAvatarService._internal();

  String? apiKey;

  /// Candidate vision models in order of priority.
  /// As older models retire (e.g., flash-1.0, 1.5, 2.0, 2.5), the waterfall automatically falls forward.
  static const List<String> _candidateModels = [
    'gemini-2.5-flash',
    'gemini-2.0-flash',
    'gemini-2.0-flash-exp',
    'gemini-1.5-flash',
    'gemini-1.5-flash-latest',
    'gemini-1.5-pro',
  ];

  /// Get current working API key from memory, SharedPreferences, or environment
  Future<String?> getActiveApiKey() async {
    if (apiKey != null && apiKey!.trim().isNotEmpty) {
      return apiKey!.trim();
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedKey = prefs.getString('gemini_api_key');
      if (storedKey != null && storedKey.trim().isNotEmpty) {
        return storedKey.trim();
      }
    } catch (_) {}

    try {
      final envKey = Platform.environment['GEMINI_API_KEY'];
      if (envKey != null && envKey.trim().isNotEmpty) {
        return envKey.trim();
      }
    } catch (_) {}

    return null;
  }

  /// Store user-provided Gemini API key
  Future<void> setApiKey(String key) async {
    apiKey = key.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gemini_api_key', apiKey!);
  }

  /// Discover active models dynamically from the Google API
  Future<List<String>> _discoverActiveVisionModels(String key) async {
    try {
      final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=$key');
      final res = await http.get(url).timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final models = (data['models'] as List? ?? []);
        final validModels = <String>[];

        for (final m in models) {
          final name = (m['name'] as String? ?? '').replaceFirst('models/', '');
          final supportedMethods = (m['supportedGenerationMethods'] as List? ?? []).cast<String>();
          if (supportedMethods.contains('generateContent') &&
              (name.contains('flash') || name.contains('pro') || name.contains('gemini'))) {
            validModels.add(name);
          }
        }

        if (validModels.isNotEmpty) {
          // Sort to prioritize flash models, newest version first
          validModels.sort((a, b) {
            final aIsFlash = a.contains('flash') ? 1 : 0;
            final bIsFlash = b.contains('flash') ? 1 : 0;
            if (aIsFlash != bIsFlash) return bIsFlash.compareTo(aIsFlash);
            return b.compareTo(a);
          });
          return validModels;
        }
      }
    } catch (e) {
      debugPrint('[GeminiAvatarService] Model discovery error (falling back to candidate list): $e');
    }
    return _candidateModels;
  }

  /// Analyze facial photo using Gemini Multimodal Vision
  Future<AvatarFeatureProfile?> analyzePhoto({
    required Uint8List imageBytes,
    String fallbackHint = 'Lagos Creative',
  }) async {
    final key = await getActiveApiKey();
    if (key == null || key.isEmpty) {
      debugPrint('[GeminiAvatarService] No Gemini API key available.');
      return null;
    }

    final modelsToTry = await _discoverActiveVisionModels(key);
    final base64Image = base64Encode(imageBytes);

    final prompt = """
You are an expert avatar stylist. Analyze this human portrait photograph and produce a high-fashion, vibrant, authentic Nigerian/African character breakdown.
Return ONLY valid JSON matching this schema with NO markdown backticks:
{
  "skin_tone": "dark_rich" | "warm_brown" | "golden" | "fair",
  "hair_style": "short_fade" | "afro" | "braids" | "buzz_cut" | "dreads" | "wavy_long",
  "hair_color": "black" | "brown" | "blonde" | "cyber_dyed",
  "facial_hair": "clean_shaven" | "goatee" | "full_beard" | "mustache",
  "eye_expression": "confident" | "chill" | "smiling" | "intense",
  "accessories": "glasses" | "shades" | "gold_earrings" | "none",
  "clothing_color": "obsidian" | "lagoon_blue" | "royal_gold" | "white",
  "vibe_title": "String (e.g. Maitama Executive VIP, Lekki Tech Founder, VI Creative Director, Silicon Lagoon Lead)",
  "matched_emoji": "String (Choose the single best matching character emoji from: 👨🏾‍💼, 👩🏾‍💻, 🧔🏾, 🧑🏾‍💻, 👑, 🎧, 💼, 💎, 🕺🏾, 👗, 🧐, 😎, 🔥, ✨)"
}
""";

    for (final model in modelsToTry) {
      try {
        debugPrint('[GeminiAvatarService] Attempting vision inference with model: $model');
        final endpoint = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$key',
        );

        final requestBody = jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": prompt},
                {
                  "inlineData": {
                    "mimeType": "image/jpeg",
                    "data": base64Image,
                  }
                }
              ]
            }
          ],
          "generationConfig": {
            "temperature": 0.3,
            "maxOutputTokens": 600,
          }
        });

        final response = await http
            .post(
              endpoint,
              headers: {'Content-Type': 'application/json'},
              body: requestBody,
            )
            .timeout(const Duration(seconds: 14));

        if (response.statusCode == 200) {
          final resJson = jsonDecode(response.body);
          final candidates = resJson['candidates'] as List? ?? [];
          if (candidates.isNotEmpty) {
            final parts = candidates[0]['content']?['parts'] as List? ?? [];
            if (parts.isNotEmpty) {
              final rawText = parts[0]['text'] as String? ?? '{}';
              final cleanJson = rawText
                  .replaceAll('```json', '')
                  .replaceAll('```', '')
                  .trim();

              final parsedMap = jsonDecode(cleanJson) as Map<String, dynamic>;
              debugPrint('[GeminiAvatarService] Successfully generated avatar profile via $model: $parsedMap');
              return AvatarFeatureProfile.fromJson(parsedMap);
            }
          }
        } else if (response.statusCode == 404 || response.statusCode == 400) {
          debugPrint('[GeminiAvatarService] Model $model returned ${response.statusCode} (likely retired or unsupported). Trying next candidate...');
          continue;
        } else {
          debugPrint('[GeminiAvatarService] Model $model returned ${response.statusCode}: ${response.body}');
        }
      } catch (e) {
        debugPrint('[GeminiAvatarService] Exception with model $model: $e. Trying next candidate...');
      }
    }

    return null;
  }
}
