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
      await setTtsVoice(language ?? 'en-US');

      // await _flutterTts.setVoice(language == 'en-US' ? const Voice(
      //   name: 'en-US-Wavenet-1',
      //   locale: 'en-US',
      //   languageCode: 'en-US',
      //   engine: 'wave_net',
      // ) : const Voice(
      //   name: 'ur-PK-Wavenet-1',
      // ));
      
      _isInitialized = true;
    }
  }


static Future<void> setTtsVoice(String languageCode) async {
  final voices = await _flutterTts.getVoices;
  Map<String, String>? selectedVoice;

  final fallbackVoice = {
    'name': 'en-us-x-iom-local',
    'locale': 'en-US',
  };

  // Define preferences
  final voicePreferences = {
    'en-US': 'en-us-x-iom-local',
    'ur-PK': 'ur-pk-x-cfn-local',
    'ur-IN': 'ur-in-x-urb-local', // optional fallback
  };

  // Try to find matching voice
  final voiceName = voicePreferences[languageCode];

  if (voiceName != null) {
    final match = voices.firstWhere(
      (v) => v['name'] == voiceName,
      orElse: () => null,
    );
    if (match != null) {
      selectedVoice = {
        'name': match['name'],
        'locale': match['locale'],
      };
    }
  }

  // Fallback if none found
  await _flutterTts.setVoice(selectedVoice ?? fallbackVoice);
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