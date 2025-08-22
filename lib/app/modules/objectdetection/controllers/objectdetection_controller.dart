import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:beenai_sense/Constants/API_key.dart';
import 'package:beenai_sense/Utility/tts_helper.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ObjectdetectionController extends GetxController {
  var isLoading = false.obs;
  var detections = <Map<String, dynamic>>[].obs;
  var cameraController = Rx<CameraController?>(null);
  var isCameraReady = false.obs;
  Timer? frameTimer;
  String lastSpoken = '';
  int lastSpokenTime = 0;
  var selectedLanguage = 'en-US'.obs;

  @override
  void onInit() async {
    super.onInit();
    await loadLanguagePreference();
    // await initializeCamera();
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

      cameraController.value = CameraController(camera, ResolutionPreset.high,enableAudio: false);
      await cameraController.value!.initialize();
      cameraController.value!.startImageStream((image) {});
      isCameraReady.value = true;
      frameTimer = Timer.periodic(
        const Duration(seconds: 2),
        (_) => captureAndDetect(),
      );
      
      // Speak instructions in the selected language
      // await TTSHelper.speakTranslated('object_instructions');
    } catch (e) {
      Get.snackbar("Camera Error", "Failed to initialize camera");
    }
  }

  Future<void> disposeCamera() async {
    frameTimer?.cancel();
    frameTimer = null;
    cameraController.value?.dispose();
    cameraController.value = null;
    detections.value = [];
    await TTSHelper.stop();
    isCameraReady.value = false;
  }

  Future<void> captureAndDetect() async {
    if (!(cameraController.value?.value.isInitialized ?? false)) return;
    final image = await cameraController.value!.takePicture();
    await detectObject(File(image.path));
  }

  Future<void> detectObject(File image) async {
    final baseUrl = await Api.getBaseUrl();
    final url = Uri.parse("$baseUrl${Api.predict}");  
    final request = http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('image', image.path));

    try {
      final response = await request.send();
      final responseData = await http.Response.fromStream(response);
      final data = json.decode(responseData.body);

      if (data['success'] == true) {
        final allDetections = List<Map<String, dynamic>>.from(
          data['detections'],
        );
        detections.value = allDetections
            .where((d) => d['confidence'] >= 0.70)
            .toList();

        if (detections.isNotEmpty) {
          final now = DateTime.now().millisecondsSinceEpoch;
          final first = detections[0];
          final label = first['label'];
          final confidence = first['confidence'];

          if (confidence >= 0.70 &&
              (label != lastSpoken || now - lastSpokenTime > 4000)) {
            
            // Use localized speech based on selected language
            if (selectedLanguage.value == 'ur-PK') {
              // For Urdu, use the translated "Detected: " + object name
              final detectedText = 'detected_object'.tr + getUrduTranslation(label);
              await TTSHelper.speak(detectedText);
            } else {
              // For English
              await TTSHelper.speak("I see ${label}");
            }
            
            lastSpoken = label;
            lastSpokenTime = now;
          }
        } else {
          // No objects detected
          // await TTSHelper.speakTranslated('no_object');
        }
      } else {
        Get.snackbar("Error", data['error'] ?? 'Unknown error');
      }
    } catch (e) {
      Get.snackbar("Error", "Connection failed");
    }
  }

  // Helper method to get Urdu translation for common objects
  // In a real app, you might use an API or a more comprehensive translation system
  String getUrduTranslation(String englishLabel) {
    final Map<String, String> translations = {
      'person': 'انسان',
      'car': 'گاڑی',
      'chair': 'کرسی',
      'bottle': 'بوتل',
      'cup': 'کپ',
      'dog': 'کتا',
      'cat': 'بلی',
      'book': 'کتاب',
      'phone': 'فون',
      'laptop': 'لیپ ٹاپ',
      'table': 'میز',
      'door': 'دروازہ',
      'window': 'کھڑکی',
    };

    return translations[englishLabel.toLowerCase()] ?? englishLabel;
  }

  @override
  void onClose() {
    disposeCamera();
    super.onClose();
  }
}
