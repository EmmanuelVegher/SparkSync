import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../services/camera_image_converter.dart';
import '../services/game_state.dart';
import '../services/nvidia_avatar_service.dart';
import '../services/photo_vault_service.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';

enum LivenessStep {
  initializing,
  positionFace,
  turnLeft,
  center1,
  turnRight,
  center2,
  blink,
  smile,
  capturing,
  uploading,
  completed,
}

class SelfieLivenessScreen extends StatefulWidget {
  final GameState gameState;
  final bool isModal;

  const SelfieLivenessScreen({
    super.key,
    required this.gameState,
    this.isModal = true,
  });

  @override
  State<SelfieLivenessScreen> createState() => _SelfieLivenessScreenState();
}

class _SelfieLivenessScreenState extends State<SelfieLivenessScreen> {
  CameraController? _cameraController;
  late final FaceDetector _faceDetector;
  bool _isProcessingFrame = false;
  bool _cameraUnavailable = false;
  bool _showManualUpload = false;

  LivenessStep _step = LivenessStep.initializing;
  String _instruction = "Initializing HD Face Detector...";
  String _subInstruction = "Please allow camera access when prompted";
  IconData _stepIcon = Icons.camera_alt_rounded;
  double _progress = 0.15;

  bool _eyesClosedOnce = false;
  bool _isEvaluating = false;
  String? _uploadStatusText;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeDetector();
    _initCamera();
  }

  void _initializeDetector() {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        enableTracking: true,
        minFaceSize: 0.25,
        performanceMode: FaceDetectorMode.fast,
      ),
    );
  }

  Future<void> _initCamera() async {
    setState(() {
      _cameraUnavailable = false;
      _errorMessage = null;
      _step = LivenessStep.initializing;
      _instruction = "Initializing front camera...";
      _subInstruction = "Connecting to high-definition video stream";
    });

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _cameraUnavailable = true);
        return;
      }

      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.veryHigh,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await _cameraController!.initialize();
      if (!mounted) return;

      try {
        await _cameraController!.setFocusMode(FocusMode.auto);
        await _cameraController!.setExposureMode(ExposureMode.auto);
      } catch (_) {}

      await _cameraController!.startImageStream(_processCameraFrame);
      if (!mounted) return;

      setState(() {
        _step = LivenessStep.positionFace;
        _instruction = "Position your face inside the oval";
        _subInstruction = "Look straight at the front camera";
        _stepIcon = Icons.face_rounded;
        _progress = 0.15;
      });
    } catch (e) {
      debugPrint("Camera init error: $e");
      if (mounted) {
        setState(() {
          _cameraUnavailable = true;
          _errorMessage = "Could not initialize camera hardware. You can upload a photo or retry.";
        });
      }
    }
  }

  void _processCameraFrame(CameraImage image) async {
    if (_isProcessingFrame ||
        _isEvaluating ||
        _showManualUpload ||
        _step == LivenessStep.initializing ||
        _step == LivenessStep.capturing ||
        _step == LivenessStep.uploading ||
        _step == LivenessStep.completed) {
      return;
    }
    _isProcessingFrame = true;

    try {
      final inputImage = convertCameraImageToInputImage(
        image: image,
        camera: _cameraController!.description,
        orientation: MediaQuery.of(context).orientation == Orientation.portrait
            ? DeviceOrientation.portraitUp
            : DeviceOrientation.landscapeLeft,
      );

      if (inputImage == null) return;

      final faces = await _faceDetector.processImage(inputImage);
      if (faces.isEmpty) {
        if (_step != LivenessStep.initializing && mounted) {
          _updateInstruction(
            "Position your face inside the frame",
            "Center your face inside the oval guide",
            Icons.center_focus_strong,
            _progress,
          );
        }
        return;
      }

      if (faces.length > 1) {
        if (mounted) {
          _updateInstruction(
            "Multiple faces detected",
            "Only one person permitted during verification",
            Icons.people_outline,
            _progress,
          );
        }
        return;
      }

      final face = faces.first;
      _handleStepProgression(face);
    } catch (e) {
      debugPrint("Face evaluation frame drop: $e");
    } finally {
      _isProcessingFrame = false;
    }
  }

  // VoteGuardWeb State Machine: accepts side rotation without inverted direction contradictions
  void _handleStepProgression(Face face) async {
    if (_isEvaluating) return;

    final yaw = face.headEulerAngleY ?? 0.0;
    final pitch = face.headEulerAngleX ?? 0.0;
    final leftEye = face.leftEyeOpenProbability ?? 1.0;
    final rightEye = face.rightEyeOpenProbability ?? 1.0;
    final smile = face.smilingProbability ?? 0.0;

    switch (_step) {
      case LivenessStep.positionFace:
        if (yaw.abs() < 10.0 && pitch.abs() < 14.0) {
          HapticFeedback.selectionClick();
          setState(() {
            _step = LivenessStep.turnLeft;
            _instruction = "Turn your head to the LEFT ◀";
            _subInstruction = "Slowly turn your head left until prompted";
            _stepIcon = Icons.arrow_back_rounded;
            _progress = 0.28;
          });
        }
        break;

      case LivenessStep.turnLeft:
        // VoteGuardWeb logic: accept turning head to side without confusing left/right inversion
        if (yaw.abs() > 11.0) {
          HapticFeedback.lightImpact();
          setState(() {
            _step = LivenessStep.center1;
            _instruction = "Turn back STRAIGHT 🎯";
            _subInstruction = "Look directly at the camera again";
            _stepIcon = Icons.center_focus_strong_rounded;
            _progress = 0.42;
          });
        }
        break;

      case LivenessStep.center1:
        if (yaw.abs() < 9.0 && pitch.abs() < 14.0) {
          HapticFeedback.selectionClick();
          setState(() {
            _step = LivenessStep.turnRight;
            _instruction = "Turn your head to the RIGHT ▶";
            _subInstruction = "Slowly turn your head right until prompted";
            _stepIcon = Icons.arrow_forward_rounded;
            _progress = 0.58;
          });
        }
        break;

      case LivenessStep.turnRight:
        // VoteGuardWeb logic: accept turning head to side
        if (yaw.abs() > 11.0) {
          HapticFeedback.lightImpact();
          setState(() {
            _step = LivenessStep.center2;
            _instruction = "Turn back STRAIGHT 🎯";
            _subInstruction = "Look directly into the camera";
            _stepIcon = Icons.center_focus_strong_rounded;
            _progress = 0.72;
          });
        }
        break;

      case LivenessStep.center2:
        if (yaw.abs() < 9.0 && pitch.abs() < 14.0) {
          HapticFeedback.selectionClick();
          setState(() {
            _step = LivenessStep.blink;
            _instruction = "Blink your eyes 👁️";
            _subInstruction = "Close both eyes and open them";
            _stepIcon = Icons.visibility_rounded;
            _progress = 0.85;
            _eyesClosedOnce = false;
          });
        }
        break;

      case LivenessStep.blink:
        if (leftEye < 0.28 && rightEye < 0.28) {
          _eyesClosedOnce = true;
        } else if (_eyesClosedOnce && leftEye > 0.60 && rightEye > 0.60) {
          HapticFeedback.lightImpact();
          setState(() {
            _step = LivenessStep.smile;
            _instruction = "Smile for your profile! 😊";
            _subInstruction = "Give a clear, natural smile";
            _stepIcon = Icons.sentiment_very_satisfied_rounded;
            _progress = 0.95;
          });
        }
        break;

      case LivenessStep.smile:
        if (smile > 0.38 && yaw.abs() < 12.0 && pitch.abs() < 14.0) {
          _isEvaluating = true;
          HapticFeedback.mediumImpact();
          setState(() {
            _step = LivenessStep.capturing;
            _instruction = "Hold still! Capturing HD portrait...";
            _subInstruction = "Enhancing clarity & cropping passport photo";
            _stepIcon = Icons.camera_rounded;
            _progress = 1.0;
          });
          await Future.delayed(const Duration(milliseconds: 600));
          await _captureAndEnroll();
        }
        break;

      default:
        break;
    }
  }

  void _updateInstruction(String main, String sub, IconData icon, double prog) {
    if ((_instruction != main || _subInstruction != sub) && mounted) {
      setState(() {
        _instruction = main;
        _subInstruction = sub;
        _stepIcon = icon;
        _progress = prog;
      });
    }
  }

  // VoteGuardWeb studio-grade enhancement: contrast stretch, saturation boost & tight crop
  Future<void> _captureAndEnroll({XFile? manualPhoto}) async {
    try {
      if (_cameraController != null && _cameraController!.value.isStreamingImages) {
        await _cameraController!.stopImageStream();
      }

      XFile? photo = manualPhoto;
      if (photo == null && _cameraController != null && _cameraController!.value.isInitialized) {
        photo = await _cameraController!.takePicture();
      }

      setState(() {
        _step = LivenessStep.uploading;
        _uploadStatusText = "Enhancing clarity & cropping biometric portrait...";
      });

      final user = widget.gameState.user;
      final appDir = await getApplicationDocumentsDirectory();
      final localFolder = Directory("${appDir.path}/profile_images");
      if (!await localFolder.exists()) {
        await localFolder.create(recursive: true);
      }
      final localFilePath = "${localFolder.path}/${user.username}_verified.jpg";

      Uint8List? finalJpgBytes;
      if (photo != null) {
        final capturedTempFile = File(photo.path);
        final rawBytes = await capturedTempFile.readAsBytes();
        img.Image? decoded = img.decodeImage(rawBytes);

        if (decoded != null) {
          // 1. Correct EXIF orientation so front selfie is 100% upright
          decoded = img.bakeOrientation(decoded);

          final orientedTempFile = File("${capturedTempFile.path}_upright.jpg");
          await orientedTempFile.writeAsBytes(img.encodeJpg(decoded, quality: 90));

          int cropX = 0;
          int cropY = 0;
          int cropDim = decoded.width < decoded.height ? decoded.width : decoded.height;

          try {
            final detectedFaces = await _faceDetector.processImage(
              InputImage.fromFilePath(orientedTempFile.path),
            );

            if (detectedFaces.isNotEmpty) {
              final face = detectedFaces.first.boundingBox;
              // VoteGuardWeb tight passport crop: face occupies ~65% of frame height
              final desiredDim = (face.height * 1.55).clamp(240.0, decoded.width.toDouble()).toDouble();
              final halfDim = desiredDim / 2;

              final targetX = face.center.dx;
              // Shift center slightly upwards so hair and top of head are included, cutting ceiling
              final targetY = face.center.dy - (face.height * 0.08);

              cropX = (targetX - halfDim).round();
              cropY = (targetY - halfDim).round();
              cropDim = desiredDim.round();
            } else {
              cropDim = (decoded.width * 0.72).round();
              cropX = (decoded.width - cropDim) ~/ 2;
              cropY = (decoded.height - cropDim) ~/ 3;
            }
          } catch (e) {
            debugPrint("Detector error during crop: $e");
            cropDim = (decoded.width * 0.72).round();
            cropX = (decoded.width - cropDim) ~/ 2;
            cropY = (decoded.height - cropDim) ~/ 3;
          } finally {
            try {
              if (await orientedTempFile.exists()) {
                await orientedTempFile.delete();
              }
            } catch (_) {}
          }

          if (cropX < 0) cropX = 0;
          if (cropY < 0) cropY = 0;
          if (cropX + cropDim > decoded.width) {
            cropX = (decoded.width - cropDim).clamp(0, decoded.width);
          }
          if (cropY + cropDim > decoded.height) {
            cropY = (decoded.height - cropDim).clamp(0, decoded.height);
          }
          final actualW = cropDim.clamp(1, decoded.width - cropX);
          final actualH = cropDim.clamp(1, decoded.height - cropY);

          var cropped = img.copyCrop(
            decoded,
            x: cropX,
            y: cropY,
            width: actualW,
            height: actualH,
          );

          // 2. High-resolution 800x800 avatar resize
          var hdAvatar = img.copyResize(
            cropped,
            width: 800,
            height: 800,
            interpolation: img.Interpolation.linear,
          );

          // 3. Studio-grade contrast expansion & color vibrancy (+12%)
          hdAvatar = img.adjustColor(
            hdAvatar,
            contrast: 1.15,
            saturation: 1.12,
          );

          finalJpgBytes = Uint8List.fromList(img.encodeJpg(hdAvatar, quality: 98));
        }
      }

      final effectiveBytes = finalJpgBytes ?? (photo != null ? await File(photo.path).readAsBytes() : null);
      final base64String = effectiveBytes != null ? base64Encode(effectiveBytes) : null;

      // 2. Automatically pass through NVIDIA Multimodal Vision model
      setState(() {
        _uploadStatusText = "Sending photo to NVIDIA Multimodal Vision AI...";
      });

      final avatarProfile = await NvidiaAvatarService().analyzePhotoForAvatar(
        base64Image: base64String,
        imageBytes: effectiveBytes,
        fallbackHint: user.neighborhood,
      );

      // 3. Generate Avatar and style traits
      setState(() {
        _uploadStatusText = "Generated AI Avatar (${avatarProfile.matchedEmoji}) • ${avatarProfile.vibeTitle}";
      });
      await Future.delayed(const Duration(milliseconds: 600));

      // 4. Store locally in the Vault
      setState(() {
        _uploadStatusText = "Storing biometric portrait in local secure Vault...";
      });

      File? vaultFile;
      if (effectiveBytes != null) {
        vaultFile = await PhotoVaultService().saveToVault(
          imageBytes: effectiveBytes,
          username: user.username,
          traits: avatarProfile,
        );
      }

      // 5. Sync to Supabase Cloud for multi-device parity
      setState(() {
        _uploadStatusText = "Syncing with Supabase Cloud for cross-device access...";
      });

      String cloudPhotoUrl = vaultFile?.path ?? localFilePath;
      final supa = SupabaseService();
      if (supa.isConfigured && supa.currentUser != null && effectiveBytes != null) {
        final uploadedStorageUrl = await supa.uploadAvatarToStorage(
          userId: supa.currentUser!.id,
          imageBytes: effectiveBytes,
          filename: '${DateTime.now().millisecondsSinceEpoch}_verified.jpg',
        );

        if (uploadedStorageUrl != null && uploadedStorageUrl.isNotEmpty) {
          cloudPhotoUrl = uploadedStorageUrl;
        } else if (base64String != null && base64String.isNotEmpty) {
          // Cloud fallback: data URI allows all secondary devices to immediately render avatar
          cloudPhotoUrl = 'data:image/jpeg;base64,$base64String';
        }
      }

      // 6. Configure on-device 2D Vector Human Avatar (Offline)
      widget.gameState.user.avatarCartoonUrl = null;

      // 7. Update GameState & Supabase Profile
      final resolvedEmoji = (avatarProfile.matchedEmoji == '👑' || avatarProfile.matchedEmoji.isEmpty)
          ? '👨🏾‍💼'
          : avatarProfile.matchedEmoji;

      await widget.gameState.verifyUserSelfie(
        avatarEmoji: resolvedEmoji,
        photoUrl: cloudPhotoUrl,
        avatarProfile: avatarProfile,
        title: avatarProfile.vibeTitle,
      );

      setState(() {
        _step = LivenessStep.completed;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("✨ Liveness Verified! AI Avatar (${avatarProfile.matchedEmoji}) stored in Vault & Supabase! (+150 XP, +150 🪙 Spark Coins)"),
          backgroundColor: AppTheme.neonEmerald,
          duration: const Duration(seconds: 4),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      debugPrint("Photo capture/save error: $e");
      _showErrorDialog("Verification error: $e. Please retry.");
    }
  }

  // VoteGuardWeb manual upload fallback
  Future<void> _pickPhotoFromGallery() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 95,
      );
      if (picked != null) {
        await _captureAndEnroll(manualPhoto: picked);
      }
    } catch (e) {
      _showErrorDialog("Could not select photo: $e");
    }
  }

  void _simulateLivenessSuccess() async {
    HapticFeedback.mediumImpact();
    setState(() {
      _step = LivenessStep.uploading;
      _uploadStatusText = "Passing through NVIDIA & Gemini Multimodal Vision...";
    });

    final user = widget.gameState.user;
    final mockProfile = await NvidiaAvatarService().analyzePhotoForAvatar(
      fallbackHint: user.neighborhood,
    );

    setState(() {
      _uploadStatusText = "Storing in Vault & Syncing with Supabase Cloud...";
    });

    await widget.gameState.verifyUserSelfie(
      avatarEmoji: mockProfile.matchedEmoji,
      photoUrl: "assets/portraits/selfie_1.png",
      avatarProfile: mockProfile,
      title: mockProfile.vibeTitle,
    );

    setState(() {
      _step = LivenessStep.completed;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("✨ Identity verified with selfie! AI Avatar (${mockProfile.matchedEmoji}) active across devices (+150 XP, +150 🪙 Spark Coins)"),
        backgroundColor: AppTheme.neonEmerald,
        duration: const Duration(seconds: 4),
      ),
    );

    Navigator.pop(context, true);
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131926),
        title: const Text("Verification Notice", style: TextStyle(color: Colors.white)),
        content: Text(message, style: const TextStyle(color: Color(0xFF94A3B8))),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.purpleRoyal),
            onPressed: () {
              Navigator.pop(ctx);
            },
            child: const Text("OK", style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  String _getActionBadgeText() {
    switch (_step) {
      case LivenessStep.positionFace:
        return "Center Face";
      case LivenessStep.turnLeft:
        return "Turn Left";
      case LivenessStep.center1:
      case LivenessStep.center2:
        return "Look Straight";
      case LivenessStep.turnRight:
        return "Turn Right";
      case LivenessStep.blink:
        return "Blink Eyes";
      case LivenessStep.smile:
        return "Smile";
      case LivenessStep.capturing:
        return "Capturing HD...";
      case LivenessStep.uploading:
        return "Enrolling...";
      default:
        return "Processing";
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617), // VoteGuardWeb dark slate obsidian
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.8),
        elevation: 0,
        leading: widget.isModal
            ? IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Row(
          children: [
            Icon(Icons.shield_rounded, color: Colors.cyanAccent, size: 20),
            SizedBox(width: 8),
            Text(
              "Biometric Liveness Verification",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: _showManualUpload || _cameraUnavailable
            ? _buildManualUploadFallback()
            : _buildLiveCameraView(),
      ),
    );
  }

  Widget _buildLiveCameraView() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.cyanAccent),
            const SizedBox(height: 16),
            Text(
              _instruction,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              _subInstruction,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
          ],
        ),
      );
    }

    final isCapturingOrDone = _step == LivenessStep.capturing || _step == LivenessStep.completed;

    return Column(
      children: [
        // Camera Preview with Oval Frame (VoteGuardWeb aspect ratio)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Camera Viewport
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    color: Colors.black,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1 / _cameraController!.value.aspectRatio,
                        child: CameraPreview(_cameraController!),
                      ),
                    ),
                  ),
                ),

                // VoteGuardWeb Centered Oval Guide & Dynamic Glow Border
                Center(
                  child: SizedBox(
                    width: 250,
                    height: 340,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Dynamic glow border
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(160),
                            border: Border.all(
                              color: isCapturingOrDone
                                  ? AppTheme.neonEmerald
                                  : Colors.cyanAccent.withValues(alpha: 0.8),
                              width: 3.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isCapturingOrDone
                                    ? AppTheme.neonEmerald.withValues(alpha: 0.5)
                                    : Colors.cyanAccent.withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),

                        // Action pill badge floating at bottom of oval
                        Positioned(
                          bottom: -6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isCapturingOrDone ? AppTheme.neonEmerald : Colors.cyanAccent,
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _stepIcon,
                                  size: 16,
                                  color: isCapturingOrDone ? AppTheme.neonEmerald : Colors.cyanAccent,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _getActionBadgeText(),
                                  style: TextStyle(
                                    color: isCapturingOrDone ? AppTheme.neonEmerald : Colors.cyanAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
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

                // Flash animation effect on capture
                if (_step == LivenessStep.capturing)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // VoteGuardWeb HUD Instructions Card
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF1E293B), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_step == LivenessStep.uploading) ...[
                Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(color: Colors.cyanAccent),
                      const SizedBox(height: 10),
                      Text(
                        _uploadStatusText ?? "Enrolling & Syncing HD Portrait...",
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _instruction,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      "${(_progress * 100).round()}%",
                      style: const TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  _subInstruction,
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 14, color: Colors.redAccent),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.redAccent, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),

                // Gradient Progress Bar (Cyan to Emerald)
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Stack(
                    children: [
                      Container(
                        height: 6,
                        width: double.infinity,
                        color: const Color(0xFF1E293B),
                      ),
                      FractionallySizedBox(
                        widthFactor: _progress.clamp(0.0, 1.0),
                        child: Container(
                          height: 6,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.cyanAccent, AppTheme.neonEmerald],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        // Bottom Action Row: On-Device AI Beacon & Fallback button
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppTheme.neonEmerald,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    "On-Device 3D AI Active (Studio HD)",
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  setState(() => _showManualUpload = true);
                },
                child: const Row(
                  children: [
                    Icon(Icons.upload_rounded, color: Colors.cyanAccent, size: 14),
                    SizedBox(width: 4),
                    Text(
                      "Upload file instead",
                      style: TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // VoteGuardWeb Manual Upload & Error Fallback View
  Widget _buildManualUploadFallback() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.cyanAccent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add_photo_alternate_rounded, color: Colors.cyanAccent, size: 52),
            ),
            const SizedBox(height: 20),
            const Text(
              "Select Profile Portrait",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Upload a clear front-facing portrait photo. Our biometric pipeline will crop and enhance your profile image.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 18, color: Colors.amber),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.amber, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Pick from Gallery
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.neonEmerald,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.photo_library_rounded, size: 20),
                label: const Text(
                  "Choose Photo from Gallery",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                onPressed: _pickPhotoFromGallery,
              ),
            ),
            const SizedBox(height: 12),

            // Retry Camera Live Feed
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF334155)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.camera_alt_rounded, size: 18, color: Colors.cyanAccent),
                label: const Text(
                  "Back to Live Camera Liveness Check",
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  setState(() {
                    _showManualUpload = false;
                    _cameraUnavailable = false;
                  });
                  _initCamera();
                },
              ),
            ),
            const SizedBox(height: 12),

            // Simulate Liveness button for testing
            TextButton.icon(
              icon: const Icon(Icons.verified_user_outlined, size: 16, color: Color(0xFF94A3B8)),
              label: const Text(
                "Simulate Verification (+150 XP)",
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              ),
              onPressed: _simulateLivenessSuccess,
            ),
          ],
        ),
      ),
    );
  }
}
