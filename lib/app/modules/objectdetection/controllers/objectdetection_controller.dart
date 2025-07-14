import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ObjectdetectionController extends GetxController {
  var isLoading = false.obs;
  var detections = <Map<String, dynamic>>[].obs;
  final tts = FlutterTts();
  var cameraController = Rx<CameraController?>(null);
  Timer? frameTimer;
  String lastSpoken = '';
  int lastSpokenTime = 0;

  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      cameraController.value = CameraController(camera, ResolutionPreset.medium);
      await cameraController.value!.initialize();
      cameraController.value!.startImageStream((image) {});

      frameTimer = Timer.periodic(const Duration(seconds: 2), (_) => captureAndDetect());
    } catch (e) {
      Get.snackbar("Camera Error", "Failed to initialize camera");
    }
  }

  void disposeCamera() {
    frameTimer?.cancel();
    frameTimer = null;
    cameraController.value?.dispose();
    cameraController.value = null;
  }

  Future<void> captureAndDetect() async {
    if (!(cameraController.value?.value.isInitialized ?? false)) return;
    final image = await cameraController.value!.takePicture();
    await detectObject(File(image.path));
  }

  Future<void> detectObject(File image) async {
    final uri = Uri.parse('http://192.168.2.2:5000/predict');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', image.path));

    try {
      final response = await request.send();
      final responseData = await http.Response.fromStream(response);
      final data = json.decode(responseData.body);

      if (data['success'] == true) {
        detections.value = List<Map<String, dynamic>>.from(data['detections']);
        if (detections.isNotEmpty) {
          final now = DateTime.now().millisecondsSinceEpoch;
          final firstLabel = detections[0]['label'];
          if (firstLabel != lastSpoken || now - lastSpokenTime > 4000) {
            await tts.speak("I see ${firstLabel}");
            lastSpoken = firstLabel;
            lastSpokenTime = now;
          }
        }
      } else {
        Get.snackbar("Error", data['error'] ?? 'Unknown error');
      }
    } catch (e) {
      Get.snackbar("Error", "Connection failed");
    }
  }

  @override
  void onClose() {
    disposeCamera();
    super.onClose();
  }
}
