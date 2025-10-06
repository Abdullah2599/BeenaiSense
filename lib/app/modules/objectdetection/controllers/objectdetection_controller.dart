import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:beenai_sense/Constants/API_key.dart';
import 'package:beenai_sense/Utility/connectivity_service.dart';
import 'package:beenai_sense/Utility/tflite_service.dart';
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
  var isOnlineMode = true.obs; // Track current mode
  Timer? frameTimer;
  String lastSpoken = '';
  int lastSpokenTime = 0;
  var selectedLanguage = 'en-US'.obs;

  @override
  void onInit() async {
    super.onInit();
    await loadLanguagePreference();
    
    // Initialize TFLite model on startup
    await TFLiteDetector.initialize();
  }

  Future<void> loadLanguagePreference() async {
    final prefs = await SharedPreferences.getInstance();
    selectedLanguage.value = prefs.getString('selectedLanguage') ?? 'en-US';
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

      cameraController.value = CameraController(
        camera, 
        ResolutionPreset.high,
        enableAudio: false
      );
      
      await cameraController.value!.initialize();
      cameraController.value!.startImageStream((image) {});
      isCameraReady.value = true;
      
      frameTimer = Timer.periodic(
        const Duration(seconds: 2),
        (_) => captureAndDetect(),
      );
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
    try {
      // Check internet connectivity
      bool isConnected = await ConnectivityService.isConnected();
      
      List<Map<String, dynamic>> allDetections = [];
      
      if (isConnected) {
        // Try online detection first
        allDetections = await _detectOnline(image);
        
        // If online fails, fallback to offline
        if (allDetections.isEmpty) {
          print('⚠️ Online detection failed, switching to offline...');
          allDetections = await _detectOffline(image);
          isOnlineMode.value = false;
        } else {
          isOnlineMode.value = true;
        }
      } else {
        // Use offline detection
        print('📱 No internet, using offline detection');
        allDetections = await _detectOffline(image);
        isOnlineMode.value = false;
      }

      // Process detections
      _processDetections(allDetections);
      
    } catch (e) {
      print('Detection error: $e');
      // On any error, try offline fallback
      final offlineDetections = await _detectOffline(image);
      _processDetections(offlineDetections);
    }
  }

  // Online detection via API
  Future<List<Map<String, dynamic>>> _detectOnline(File image) async {
    try {
      final baseUrl = await Api.getBaseUrl();
      
      // Check if server is reachable
      bool serverReachable = await ConnectivityService.isServerReachable(baseUrl);
      if (!serverReachable) {
        return [];
      }

      final url = Uri.parse("$baseUrl${Api.predict}");
      final request = http.MultipartRequest('POST', url)
        ..files.add(await http.MultipartFile.fromPath('image', image.path));

      // Set timeout for API call
      final response = await request.send().timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('API timeout'),
      );

      final responseData = await http.Response.fromStream(response);
      final data = json.decode(responseData.body);

      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['detections']);
      }
      
      return [];
    } catch (e) {
      print('Online detection error: $e');
      return [];
    }
  }

  // Offline detection via TFLite
  Future<List<Map<String, dynamic>>> _detectOffline(File image) async {
    try {
      return await TFLiteDetector.detectObjects(image);
    } catch (e) {
      print('Offline detection error: $e');
      return [];
    }
  }

  // Process and announce detections
  void _processDetections(List<Map<String, dynamic>> allDetections) {
    // Filter by confidence
    detections.value = allDetections
        .where((d) => (d['confidence'] as double) >= 0.70)
        .toList();

    if (detections.isNotEmpty) {
      final now = DateTime.now().millisecondsSinceEpoch;
      final first = detections[0];
      final label = first['label'] as String;
      final confidence = first['confidence'] as double;

      if (confidence >= 0.70 &&
          (label != lastSpoken || now - lastSpokenTime > 4000)) {
        
        // Announce detection with mode indicator
        String announcement = isOnlineMode.value 
            ? "I see $label" 
            : "I see $label";
            
        if (selectedLanguage.value == 'ur-PK') {
          final detectedText = 'detected_object'.tr + 
                               getUrduTranslation(label);
          TTSHelper.speak(detectedText);
        } else {
          TTSHelper.speak(announcement);
        }
        
        lastSpoken = label;
        lastSpokenTime = now;
      }
    }
  }

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
    TFLiteDetector.dispose();
    super.onClose();
  }
}
