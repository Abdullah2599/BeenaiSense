import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageselectionController extends GetxController {
  final FlutterTts flutterTts = FlutterTts();
  final RxBool isSpeaking = false.obs;
  final RxString selectedLanguage = ''.obs;
  final RxBool isPermissionGranted = false.obs;

  // Use this flag to ensure instructions only play once on startup
  bool hasPlayedInitialInstructions = false;

  @override
  void onInit() {
    super.onInit();
    // Set up basic initialization synchronously
    initBasic();
  }

  void initBasic() {
    // Initialize any synchronous setup here
    isSpeaking.value = false;
    hasPlayedInitialInstructions = false;
  }

  @override
  void onReady() async {
    super.onReady();
    try {
      await initTTS(); // Ensure TTS is ready
      bool hasExistingLanguage = await checkLanguagePreference(); // Navigate away if already selected
      
      if (!hasExistingLanguage && !hasPlayedInitialInstructions) {
        hasPlayedInitialInstructions = true;
        await speakLanguageInstructions(); // Speak the instructions if no language set
      }
    } catch (e) {
      print("Error in language controller initialization: $e");
    }
  }

  @override
  void onClose() {
    flutterTts.stop();
    super.onClose();
  }

  Future<void> initTTS() async {
    // Set up TTS engine
    try {
      await flutterTts.setLanguage('en-US');
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.setVolume(1.0);
      await flutterTts.setPitch(1.0);
      
      flutterTts.setCompletionHandler(() {
        isSpeaking.value = false;
      });
      
      // Check if TTS is working by getting available languages
      await flutterTts.getLanguages;
      
      return;
    } catch (e) {
      print("Error initializing TTS: $e");
      Get.snackbar(
        "TTS Error", 
        "Could not initialize text-to-speech. The app might not speak instructions.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<bool> checkLanguagePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? language = prefs.getString('selectedLanguage');
      
      if (language != null) {
        selectedLanguage.value = language;
        
        // Update app locale before navigation
        if (language == 'ur-PK') {
          Get.updateLocale(const Locale('ur', 'PK'));
        } else {
          Get.updateLocale(const Locale('en', 'US'));
        }
        
        // If language is already selected, navigate to the main screen
        // But first request permissions
        await requestPermissions();
        Get.offAllNamed('/bottomnav');
        return true;
      }
      return false;
    } catch (e) {
      print("Error checking language preference: $e");
      return false;
    }
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
      // First in English
      await flutterTts.setLanguage('en-US');
      await flutterTts.speak(
        'To select English, tap the top of the screen.',
      );
      
      // Wait for English to finish
      await Future.delayed(const Duration(seconds: 3));
      
      // Then in Urdu
      await flutterTts.setLanguage('ur-PK');
      await flutterTts.speak(
        'اردو کا انتخاب کرنے کے لیے، اسکرین کے نیچے والے حصے پر تھپتھپائیں۔',
      );
      
      // Add shorter delay for the replay instruction
      await Future.delayed(const Duration(seconds: 3));
      
      // One more helpful instruction about the middle area
      await flutterTts.setLanguage('ur-PK'); // Keep in Urdu for graceful flow
      await flutterTts.speak(
        'ہدایات دوبارہ سننے کے لیے، درمیانی حصے پر تھپتھپائیں۔',
      );
    } catch (e) {
      print("Error speaking instructions: $e");
      isSpeaking.value = false;
    }
  }

  Future<bool> requestPermissions() async {
    try {
      // Request camera permission
      PermissionStatus cameraStatus = await Permission.camera.request();
      
      // Request microphone permission
      PermissionStatus microphoneStatus = await Permission.microphone.request();
      
      // Storage permission might be needed for saving images
      PermissionStatus storageStatus = await Permission.storage.request();
      
      // Check if permissions are granted
      bool allGranted = cameraStatus.isGranted && 
                        microphoneStatus.isGranted && 
                        storageStatus.isGranted;
      
      isPermissionGranted.value = allGranted;
      return allGranted;
    } catch (e) {
      print("Error requesting permissions: $e");
      return false;
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
      
      // Request permissions before confirmation message
      bool permissionsGranted = await requestPermissions();
      
      // Speak selection confirmation
      await flutterTts.setLanguage('en-US');
      if (permissionsGranted) {
        await flutterTts.speak(
          'You have selected English. All permissions are granted. Starting the app now.',
        );
      } else {
        await flutterTts.speak(
          'You have selected English. Some permissions were denied. The app may not work correctly.',
        );
      }
      
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
      
      // Save preference first so it's ready for the next screen
      await saveLanguagePreference('ur-PK');
      
      // Request permissions before confirmation message
      bool permissionsGranted = await requestPermissions();
      
      // Speak selection confirmation
      await flutterTts.setLanguage('ur-PK');
      if (permissionsGranted) {
        await flutterTts.speak(
          'آپ نے اردو کا انتخاب کیا ہے۔ تمام اجازتیں مل گئی ہیں۔ ایپ اب شروع ہو رہی ہے۔',
        );
      } else {
        await flutterTts.speak(
          'آپ نے اردو کا انتخاب کیا ہے۔ کچھ اجازتیں منسوخ کر دی گئیں۔ ایپ ٹھیک سے کام نہیں کر سکتی۔',
        );
      }
      
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
