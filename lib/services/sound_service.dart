import 'dart:async';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  AudioPlayer? _samplePlayer;
  AudioPlayer? _loopPlayer;
  AudioPlayer? _karaokePlayer;
  bool _isLoopPlaying = false;
  bool get isLoopPlaying => _isLoopPlaying;
  bool _isKaraokePlaying = false;
  bool get isKaraokePlaying => _isKaraokePlaying;
  bool _isKaraokeMuted = false;
  bool get isKaraokeMuted => _isKaraokeMuted;
  String? _currentKaraokeUrl;
  String? get currentKaraokeUrl => _currentKaraokeUrl;

  // Cached Synthesized WAV Audio Buffers
  Uint8List? _kickWav;
  Uint8List? _congaWav;
  Uint8List? _bellWav;
  Uint8List? _airhornWav;
  Uint8List? _saxWav;
  Uint8List? _sheeshWav;
  Uint8List? _scratchWav;
  Uint8List? _cheerWav;
  Uint8List? _whistleWav;
  Uint8List? _vuvuzelaWav;
  Uint8List? _afrobeatLoopWav;

  /// Play a loud alert vibration and system alert sound
  Future<void> playDanfoHorn() async {
    try {
      await HapticFeedback.heavyImpact();
      await SystemSound.play(SystemSoundType.alert);
    } catch (_) {}
  }

  /// Power outage feedback
  Future<void> playNepaOff() async {
    try {
      await HapticFeedback.vibrate();
      await SystemSound.play(SystemSoundType.alert);
    } catch (_) {}
  }

  /// Power restored feedback
  Future<void> playNepaOn() async {
    try {
      await HapticFeedback.mediumImpact();
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  /// Button tap feedback
  Future<void> playButtonTap() async {
    try {
      await HapticFeedback.selectionClick();
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  /// Spraying Naira / gifting feedback
  Future<void> playMoneySpray() async {
    try {
      await HapticFeedback.mediumImpact();
      _sheeshWav ??= _generateSheeshWav();
      await _playBytes(_sheeshWav!);
    } catch (_) {
      try {
        await SystemSound.play(SystemSoundType.click);
      } catch (_) {}
    }
  }

  /// Coin or reward earned
  Future<void> playCoinEarned() async {
    try {
      await HapticFeedback.lightImpact();
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  /// Match celebrate chime and heavy haptic pulse
  Future<void> playSparkMatch() async {
    try {
      await HapticFeedback.heavyImpact();
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  /// Chat message sent feedback
  Future<void> playMessageSent() async {
    try {
      await HapticFeedback.lightImpact();
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  // ==========================================
  // AFROBEAT VIBE ROOM AUDIO SYNTHESIS ENGINE
  // ==========================================

  /// Play an interactive Afrobeat Soundboard sample with responsive haptics
  Future<void> playAfrobeatSample(String sampleId) async {
    try {
      switch (sampleId.toLowerCase()) {
        case 'kick':
          await HapticFeedback.heavyImpact();
          _kickWav ??= _generateKickWav();
          await _playBytes(_kickWav!);
          break;
        case 'conga':
          await HapticFeedback.mediumImpact();
          _congaWav ??= _generateCongaWav();
          await _playBytes(_congaWav!);
          break;
        case 'bell':
          await HapticFeedback.lightImpact();
          _bellWav ??= _generateBellWav();
          await _playBytes(_bellWav!);
          break;
        case 'airhorn':
          await HapticFeedback.heavyImpact();
          _airhornWav ??= _generateAirhornWav();
          await _playBytes(_airhornWav!);
          break;
        case 'sax':
          await HapticFeedback.mediumImpact();
          _saxWav ??= _generateSaxWav();
          await _playBytes(_saxWav!);
          break;
        case 'sheesh':
          await HapticFeedback.selectionClick();
          _sheeshWav ??= _generateSheeshWav();
          await _playBytes(_sheeshWav!);
          break;
        case 'scratch':
          await HapticFeedback.heavyImpact();
          _scratchWav ??= _generateRecordScratchWav();
          await _playBytes(_scratchWav!);
          break;
        case 'cheer':
          await HapticFeedback.mediumImpact();
          _cheerWav ??= _generateCheerWav();
          await _playBytes(_cheerWav!);
          break;
        default:
          await HapticFeedback.lightImpact();
          await SystemSound.play(SystemSoundType.click);
          break;
      }
    } catch (_) {
      try {
        await SystemSound.play(SystemSoundType.click);
      } catch (_) {}
    }
  }

  // ==========================================
  // NAIJA BANTER ROOM AUDIO SYNTHESIS ENGINE
  // ==========================================

  /// Play an interactive Banter Soundboard sample (Whistle, Vuvuzela, Goal, Airhorn, Sheesh/E Choke, Wotowoto)
  Future<void> playBanterSound(String sampleId) async {
    try {
      switch (sampleId.toLowerCase()) {
        case 'whistle':
        case 'var':
          await HapticFeedback.mediumImpact();
          _whistleWav ??= _generateWhistleWav();
          await _playBytes(_whistleWav!);
          break;
        case 'vuvuzela':
          await HapticFeedback.heavyImpact();
          _vuvuzelaWav ??= _generateVuvuzelaWav();
          await _playBytes(_vuvuzelaWav!);
          break;
        case 'goal':
          await HapticFeedback.heavyImpact();
          _cheerWav ??= _generateCheerWav();
          await _playBytes(_cheerWav!);
          break;
        case 'airhorn':
          await HapticFeedback.heavyImpact();
          _airhornWav ??= _generateAirhornWav();
          await _playBytes(_airhornWav!);
          break;
        case 'sheesh':
        case 'echoke':
          await HapticFeedback.selectionClick();
          _sheeshWav ??= _generateSheeshWav();
          await _playBytes(_sheeshWav!);
          break;
        case 'scratch':
        case 'wotowoto':
          await HapticFeedback.heavyImpact();
          _scratchWav ??= _generateRecordScratchWav();
          await _playBytes(_scratchWav!);
          break;
        default:
          await HapticFeedback.lightImpact();
          await SystemSound.play(SystemSoundType.click);
          break;
      }
    } catch (_) {
      try {
        await SystemSound.play(SystemSoundType.click);
      } catch (_) {}
    }
  }

  /// Starts ambient Afrobeat rhythm backing loop
  Future<void> startAfrobeatLoop() async {
    try {
      _afrobeatLoopWav ??= _generateAfrobeatLoopWav();
      _loopPlayer ??= AudioPlayer();
      await _loopPlayer!.setReleaseMode(ReleaseMode.loop);
      await _loopPlayer!.play(BytesSource(_afrobeatLoopWav!));
      _isLoopPlaying = true;
    } catch (_) {
      _isLoopPlaying = false;
    }
  }

  /// Stops ambient Afrobeat rhythm backing loop
  Future<void> stopAfrobeatLoop() async {
    try {
      await _loopPlayer?.stop();
    } catch (_) {}
    _isLoopPlaying = false;
  }

  /// Toggle ambient loop
  Future<bool> toggleAfrobeatLoop() async {
    if (_isLoopPlaying) {
      await stopAfrobeatLoop();
      return false;
    } else {
      await startAfrobeatLoop();
      return _isLoopPlaying;
    }
  }

  StreamSubscription? _karaokeCompleteSub;

  /// Streams real audio for the active Karaoke song performance.
  /// When a preview snippet finishes, transitions smoothly to the rhythm backing track
  /// so the audio plays continuously throughout the full length of the song performance
  /// without abruptly restarting the vocal clip at 50 seconds!
  Future<void> playKaraokeAudio(String? previewUrl) async {
    _currentKaraokeUrl = previewUrl;
    try {
      _karaokeCompleteSub?.cancel();
      _karaokeCompleteSub = null;
      _karaokePlayer ??= AudioPlayer();
      await _karaokePlayer!.stop();
      _isKaraokePlaying = false;

      if (previewUrl != null && previewUrl.trim().isNotEmpty) {
        if (_isLoopPlaying) {
          await stopAfrobeatLoop();
        }
        await _karaokePlayer!.setReleaseMode(ReleaseMode.stop);
        await _karaokePlayer!.setVolume(_isKaraokeMuted ? 0.0 : 1.0);
        await _karaokePlayer!.play(UrlSource(previewUrl.trim()));
        _isKaraokePlaying = true;

        // When the audio preview ends (typically 30-50s on iTunes), seamlessly
        // transition to the backing rhythm groove so music continues for the full 5+ minutes
        // without looping the vocals back to the beginning!
        _karaokeCompleteSub = _karaokePlayer!.onPlayerComplete.listen((_) async {
          debugPrint('[SoundService] Audio preview completed; maintaining backing rhythm for full song');
          await startAfrobeatLoop();
        });
      } else {
        await startAfrobeatLoop();
        _isKaraokePlaying = true;
      }
    } catch (e) {
      try {
        await startAfrobeatLoop();
        _isKaraokePlaying = true;
      } catch (_) {}
    }
  }

  /// Stops any currently playing karaoke stream and backing loop
  Future<void> stopKaraokeAudio() async {
    _karaokeCompleteSub?.cancel();
    _karaokeCompleteSub = null;
    try {
      await _karaokePlayer?.stop();
    } catch (_) {}
    try {
      await stopAfrobeatLoop();
    } catch (_) {}
    _isKaraokePlaying = false;
    _currentKaraokeUrl = null;
  }

  /// Toggle mute for karaoke playback
  Future<void> toggleKaraokeMute() async {
    _isKaraokeMuted = !_isKaraokeMuted;
    try {
      if (_karaokePlayer != null) {
        await _karaokePlayer!.setVolume(_isKaraokeMuted ? 0.0 : 1.0);
      }
      if (_loopPlayer != null) {
        await _loopPlayer!.setVolume(_isKaraokeMuted ? 0.0 : 1.0);
      }
    } catch (_) {}
  }

  /// Replay the active track audio from the very start (0:00)
  Future<void> replayKaraokeAudio() async {
    try {
      _karaokeCompleteSub?.cancel();
      _karaokeCompleteSub = null;
      await stopAfrobeatLoop();
      if (_karaokePlayer != null && _currentKaraokeUrl != null && _currentKaraokeUrl!.isNotEmpty) {
        await _karaokePlayer!.seek(Duration.zero);
        await _karaokePlayer!.resume();
        _isKaraokePlaying = true;
        _karaokeCompleteSub = _karaokePlayer!.onPlayerComplete.listen((_) async {
          await startAfrobeatLoop();
        });
      } else if (_currentKaraokeUrl != null && _currentKaraokeUrl!.isNotEmpty) {
        await playKaraokeAudio(_currentKaraokeUrl);
      } else {
        await startAfrobeatLoop();
      }
    } catch (_) {
      if (_currentKaraokeUrl != null && _currentKaraokeUrl!.isNotEmpty) {
        await playKaraokeAudio(_currentKaraokeUrl);
      } else {
        await startAfrobeatLoop();
      }
    }
  }

  Future<void> _playBytes(Uint8List bytes) async {
    try {
      _samplePlayer ??= AudioPlayer();
      await _samplePlayer!.stop();
      await _samplePlayer!.play(BytesSource(bytes));
    } catch (_) {
      // Graceful fallback on headless or unsupported environments
    }
  }

  // --- WAV Synthesizer Math Helpers ---

  static Uint8List _createWav(List<double> samples, {int sampleRate = 22050}) {
    final numSamples = samples.length;
    final byteRate = sampleRate * 2;
    final dataSize = numSamples * 2;
    final chunkSize = 36 + dataSize;
    final buffer = ByteData(44 + dataSize);

    // RIFF Header
    buffer.setUint8(0, 0x52); // 'R'
    buffer.setUint8(1, 0x49); // 'I'
    buffer.setUint8(2, 0x46); // 'F'
    buffer.setUint8(3, 0x46); // 'F'
    buffer.setUint32(4, chunkSize, Endian.little);
    buffer.setUint8(8, 0x57); // 'W'
    buffer.setUint8(9, 0x41); // 'A'
    buffer.setUint8(10, 0x56); // 'V'
    buffer.setUint8(11, 0x45); // 'E'

    // fmt Chunk
    buffer.setUint8(12, 0x66); // 'f'
    buffer.setUint8(13, 0x6D); // 'm'
    buffer.setUint8(14, 0x74); // 't'
    buffer.setUint8(15, 0x20); // ' '
    buffer.setUint32(16, 16, Endian.little);
    buffer.setUint16(20, 1, Endian.little); // PCM = 1
    buffer.setUint16(22, 1, Endian.little); // Mono = 1
    buffer.setUint32(24, sampleRate, Endian.little);
    buffer.setUint32(28, byteRate, Endian.little);
    buffer.setUint16(32, 2, Endian.little); // Block align
    buffer.setUint16(34, 16, Endian.little); // 16 bits per sample

    // data Chunk
    buffer.setUint8(36, 0x64); // 'd'
    buffer.setUint8(37, 0x61); // 'a'
    buffer.setUint8(38, 0x74); // 't'
    buffer.setUint8(39, 0x61); // 'a'
    buffer.setUint32(40, dataSize, Endian.little);

    var offset = 44;
    for (var i = 0; i < numSamples; i++) {
      final s = samples[i].clamp(-1.0, 1.0);
      buffer.setInt16(offset, (s * 32767).toInt(), Endian.little);
      offset += 2;
    }
    return buffer.buffer.asUint8List();
  }

  static Uint8List _generateKickWav() {
    const sr = 22050;
    const dur = 0.35;
    final count = (sr * dur).toInt();
    final list = <double>[];
    var phase = 0.0;
    for (var i = 0; i < count; i++) {
      final t = i / sr;
      final freq = 45.0 + 115.0 * math.exp(-t * 22);
      phase += 2 * math.pi * freq / sr;
      final env = math.exp(-t * 9.0);
      final s = math.sin(phase) + 0.25 * math.sin(phase * 2) * math.exp(-t * 30);
      list.add((s * env).clamp(-1.0, 1.0));
    }
    return _createWav(list, sampleRate: sr);
  }

  static Uint8List _generateCongaWav() {
    const sr = 22050;
    const dur = 0.28;
    final count = (sr * dur).toInt();
    final list = <double>[];
    var p1 = 0.0;
    var p2 = 0.0;
    for (var i = 0; i < count; i++) {
      final t = i / sr;
      final f1 = 220.0 + 30.0 * math.exp(-t * 30);
      final f2 = f1 * 1.85;
      p1 += 2 * math.pi * f1 / sr;
      p2 += 2 * math.pi * f2 / sr;
      final env = math.exp(-t * 14.0);
      final s = 0.8 * math.sin(p1) + 0.3 * math.sin(p2);
      list.add((s * env).clamp(-1.0, 1.0));
    }
    return _createWav(list, sampleRate: sr);
  }

  static Uint8List _generateBellWav() {
    const sr = 22050;
    const dur = 0.32;
    final count = (sr * dur).toInt();
    final list = <double>[];
    var p1 = 0.0;
    var p2 = 0.0;
    for (var i = 0; i < count; i++) {
      final t = i / sr;
      p1 += 2 * math.pi * 1100.0 / sr;
      p2 += 2 * math.pi * 1650.0 / sr;
      final env = math.exp(-t * 11.0);
      final s = 0.6 * math.sin(p1) + 0.4 * math.sin(p2);
      list.add((s * env).clamp(-1.0, 1.0));
    }
    return _createWav(list, sampleRate: sr);
  }

  static Uint8List _generateAirhornWav() {
    const sr = 22050;
    const dur = 0.70;
    final count = (sr * dur).toInt();
    final list = <double>[];
    var p1 = 0.0, p2 = 0.0, p3 = 0.0;
    const f1 = 466.16; // Bb4
    const f2 = 587.33; // D5
    const f3 = 698.46; // F5
    for (var i = 0; i < count; i++) {
      final t = i / sr;
      double gate = 0.0;
      if (t < 0.10) {
        gate = 1.0 - (t / 0.10) * 0.2;
      } else if (t >= 0.13 && t < 0.23) {
        gate = 1.0 - ((t - 0.13) / 0.10) * 0.2;
      } else if (t >= 0.26 && t < 0.68) {
        gate = 1.0 - ((t - 0.26) / 0.42);
      }
      p1 += 2 * math.pi * f1 / sr;
      p2 += 2 * math.pi * f2 / sr;
      p3 += 2 * math.pi * f3 / sr;
      final s = (math.sin(p1) > 0 ? 0.35 : -0.35) +
          (math.sin(p2) > 0 ? 0.35 : -0.35) +
          (math.sin(p3) > 0 ? 0.25 : -0.25);
      list.add((s * gate).clamp(-1.0, 1.0));
    }
    return _createWav(list, sampleRate: sr);
  }

  static Uint8List _generateSaxWav() {
    const sr = 22050;
    const dur = 0.50;
    final count = (sr * dur).toInt();
    final list = <double>[];
    var phase = 0.0;
    const baseFreq = 370.0; // F#4
    for (var i = 0; i < count; i++) {
      final t = i / sr;
      final vibrato = 1.0 + 0.03 * math.sin(2 * math.pi * 5.5 * t);
      phase += 2 * math.pi * baseFreq * vibrato / sr;
      final env = t < 0.04 ? (t / 0.04) : math.exp(-(t - 0.04) * 3.5);
      final s = 0.5 * math.sin(phase) +
          0.3 * math.sin(phase * 2) +
          0.15 * math.sin(phase * 3) +
          0.08 * math.sin(phase * 4);
      list.add((s * env).clamp(-1.0, 1.0));
    }
    return _createWav(list, sampleRate: sr);
  }

  static Uint8List _generateSheeshWav() {
    const sr = 22050;
    const dur = 0.42;
    final count = (sr * dur).toInt();
    final list = <double>[];
    var phase = 0.0;
    for (var i = 0; i < count; i++) {
      final t = i / sr;
      final freq = 280.0 + 500.0 * (t / dur) + 15.0 * math.sin(2 * math.pi * 18 * t);
      phase += 2 * math.pi * freq / sr;
      final env = t < 0.05 ? (t / 0.05) : math.exp(-(t - 0.05) * 4.0);
      final s = 0.6 * math.sin(phase) + 0.3 * math.sin(phase * 2);
      list.add((s * env).clamp(-1.0, 1.0));
    }
    return _createWav(list, sampleRate: sr);
  }

  static Uint8List _generateRecordScratchWav() {
    const sr = 22050;
    const dur = 0.38;
    final count = (sr * dur).toInt();
    final list = <double>[];
    var phase = 0.0;
    final rng = math.Random(42);
    for (var i = 0; i < count; i++) {
      final t = i / sr;
      final freq = 1200.0 * math.exp(-t * 12.0) + 150.0;
      phase += 2 * math.pi * freq / sr;
      final noise = (rng.nextDouble() * 2 - 1) * 0.35;
      final env = math.exp(-t * 6.0);
      final s = (math.sin(phase) * 0.65 + noise) * env;
      list.add(s.clamp(-1.0, 1.0));
    }
    return _createWav(list, sampleRate: sr);
  }

  static Uint8List _generateCheerWav() {
    const sr = 22050;
    const dur = 0.65;
    final count = (sr * dur).toInt();
    final list = <double>[];
    var p1 = 0.0, p2 = 0.0, p3 = 0.0, p4 = 0.0;
    for (var i = 0; i < count; i++) {
      final t = i / sr;
      p1 += 2 * math.pi * 523.25 / sr; // C5
      p2 += 2 * math.pi * 659.25 / sr; // E5
      p3 += 2 * math.pi * 783.99 / sr; // G5
      p4 += 2 * math.pi * 1046.50 / sr; // C6
      final env = t < 0.05 ? (t / 0.05) : math.exp(-(t - 0.05) * 3.0);
      final s = 0.3 * math.sin(p1) + 0.25 * math.sin(p2) + 0.25 * math.sin(p3) + 0.2 * math.sin(p4);
      list.add((s * env).clamp(-1.0, 1.0));
    }
    return _createWav(list, sampleRate: sr);
  }

  /// 1-bar rhythmic Afrobeat backing loop (Kick, Shaker, Conga syncopation at ~110 BPM)
  static Uint8List _generateAfrobeatLoopWav() {
    const sr = 22050;
    const bpm = 110.0;
    const beatDur = 60.0 / bpm; // ~0.545s per beat
    const loopDur = beatDur * 4; // 1 full bar (approx 2.18s)
    final count = (sr * loopDur).toInt();
    final list = List<double>.filled(count, 0.0);

    void addHit(double startTime, double duration, double Function(double t) hitFn) {
      final startIdx = (startTime * sr).toInt();
      final hitCount = (duration * sr).toInt();
      for (var j = 0; j < hitCount; j++) {
        final idx = startIdx + j;
        if (idx < count) {
          final t = j / sr;
          list[idx] = (list[idx] + hitFn(t)).clamp(-1.0, 1.0);
        }
      }
    }

    // 4 on the floor soft amapiano/afrobeat log kicks + upbeat syncopations
    for (var b = 0; b < 4; b++) {
      final hitTime = b * beatDur;
      addHit(hitTime, 0.3, (t) {
        final freq = 55.0 + 80.0 * math.exp(-t * 24);
        return 0.45 * math.sin(2 * math.pi * freq * t) * math.exp(-t * 8.0);
      });
      // 16th note shakers
      for (var s = 0; s < 4; s++) {
        final sTime = hitTime + s * (beatDur / 4);
        addHit(sTime, 0.06, (t) {
          final rng = math.Random((sTime * 1000).toInt());
          return (rng.nextDouble() * 2 - 1) * 0.12 * math.exp(-t * 40);
        });
      }
    }

    // Polyrhythmic syncopated conga hits on 2.5 and 4.75
    addHit(beatDur * 1.5, 0.2, (t) => 0.35 * math.sin(2 * math.pi * 230 * t) * math.exp(-t * 14));
    addHit(beatDur * 2.75, 0.2, (t) => 0.35 * math.sin(2 * math.pi * 280 * t) * math.exp(-t * 14));
    addHit(beatDur * 3.5, 0.2, (t) => 0.35 * math.sin(2 * math.pi * 210 * t) * math.exp(-t * 14));

    return _createWav(list, sampleRate: sr);
  }

  /// Piercing referee pea whistle (2850Hz & 3150Hz beating tones with frequency flutter)
  static Uint8List _generateWhistleWav() {
    const sr = 22050;
    const dur = 0.50;
    final count = (sr * dur).toInt();
    final list = <double>[];
    var p1 = 0.0, p2 = 0.0;
    for (var i = 0; i < count; i++) {
      final t = i / sr;
      final flutter = 1.0 + 0.08 * math.sin(2 * math.pi * 26.0 * t);
      p1 += 2 * math.pi * (2850.0 * flutter) / sr;
      p2 += 2 * math.pi * (3150.0 * flutter) / sr;
      final env = t < 0.04 ? (t / 0.04) : (t > dur - 0.08 ? (dur - t) / 0.08 : 1.0);
      final s = (0.5 * math.sin(p1) + 0.45 * math.sin(p2)) * env;
      list.add(s.clamp(-1.0, 1.0));
    }
    return _createWav(list, sampleRate: sr);
  }

  /// Classic stadium vuvuzela buzzing B-flat (~233Hz) horn with brassy upper harmonics
  static Uint8List _generateVuvuzelaWav() {
    const sr = 22050;
    const dur = 0.65;
    final count = (sr * dur).toInt();
    final list = <double>[];
    var p1 = 0.0, p2 = 0.0, p3 = 0.0, p4 = 0.0;
    final rng = math.Random(10);
    for (var i = 0; i < count; i++) {
      final t = i / sr;
      final jitter = (rng.nextDouble() - 0.5) * 4.0;
      final f = 233.0 + jitter;
      p1 += 2 * math.pi * f / sr;
      p2 += 2 * math.pi * (f * 2) / sr;
      p3 += 2 * math.pi * (f * 3) / sr;
      p4 += 2 * math.pi * (f * 4) / sr;
      final env = t < 0.08 ? (t / 0.08) : (t > dur - 0.12 ? (dur - t) / 0.12 : 1.0);
      final s = (0.45 * math.sin(p1) + 0.3 * math.sin(p2) + 0.2 * math.sin(p3) + 0.12 * math.sin(p4)) * env;
      list.add(s.clamp(-1.0, 1.0));
    }
    return _createWav(list, sampleRate: sr);
  }
}
