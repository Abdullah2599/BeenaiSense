import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class OcrController extends GetxController {
  var cameraController = Rx<CameraController?>(null);
  var isCameraReady = false.obs;
  var isProcessing = false.obs;
  var recognizedText = ''.obs;
  var recognizedSentences = <String>[].obs;
  var currentSpokenIndex = 0.obs;
  final tts = FlutterTts();

  @override
  void onInit() {
    super.onInit();
    // Camera initialization is managed by navigation logic, not here.
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
    await tts.stop();
    isCameraReady.value = false;
  }

  List<String> _splitToSentences(String text) {
    // Simple sentence split (can be improved for more languages)
    return text.split(RegExp(r'(?<=[.!?])\s+')).where((s) => s.trim().isNotEmpty).toList();
  }

  Future<void> _speakSentencesSequentially() async {
    await tts.awaitSpeakCompletion(true);
    for (int i = 0; i < recognizedSentences.length; i++) {
      currentSpokenIndex.value = i;
      await tts.speak(recognizedSentences[i]);
      // Optionally add a small delay between sentences
      await Future.delayed(const Duration(milliseconds: 300));
    }
    currentSpokenIndex.value = -1;
  }

  Future<void> captureAndReadText() async {
    if (isProcessing.value || cameraController.value == null || !(cameraController.value!.value.isInitialized)) return;
    isProcessing.value = true;
    recognizedText.value = '';
    try {
      // Spoken countdown for accessibility
      await tts.speak('Hold still. Capturing in 1 seconds.');
      await Future.delayed(const Duration(seconds: 1));
      // Optional: haptic feedback (if context available)
      // Feedback.forLongPress(context); // context not available here, handled in view

      // Double check not processing again
      if (!isProcessing.value) return;
      final image = await cameraController.value!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText result = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();
      recognizedText.value = result.text.trim();
      recognizedSentences.value = _splitToSentences(recognizedText.value);
      currentSpokenIndex.value = 0;
      if (recognizedSentences.isNotEmpty) {
        await _speakSentencesSequentially();
      } else {
        await tts.speak('Unable to detect the text. Please try again.');
        Get.snackbar('OCR', 'Unable to detect the text. Please try again.');
      }
    } catch (e, stacktrace) {
      await tts.speak('An error occurred during text recognition. Please try again.');
      Get.snackbar('OCR Error', 'Failed to recognize text: \\n${e.toString()}');
      // Optionally log error and stacktrace
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
