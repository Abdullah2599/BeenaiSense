import 'package:beenai_sense/Utility/Colors.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/ocr_controller.dart';

class OcrView extends GetView<OcrController> {
  const OcrView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
    
              // Overlay for recognized text
              if (recognizedText.isNotEmpty)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 170,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(14),
                    constraints: const BoxConstraints(
                      maxHeight: 180, // Limit the height of the container
                      minHeight: 40,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.blackColor.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: SingleChildScrollView(
                        child: Text(
                          recognizedText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
    
              // Accessibility hint at the bottom
              Positioned(
                left: 0,
                right: 0,
                top: 40,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      isProcessing ? 'reading'.tr : 'hold_anywhere'.tr,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        // letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
