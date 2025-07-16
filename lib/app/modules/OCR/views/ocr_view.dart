import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/ocr_controller.dart';

class OcrView extends GetView<OcrController> {
  const OcrView({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Obx(() {
          final camCtrl = controller.cameraController.value;
          final isCameraReady = controller.isCameraReady.value;
          final isProcessing = controller.isProcessing.value;
          final recognizedText = controller.recognizedText.value;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onLongPress: () async {
              // Haptic feedback for accessibility
              Feedback.forLongPress(context);
              await controller.captureAndReadText();
            },
            child: Stack(
              children: [
                // Camera Preview
                if (isCameraReady && camCtrl != null)
                  Positioned.fill(child: CameraPreview(camCtrl))
                else
                  const Center(child: CircularProgressIndicator()),
      
                // Overlay for recognized text
                if (recognizedText.isNotEmpty)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 170,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Obx(() {
                        final sentences = controller.recognizedSentences;
                        final currentIdx = controller.currentSpokenIndex.value;
                        return SizedBox(
                          height: 110,
                          child: Scrollbar(
                            thumbVisibility: true,
                            child: ListView.builder(
                              itemCount: sentences.length,
                              itemBuilder: (context, idx) {
                                final isCurrent = idx == currentIdx;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                                  child: Text(
                                    sentences[idx],
                                    style: TextStyle(
                                      color: isCurrent ? Colors.yellow : Colors.white,
                                      fontSize: 15,
                                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
      
                // // Loading spinner overlay
                // if (isProcessing)
                //   Container(
                //     color: Colors.black.withOpacity(0.5),
                //     child: const Center(
                //       child: CircularProgressIndicator(color: Colors.blue, strokeWidth: 6),
                //     ),
                //   ),
      
                // Accessibility hint at the bottom
                Positioned(
                  left: 0,
                  right: 0,
                  top: 40,
                  child: Center(
                    child: Text(
                      isProcessing ? 'Reading...' : 'Hold anywhere on screen to read',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
