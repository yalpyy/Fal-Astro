import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

/// Text-to-Speech service for horoscope readings
class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  FlutterTts? _flutterTts;
  bool _isInitialized = false;
  bool _isSpeaking = false;
  double _speechDuration = 0;

  bool get isSpeaking => _isSpeaking;
  double get estimatedDuration => _speechDuration;

  /// Initialize TTS engine
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      _flutterTts = FlutterTts();

      // Configure for Turkish
      await _flutterTts!.setLanguage('tr-TR');
      await _flutterTts!.setSpeechRate(0.5); // Slower for better comprehension
      await _flutterTts!.setVolume(1.0);
      await _flutterTts!.setPitch(1.0);

      // Set handlers
      _flutterTts!.setStartHandler(() {
        _isSpeaking = true;
      });

      _flutterTts!.setCompletionHandler(() {
        _isSpeaking = false;
      });

      _flutterTts!.setCancelHandler(() {
        _isSpeaking = false;
      });

      _flutterTts!.setErrorHandler((msg) {
        _isSpeaking = false;
        debugPrint('TTS Error: $msg');
      });

      _isInitialized = true;
    } catch (e) {
      debugPrint('TTS initialization error: $e');
    }
  }

  /// Estimate speech duration in seconds
  int estimateDuration(String text) {
    // Average Turkish speech rate is about 150 words per minute
    // At 0.5 speech rate, it's about 75 words per minute
    final wordCount = text.split(' ').length;
    final seconds = (wordCount / 75 * 60).round();
    return seconds > 0 ? seconds : 1;
  }

  /// Speak the given text
  Future<void> speak(String text) async {
    if (!_isInitialized) await init();
    if (_flutterTts == null) return;

    // Stop any ongoing speech
    await stop();

    _speechDuration = estimateDuration(text).toDouble();

    try {
      await _flutterTts!.speak(text);
    } catch (e) {
      debugPrint('TTS speak error: $e');
    }
  }

  /// Stop speaking
  Future<void> stop() async {
    if (_flutterTts == null) return;

    try {
      await _flutterTts!.stop();
      _isSpeaking = false;
    } catch (e) {
      debugPrint('TTS stop error: $e');
    }
  }

  /// Pause speaking
  Future<void> pause() async {
    if (_flutterTts == null) return;

    try {
      await _flutterTts!.pause();
    } catch (e) {
      debugPrint('TTS pause error: $e');
    }
  }

  /// Dispose TTS engine
  Future<void> dispose() async {
    await stop();
    _flutterTts = null;
    _isInitialized = false;
  }
}
