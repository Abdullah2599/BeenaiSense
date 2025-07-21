import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'tts_helper.dart';

class LanguageHelper {
  // Singleton instance
  static final LanguageHelper _instance = LanguageHelper._internal();
  factory LanguageHelper() => _instance;
  LanguageHelper._internal();

  // Key for storing language preference
  static const String _langPrefKey = 'selectedLanguage';

  // Available languages
  static const Map<String, Locale> availableLanguages = {
    'en-US': Locale('en', 'US'),
    'ur-PK': Locale('ur', 'PK'),
  };

  // Get the current language code
  Future<String> getCurrentLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_langPrefKey) ?? 'en-US';
  }

  // Get the current locale
  Future<Locale> getCurrentLocale() async {
    final code = await getCurrentLanguageCode();
    return availableLanguages[code] ?? const Locale('en', 'US');
  }

  // Change the app language
  Future<void> changeLanguage(String languageCode) async {
    if (!availableLanguages.containsKey(languageCode)) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langPrefKey, languageCode);
    
    // Update app locale
    final locale = availableLanguages[languageCode]!;
    Get.updateLocale(locale);
    
    // Update TTS language
    await TTSHelper.setLanguage(languageCode);
  }

  // Check if a language is set
  Future<bool> isLanguageSet() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_langPrefKey);
  }

  // Get language name from code
  String getLanguageName(String code) {
    switch (code) {
      case 'en-US':
        return 'English';
      case 'ur-PK':
        return 'اردو';
      default:
        return 'Unknown';
    }
  }

  // Get display name based on current language
  Future<String> getDisplayText(String englishText, String urduText) async {
    final code = await getCurrentLanguageCode();
    return code == 'ur-PK' ? urduText : englishText;
  }
} 