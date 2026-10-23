import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'nvidia_avatar_service.dart';

class PhotoVaultService {
  static final PhotoVaultService _instance = PhotoVaultService._internal();
  factory PhotoVaultService() => _instance;
  PhotoVaultService._internal();

  static const String _prefKeyVerified = 'sparksync_vault_verified';
  static const String _prefKeyPhotoPath = 'sparksync_vault_photo_path';
  static const String _prefKeyCloudUrl = 'sparksync_vault_cloud_url';
  static const String _prefKeyAvatarEmoji = 'sparksync_vault_avatar_emoji';
  static const String _prefKeyTraitsJson = 'sparksync_vault_traits_json';

  Future<Directory> _getVaultDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final vaultDir = Directory('${appDir.path}/photo_vault');
    if (!await vaultDir.exists()) {
      await vaultDir.create(recursive: true);
    }
    return vaultDir;
  }

  /// Store selfie photo bytes & avatar traits locally in the secure Vault
  Future<File> saveToVault({
    required Uint8List imageBytes,
    required String username,
    AvatarFeatureProfile? traits,
    String? cloudUrl,
  }) async {
    final vaultDir = await _getVaultDirectory();
    final cleanUsername = username.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    final filePath = '${vaultDir.path}/vault_selfie_$cleanUsername.jpg';
    final file = File(filePath);

    await file.writeAsBytes(imageBytes, flush: true);

    // Save metadata into SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKeyVerified, true);
    await prefs.setString(_prefKeyPhotoPath, filePath);
    if (cloudUrl != null && cloudUrl.isNotEmpty) {
      await prefs.setString(_prefKeyCloudUrl, cloudUrl);
    }
    if (traits != null) {
      await prefs.setString(_prefKeyAvatarEmoji, traits.matchedEmoji);
      await prefs.setString(_prefKeyTraitsJson, jsonEncode(traits.toJson()));

      // Also persist traits JSON file directly in vault
      final traitsFile = File('${vaultDir.path}/vault_traits_$cleanUsername.json');
      await traitsFile.writeAsString(jsonEncode(traits.toJson()), flush: true);
    }

    debugPrint('[PhotoVaultService] Saved verified portrait to Vault: $filePath');
    return file;
  }

  /// Retrieve local vault photo if it exists
  Future<File?> getLocalVaultPhoto(String username) async {
    final vaultDir = await _getVaultDirectory();
    final cleanUsername = username.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    final filePath = '${vaultDir.path}/vault_selfie_$cleanUsername.jpg';
    final file = File(filePath);
    if (await file.exists()) {
      return file;
    }

    // Fallback: check shared prefs stored path
    final prefs = await SharedPreferences.getInstance();
    final storedPath = prefs.getString(_prefKeyPhotoPath);
    if (storedPath != null) {
      final storedFile = File(storedPath);
      if (await storedFile.exists()) {
        return storedFile;
      }
    }
    return null;
  }

  /// When logging in on another device, download and cache remote photo in the local vault
  Future<File?> cacheRemotePhoto({
    required String remoteUrl,
    required String username,
  }) async {
    try {
      final vaultDir = await _getVaultDirectory();
      final cleanUsername = username.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
      final targetFile = File('${vaultDir.path}/vault_selfie_$cleanUsername.jpg');

      if (remoteUrl.startsWith('data:image')) {
        // Base64 Data URI
        final commaIdx = remoteUrl.indexOf(',');
        final base64Str = commaIdx != -1 ? remoteUrl.substring(commaIdx + 1) : remoteUrl;
        final bytes = base64Decode(base64Str);
        await targetFile.writeAsBytes(bytes, flush: true);
      } else if (remoteUrl.startsWith('http')) {
        // Network URL (e.g. Supabase Storage)
        final response = await http.get(Uri.parse(remoteUrl)).timeout(const Duration(seconds: 15));
        if (response.statusCode == 200) {
          await targetFile.writeAsBytes(response.bodyBytes, flush: true);
        } else {
          return null;
        }
      } else {
        return null;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKeyVerified, true);
      await prefs.setString(_prefKeyPhotoPath, targetFile.path);
      await prefs.setString(_prefKeyCloudUrl, remoteUrl);

      debugPrint('[PhotoVaultService] Successfully cached remote portrait into Vault: ${targetFile.path}');
      return targetFile;
    } catch (e) {
      debugPrint('[PhotoVaultService] Error caching remote photo to vault: $e');
      return null;
    }
  }

  /// Retrieve cached traits from SharedPreferences or vault file
  Future<AvatarFeatureProfile?> getCachedAvatarTraits(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString(_prefKeyTraitsJson);
      if (rawJson != null) {
        final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
        return AvatarFeatureProfile.fromJson(decoded);
      }

      final vaultDir = await _getVaultDirectory();
      final cleanUsername = username.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
      final traitsFile = File('${vaultDir.path}/vault_traits_$cleanUsername.json');
      if (await traitsFile.exists()) {
        final content = await traitsFile.readAsString();
        final decoded = jsonDecode(content) as Map<String, dynamic>;
        return AvatarFeatureProfile.fromJson(decoded);
      }
    } catch (_) {}
    return null;
  }
}
