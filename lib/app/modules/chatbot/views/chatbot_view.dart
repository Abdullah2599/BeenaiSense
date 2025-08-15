import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import '../controllers/chatbot_controller.dart';

class ChatbotView extends GetView<ChatbotController> {
  const ChatbotView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ChatbotController>()) {
      Get.put(ChatbotController());
    }
    final ctrl = Get.find<ChatbotController>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (_) async {
          if (ctrl.isSpeaking.value) {
            ctrl.stopSpeaking();
            if (await Vibrate.canVibrate) Vibrate.feedback(FeedbackType.success);
          } else {
            await ctrl.startListening();
            if (await Vibrate.canVibrate) Vibrate.feedback(FeedbackType.medium);
          }
        },
        onTapUp: (_) async {
          if (ctrl.isListening.value) {
            await ctrl.stopListening();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Animated background
            Positioned.fill(
              child: Lottie.asset(
                'assets/bg.json', // e.g. flowing waves or particles
                fit: BoxFit.cover,

                repeat: true,
              ),
            ),

            // Floating assistant avatar
            Center(
              child: Obx(() {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: ctrl.isListening.value ? 250 : 200,
                  height: ctrl.isListening.value ? 250 : 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue.withValues(alpha: 0.3),
                    boxShadow: [
                      BoxShadow(
                        color: ctrl.isListening.value
                            ? Colors.blueAccent.withValues(alpha: 0.6)
                            : Colors.transparent,
                        blurRadius: 30,
                        spreadRadius: 10,
                      )
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (ctrl.isListening.value)
                        Lottie.asset(
                          'assets/ripple.json',
                          repeat: true,
                          fit: BoxFit.cover,
                        ),

                      // Center logo
                      Container(
                        width: 100,
                        height: 100,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage('assets/logo.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // Status text
                      Positioned(
                        bottom: 0,
                        child: Text(
                          ctrl.isListening.value
                              ? 'listening'.tr                              : ctrl.isSpeaking.value
                                  ? 'speaking'.tr
                                  : 'tap_to_speak'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 3,
                                color: Colors.black54,
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
