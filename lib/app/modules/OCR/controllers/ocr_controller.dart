import 'package:beenai_sense/Utility/tts_helper.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OcrController extends GetxController {
  var cameraController = Rx<CameraController?>(null);
  var isCameraReady = false.obs;
  var isProcessing = false.obs;
  var recognizedText = ''.obs;
  var recognizedSentences = <String>[].obs;
  var currentSpokenIndex = 0.obs;
  var selectedLanguage = 'en-US'.obs;

  @override
  void onInit() {
    super.onInit();
    loadLanguagePreference();
  }

  Future<void> loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    selectedLanguage.value = prefs.getString('selectedLanguage') ?? 'en-US';
    // Initialize TTS with selected language
    await TTSHelper.initTTS();
  }

  Future<void> initializeCamera() async {
    try {
      isCameraReady.value = false;
      final cameras = await availableCameras();
      final camera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      cameraController.value = CameraController(camera, ResolutionPreset.high, enableAudio: false);
      await cameraController.value!.initialize();
      isCameraReady.value = true;
      
      // Speak instructions in the selected language
      // await TTSHelper.speakTranslated('ocr_instructions');
    } catch (e) {
      Get.snackbar('Camera Error', 'Could not initialize camera');
    }
  }

  Future<void> disposeCamera() async {
    cameraController.value?.dispose();
    cameraController.value = null;
    recognizedText.value = '';
    recognizedSentences.value = [];
    currentSpokenIndex.value = 0;
    await TTSHelper.stop();
    isCameraReady.value = false;
  }

  // List<String> _splitToSentences(String text) {
  //   // Simple sentence split (can be improved for more languages)
  //   return text.split(RegExp(r'(?<=[.!?])\s+')).where((s) => s.trim().isNotEmpty).toList();
  // }

  // Future<void> _speakSentencesSequentially() async {
  //   for (int i = 0; i < recognizedSentences.length; i++) {
  //     currentSpokenIndex.value = i;
  //     await TTSHelper.speak(recognizedSentences[i]);
  //     // Optionally add a small delay between sentences
  //     await Future.delayed(const Duration(milliseconds: 300));
  //   }
  //   currentSpokenIndex.value = -1;
  // }

  Future<void> captureAndReadText() async {
    if (isProcessing.value || cameraController.value == null || !(cameraController.value!.value.isInitialized)) return;
    isProcessing.value = true;
    recognizedText.value = '';
    try {
      // Spoken countdown for accessibility in selected language
      if (selectedLanguage.value == 'ur-PK') {
        await TTSHelper.speak('حرکت نہ کریں۔ 1 سیکنڈ میں تصویر لی جائے گی۔');
      } else {
        await TTSHelper.speak('Hold still. Capturing in 1 seconds.');
      }
      await Future.delayed(const Duration(seconds: 3));

      // Double check not processing again
      if (!isProcessing.value) return;
      final image = await cameraController.value!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      
      // Use Latin script for now since Arabic script might not be available in the current version
      // In a real app, you might want to check available scripts or use a different library for Urdu
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText result = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();
      recognizedText.value = result.text.trim();
      // recognizedSentences.value = _splitToSentences(recognizedText.value);
      // currentSpokenIndex.value = 0;
      
      if (recognizedText.value.isNotEmpty) {
        // First announce that text was detected
        // await TTSHelper.speakTranslated('text_detected');
        // await Future.delayed(const Duration(seconds: 5));
        // await _speakSentencesSequentially();
        await TTSHelper.speak(recognizedText.value);
      } else {
        await TTSHelper.speakTranslated('no_text');
        Get.snackbar('OCR', 'no_text'.tr);
      }
    } catch (e, stacktrace) {
      if (selectedLanguage.value == 'ur-PK') {
        await TTSHelper.speak('متن کی شناخت کے دوران ایک خرابی پیش آئی۔ براہ کرم دوبارہ کوشش کریں۔');
      } else {
        await TTSHelper.speak('An error occurred during text recognition. Please try again.');
      }
      Get.snackbar('OCR Error', 'Failed to recognize text: \n${e.toString()}');
      print('OCR Error: $e\n$stacktrace');
    } finally {
      isProcessing.value = false;
    }
  }

  @override
  void onClose() {
    disposeCamera();
    super.onClose();
  }
}
