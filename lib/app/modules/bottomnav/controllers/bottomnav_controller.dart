import 'package:beenai_sense/app/modules/OCR/controllers/ocr_controller.dart';
import 'package:beenai_sense/app/modules/objectdetection/controllers/objectdetection_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

class BottomnavController extends GetxController {
  final FlutterTts tts = FlutterTts();
  final ScrollController scrollController = ScrollController();

  RxInt selectedIndex = 0.obs;
  final List<String> modes = [
    'Object Detector',
    'Text Reader',
    'Currency Reader',
    'Color Identifier',
    'Scene Describer',
  ];

  @override
  void onInit() {
    super.onInit();
    Get.lazyPut<ObjectdetectionController>(() => ObjectdetectionController());
    Get.lazyPut(()=>OcrController());
    speakMode();
    // Initialize camera for the default index
    if (selectedIndex.value == 0) {
      Get.find<ObjectdetectionController>().initializeCamera();
    } else if (selectedIndex.value == 1) {
      Get.find<OcrController>().initializeCamera();
    }
  }

  Future<void> speakMode() async {
    await tts.setSpeechRate(0.5);
    await tts.setPitch(1.0);
    await tts.setVolume(1.0);
    await tts.speak("${modes[selectedIndex.value]}");
  }

  void swipeLeft() {
  HapticFeedback.selectionClick();
  if (selectedIndex.value < modes.length - 1) {
    // Handle leaving Object Detector
    if (selectedIndex.value == 0) {
      Get.find<ObjectdetectionController>().disposeCamera();
    }
    // Handle leaving OCR
    if (selectedIndex.value == 1) {
      Get.find<OcrController>().disposeCamera();
    }
    selectedIndex.value++;
    // Handle entering Object Detector
    if (selectedIndex.value == 0) {
      Get.find<ObjectdetectionController>().initializeCamera();
    }
    // Handle entering OCR
    if (selectedIndex.value == 1) {
      Get.find<OcrController>().initializeCamera();
    }
    speakMode();
    scrollToIndex(selectedIndex.value);
  }
}

  void swipeRight() {
  HapticFeedback.selectionClick();
  if (selectedIndex.value > 0) {
    // Handle leaving Object Detector
    if (selectedIndex.value == 0) {
      Get.find<ObjectdetectionController>().disposeCamera();
    }
    // Handle leaving OCR
    if (selectedIndex.value == 1) {
      Get.find<OcrController>().disposeCamera();
    }
    selectedIndex.value--;
    // Handle entering Object Detector
    if (selectedIndex.value == 0) {
      Get.find<ObjectdetectionController>().initializeCamera();
    }
    // Handle entering OCR
    if (selectedIndex.value == 1) {
      Get.find<OcrController>().initializeCamera();
    }
    speakMode();
    scrollToIndex(selectedIndex.value);
  }
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
        return Icons.search;
      case 1:
        return Icons.text_fields;
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
