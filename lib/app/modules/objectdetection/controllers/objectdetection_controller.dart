import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:beenai_sense/Constants/API_key.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ObjectdetectionController extends GetxController {
  var isLoading = false.obs;
  var detections = <Map<String, dynamic>>[].obs;
  final tts = FlutterTts();
  var cameraController = Rx<CameraController?>(null);
  var isCameraReady = false.obs;
  Timer? frameTimer;
  String lastSpoken = '';
  int lastSpokenTime = 0;

  Future<void> initializeCamera() async {
    try {
      isCameraReady.value = false;
      final cameras = await availableCameras();
      final camera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      cameraController.value = CameraController(camera, ResolutionPreset.high);
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
    await tts.stop();
    isCameraReady.value = false;
  }

  Future<void> captureAndDetect() async {
    if (!(cameraController.value?.value.isInitialized ?? false)) return;
    final image = await cameraController.value!.takePicture();
    await detectObject(File(image.path));
  }

  Future<void> detectObject(File image) async {
    print(Api.predict);
    final uri = Uri.parse(Api.baseUrl + Api.predict);
    final request = http.MultipartRequest('POST', uri)
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
            await tts.speak("I see $label");
            lastSpoken = label;
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
