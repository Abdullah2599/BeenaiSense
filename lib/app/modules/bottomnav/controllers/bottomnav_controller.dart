import 'package:beenai_sense/Utility/tts_helper.dart';
import 'package:beenai_sense/app/modules/OCR/controllers/ocr_controller.dart';
import 'package:beenai_sense/app/modules/chatbot/controllers/chatbot_controller.dart';
import 'package:beenai_sense/app/modules/objectdetection/controllers/objectdetection_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomnavController extends GetxController {
  final ScrollController scrollController = ScrollController();
  RxBool hasSeenInstructions = false.obs;

  RxInt selectedIndex = 0.obs;
  final List<String> modes = [
    'object_detection',
    'ocr',
    'beenai_sense',
    // 'currency_reader',
    // 'settings',
  ];

  @override
  void onInit() {
    super.onInit();

    // Initialize controllers
    Get.lazyPut<ObjectdetectionController>(() => ObjectdetectionController());
    Get.lazyPut(() => OcrController());
    Get.lazyPut(() => ChatbotController());

    // Initialize TTS helper
    TTSHelper.initTTS();
    // Speak current mode using TTS helper
    speakMode();

    // Check if user has seen instructions before initializing camera
    _checkInstructionStatus();
  }

  Future<void> _checkInstructionStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    hasSeenInstructions.value = prefs.getBool('has_shown_instruction') ?? false;

    // Only initialize camera if user has seen instructions
    if (hasSeenInstructions.value) {
      _initializeCamera();
    }
  }

  void _initializeCamera() {
    // Initialize camera for the default index
    if (selectedIndex.value == 0) {
      Get.find<ObjectdetectionController>().initializeCamera();
    } else if (selectedIndex.value == 1) {
      Get.find<OcrController>().initializeCamera();
    }
  }

  @override
  void onReady() {
    super.onReady();
    _showInstructionDialogIfFirstLaunch();
  }

  Future<void> _showInstructionDialogIfFirstLaunch() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool hasShownInstruction =
        prefs.getBool('has_shown_instruction') ?? false;

    if (!hasShownInstruction) {
      _showInstructionDialog();
    }
  }

  Future<void> _showInstructionDialog() async {
    // Use the exact key from translations.dart
    String instructions =
        'Welcome to BeenAI Sense!\n\nThis app is designed to help you with:\n• Object Detection - Identifies objects around you\n• OCR - Reads text from images or camera\n• BeenAI Sense - Voice assistant for general information\n• Currency Reader - Identifies currency notes\n• Settings - Customize app preferences\n\nNavigation Instructions:\n• Swipe left/right to switch between sections\n• Single tap on this dialog to close it\n• Double tap on this dialog to replay instructions'
            .tr;

    bool isSpeaking = true;

    Get.dialog(
      // barrierColor: Colors.white,
      GestureDetector(
        onTap: () async {
          // Single tap closes the dialog and saves that it was shown
          if (isSpeaking) {
            await TTSHelper.stop();
          }
          Get.back();
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setBool('has_shown_instruction', true);
          hasSeenInstructions.value = true;

          // Initialize camera after closing instructions
          _initializeCamera();
          speakMode();
        },
        onDoubleTap: () async {
          // Double tap repeats the instructions
          isSpeaking = true;
          await TTSHelper.stop();
          await _speakInstructions();
        },
        child: Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'How to use BeenAI Sense'.tr,
                  style: const TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20.0),
                Text(
                  instructions,
                  style: const TextStyle(fontSize: 16.0, height: 1.5),
                ),
                const SizedBox(height: 20.0),
                Text(
                  'Single tap to close - Double tap to repeat instructions'.tr,
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    // Automatically speak instructions when dialog appears
    _speakInstructions();
  }

  Future<void> _speakInstructions() async {
    // Use the exact key from translations.dart, without the "On main screens" line
    String audioInstructions =
        'Welcome to BeenAI Sense!\n\nThis app helps you with object detection, text reading, voice assistance, currency identification, and settings management.\n\nTo navigate, swipe left or right to move between different sections. \nSingle tap on this instruction to close it. \nDouble tap to replay these instructions.\n\nThank you for using BeenAI Sense!'
            .tr;
    await TTSHelper.setTtsSpeed(0.4);
    await TTSHelper.speakTranslated(audioInstructions);
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
      // Only initialize camera if user has seen instructions
      if (hasSeenInstructions.value) {
        // Handle entering Object Detector
        if (selectedIndex.value == 0) {
          Get.find<ObjectdetectionController>().initializeCamera();
        }
        // Handle entering OCR
        if (selectedIndex.value == 1) {
          Get.find<OcrController>().initializeCamera();
        }
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
      // Only initialize camera if user has seen instructions
      if (hasSeenInstructions.value) {
        // Handle entering Object Detector
        if (selectedIndex.value == 0) {
          Get.find<ObjectdetectionController>().initializeCamera();
        }
        // Handle entering OCR
        if (selectedIndex.value == 1) {
          Get.find<OcrController>().initializeCamera();
        }
      }
      speakMode();
      scrollToIndex(selectedIndex.value);
    }
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
        return FontAwesomeIcons.magnifyingGlass;
      case 1:
        return FontAwesomeIcons.newspaper;
      case 2:
        return FontAwesomeIcons.comments;
      // case 3:
      //   return FontAwesomeIcons.moneyBill;
      // case 4:
      //   return FontAwesomeIcons.gear;
      default:
        return Icons.device_unknown;
    }
  }
}
