import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TTSHelper {
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _isInitialized = false;
  
  // Initialize TTS with default settings
  static Future<void> initTTS() async {
    if (!_isInitialized) {
      final prefs = await SharedPreferences.getInstance();
      final String? language = prefs.getString('selectedLanguage');
      
      await _flutterTts.setLanguage(language ?? 'en-US');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      
      _isInitialized = true;
    }
  }
  
  // Speak text in the selected language
  static Future<void> speak(String text) async {
    await initTTS();
    await _flutterTts.stop();
    await _flutterTts.speak(text);
  }
  
  // Speak translated text based on the key
  static Future<void> speakTranslated(String key) async {
    await initTTS();
    final String text = key.tr; // Use GetX translation
    await _flutterTts.stop();
    await _flutterTts.speak(text);
  }
  
  // Stop TTS
  static Future<void> stop() async {
    await _flutterTts.stop();
  }
  
  // Change TTS language
  static Future<void> setLanguage(String languageCode) async {
    await initTTS();
    await _flutterTts.setLanguage(languageCode);
  }
  
  // Get current language
  static Future<String> getCurrentLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? language = prefs.getString('selectedLanguage');
    return language ?? 'en-US';
  }
  
  // Check if the language is supported
  static Future<bool> isLanguageSupported(String languageCode) async {
    final List<dynamic>? languages = await _flutterTts.getLanguages;
    return languages?.contains(languageCode) ?? false;
  }
  
  // Clean up resources
  static Future<void> dispose() async {
    await _flutterTts.stop();
  }
} 