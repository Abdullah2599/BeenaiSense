import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageselectionController extends GetxController {
  final FlutterTts flutterTts = FlutterTts();
  final RxBool isSpeaking = false.obs;
  final RxString selectedLanguage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Nothing async here — only basic init
  }

  @override
  void onReady() async {
    super.onReady();

    await initTTS(); // Ensure TTS is ready
    await checkLanguagePreference(); // Navigate away if already selected
    await speakLanguageInstructions(); // Finally, speak the instructions
  }

  @override
  void onClose() {
    flutterTts.stop();
    super.onClose();
  }

  Future<void> initTTS() async {
    // Set up TTS engine
    await flutterTts.setLanguage('en-US');
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    flutterTts.setCompletionHandler(() {
      isSpeaking.value = false;
    });
  }

  Future<void> checkLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final String? language = prefs.getString('selectedLanguage');

    if (language != null) {
      selectedLanguage.value = language;
      // If language is already selected, navigate to the main screen
      Get.offAllNamed('/bottomnav');
    }
  }

  Future<void> speakLanguageInstructions() async {
    if (isSpeaking.value) {
      await flutterTts.stop();
    }

    isSpeaking.value = true;

    await flutterTts.setLanguage('en-US');
    await flutterTts.speak(
      'To select English, tap the top side of the screen.',
    );

    // Wait until TTS finishes
    await Future.delayed(Duration(seconds: 5)); // Optionally adjust this

    await flutterTts.setLanguage('ur-PK');
    await flutterTts.speak(
      'اردو کا انتخاب کرنے کے لیے، اسکرین کے نیچے والے حصے پر تھپتھپائیں۔',
    );
  }

  Future<void> selectEnglish() async {
    await flutterTts.stop();
    selectedLanguage.value = 'en-US';
    await flutterTts.setLanguage('en-US');
    await flutterTts.speak(
      'You have selected English. The app will now proceed.',
    );
    await saveLanguagePreference('en-US');
    await Future.delayed(const Duration(seconds: 5));
    Get.offAllNamed('/bottomnav');
  }

  Future<void> selectUrdu() async {
    await flutterTts.stop();
    selectedLanguage.value = 'ur-PK';
    await flutterTts.setLanguage('ur-PK');
    await flutterTts.speak('آپ نے اردو کا انتخاب کیا ہے۔ ایپ اب آگے بڑھے گی۔');
    await saveLanguagePreference('ur-PK');
    await Future.delayed(const Duration(seconds: 5));
    Get.offAllNamed('/bottomnav');
  }

  Future<void> saveLanguagePreference(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLanguage', language);
  }
}
