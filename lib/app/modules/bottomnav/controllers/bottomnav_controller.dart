import 'package:beenai_sense/Utility/tts_helper.dart';
import 'package:beenai_sense/app/modules/OCR/controllers/ocr_controller.dart';
import 'package:beenai_sense/app/modules/objectdetection/controllers/objectdetection_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomnavController extends GetxController {
  final ScrollController scrollController = ScrollController();

  RxInt selectedIndex = 0.obs;
  final List<String> modes = [
    'object_detection',
    'ocr',
    'currency_reader',
    'color_identifier',
    'scene_describer',
  ];
  


  @override
  void onInit() {
    super.onInit();
    
    // Initialize controllers
    Get.lazyPut<ObjectdetectionController>(() => ObjectdetectionController());
    Get.lazyPut(() => OcrController());

    // Initialize TTS helper
     TTSHelper.initTTS();
    // Speak current mode using TTS helper
     speakMode();
   
    
    
    
    // Initialize camera for the default index
    if (selectedIndex.value == 0) {
      Get.find<ObjectdetectionController>().initializeCamera();
    } else if (selectedIndex.value == 1) {
      Get.find<OcrController>().initializeCamera();
    }
  }

  Future<void> speakMode() async {
    // Use TTS helper with translations
    await TTSHelper.speakTranslated(modes[selectedIndex.value]);
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

  // void onDoubleTap() async {
  //   HapticFeedback.vibrate();
  //   final message = "Activating ${modes[selectedIndex.value]}";
    
  //   if (selectedLanguage.value == 'ur-PK') {
  //     // Translation for "Activating" in Urdu + the mode name
  //     await TTSHelper.speak("${modes[selectedIndex.value].tr} فعال کر رہا ہے");
  //   } else {
  //     await TTSHelper.speak("Activating ${modes[selectedIndex.value].tr}");
  //   }
  // }

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
