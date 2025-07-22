// logic/camera_controller.dart
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class CamerascreenController extends GetxController {
  CameraController? cameraController;
  List<CameraDescription>? cameras;
  final FlutterTts tts = FlutterTts();
  final ScrollController scrollController = ScrollController();

  RxInt selectedIndex = 0.obs;
  final List<String> modes = [
    'Text Reader',
    'Object Detector',
    'Currency Reader',
    'Color Identifier',
    'Scene Describer',
  ];

  @override
  void onInit() {
    super.onInit();
    initCamera();
    speakMode();
  }

  Future<void> initCamera() async {
    await Permission.camera.request();
    cameras = await availableCameras();
    if (cameras!.isNotEmpty) {
      cameraController = CameraController(cameras![0], ResolutionPreset.medium);
      await cameraController!.initialize();
      update();
    }
  }

  Future<void> speakMode() async {
    await tts.setSpeechRate(0.5);
    await tts.setPitch(1.0);
    await tts.setVolume(1.0);
    await tts.speak("Selected mode: ${modes[selectedIndex.value]}");
  }

  void swipeLeft() {
    HapticFeedback.selectionClick();
    selectedIndex.value = (selectedIndex.value + 1) % modes.length;
    speakMode();
    scrollToIndex(selectedIndex.value);
  }

  void swipeRight() {
    HapticFeedback.selectionClick();
    selectedIndex.value = (selectedIndex.value - 1 + modes.length) % modes.length;
    speakMode();
    scrollToIndex(selectedIndex.value);
  }

  void onDoubleTap() {
    HapticFeedback.vibrate();
    tts.speak("Activating ${modes[selectedIndex.value]}");
   
  }

  void scrollToIndex(int index) {
    double offset = index * 130.0 - Get.width / 2 + 65;
    scrollController.animateTo(
      offset.clamp(0.0, scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  IconData getModeIcon(int index) {
    switch (index) {
      case 0:
        return Icons.text_fields;
      case 1:
        return Icons.search;
      case 2:
        return Icons.currency_exchange;
      case 3:
        return Icons.color_lens;
      case 4:
        return Icons.landscape;
      default:
        return Icons.device_unknown;
    }
  }
}
