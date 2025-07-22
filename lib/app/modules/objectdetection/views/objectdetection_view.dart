import 'package:beenai_sense/Utility/Colors.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/objectdetection_controller.dart';

class ObjectdetectionView extends GetView<ObjectdetectionController> {
  const ObjectdetectionView({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Obx(() {
          final camCtrl = controller.cameraController.value;
          final isCameraReady = controller.isCameraReady.value;
          if (!isCameraReady || camCtrl == null) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final previewSize =
                  controller.cameraController.value?.value.previewSize;
              final scaleX = constraints.maxWidth / (previewSize?.height ?? 1);
              final scaleY = constraints.maxHeight / (previewSize?.width ?? 1);

              return Stack(
                children: [
                  CameraPreview(camCtrl),
                  Obx(() {
                    return Stack(
                      children: controller.detections.map((detection) {
                        final box = detection['box'];
                        final left = box[0] * scaleX;
                        final top = box[1] * scaleY;
                        final width = (box[2] - box[0]) * scaleX;
                        final height = (box[3] - box[1]) * scaleY;

                        return Positioned(
                          left: left,
                          top: top,
                          width: width,
                          height: height,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.red, width: 2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Container(
                                color: Colors.red.withValues(alpha: 0.7),
                                padding: const EdgeInsets.all(4),
                                child: Text(
                                  "${detection['label']} (${(detection['confidence'] * 100).toStringAsFixed(1)}%)",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }),
                ],
              );
            },
          );
        }),
      ),
    );
  }
}
