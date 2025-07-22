import 'package:beenai_sense/Utility/theme_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageselectionController extends GetxController {
  final FlutterTts flutterTts = FlutterTts();
  final RxBool isSpeaking = false.obs;
  final RxString selectedLanguage = ''.obs;
  final themeController = Get.find<ThemeController>();

  @override
  void onInit() async {
    super.onInit();
    // Set up basic initialization synchronously
    await speakLanguageInstructions();
  }



  @override
  void onClose() {
    flutterTts.stop();
    super.onClose();
  }


  Future<void> speakLanguageInstructions() async {
    if (isSpeaking.value) {
      await flutterTts.stop();
      // Give a short pause after stopping
      await Future.delayed(const Duration(milliseconds: 300));
    }

    try {
      isSpeaking.value = true;

      // Speak both instructions with minimal delay
      await flutterTts.setLanguage('ur-PK');
      await flutterTts.speak(
        'To select English, tap the top of the screen.\n'
        'اردو کا انتخاب کرنے کے لیے، اسکرین کے نیچے والے حصے پر tap کریں۔\n\n'
        'To repeat instructions, tap the middle area.\n'
        'ہدایات دوبارہ سننے کے لیے، درمیانی حصے پر tap کریں۔',
      );
    } catch (e) {
      print("Error speaking instructions: $e");
      isSpeaking.value = false;
    }
  }

  Future<void> selectEnglish() async {
    if (isSpeaking.value) {
      await flutterTts.stop();
      // Short delay to ensure TTS has stopped
      await Future.delayed(const Duration(milliseconds: 300));
    }

    try {
      isSpeaking.value = true;
      selectedLanguage.value = 'en-US';
      // Update app locale to English
      Get.updateLocale(const Locale('en', 'US'));
      // Save preference first so it's ready for the next screen
      await saveLanguagePreference('en-US');
      // // Speak selection confirmation
      await flutterTts.setLanguage('en-US');
      themeController.updateThemeBasedOnLanguage('en-US');
      await flutterTts.speak(
        'You have selected English. All permissions are granted. Starting the app now.',
      );
      // Wait for TTS to finish before navigating
      await Future.delayed(const Duration(seconds: 5));

      // Navigate to main screen
      Get.offAllNamed('/bottomnav');
    } catch (e) {
      print("Error in English selection: $e");
      // Navigate anyway even if there's an error
      Get.offAllNamed('/bottomnav');
    }
  }

  Future<void> selectUrdu() async {
    if (isSpeaking.value) {
      await flutterTts.stop();
      // Short delay to ensure TTS has stopped
      await Future.delayed(const Duration(milliseconds: 300));
    }

    try {
      isSpeaking.value = true;
      selectedLanguage.value = 'ur-PK';

      // Update app locale to Urdu
      Get.updateLocale(const Locale('ur', 'PK'));
      themeController.updateThemeBasedOnLanguage('ur-PK');
      await saveLanguagePreference('ur-PK');
      await flutterTts.setLanguage('ur-PK');
      await flutterTts.speak(
        'آپ نے اردو کا انتخاب کیا ہے۔ تمام اجازتیں مل گئی ہیں۔ ایپ اب شروع ہو رہی ہے۔',
      );

      // Wait for TTS to finish before navigating
      await Future.delayed(const Duration(seconds: 5));

      // Navigate to main screen
      Get.offAllNamed('/bottomnav');
    } catch (e) {
      print("Error in Urdu selection: $e");
      // Navigate anyway even if there's an error
      Get.offAllNamed('/bottomnav');
    }
  }

  Future<void> saveLanguagePreference(String language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selectedLanguage', language);
    } catch (e) {
      print("Error saving language preference: $e");
    }
  }
}
