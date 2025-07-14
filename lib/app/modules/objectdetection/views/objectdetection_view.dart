import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/objectdetection_controller.dart';

class ObjectdetectionView extends GetView<ObjectdetectionController> {
  const ObjectdetectionView({super.key});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: controller.initializeCamera(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: Colors.grey[900],
          appBar: AppBar(
            title: const Text("Visual Assist AI"),
            backgroundColor: Colors.deepPurple,
          ),
          body: Obx(() {
            final camCtrl = controller.cameraController.value;
            if (camCtrl == null || !camCtrl.value.isInitialized) {
              return const Center(child: CircularProgressIndicator());
            }

            return Stack(
              children: [
                CameraPreview(camCtrl),
                ...controller.detections.map((detection) {
                  final box = detection['box'];
                  return Positioned(
                    left: box[0].toDouble() / 4,
                    top: box[1].toDouble() / 4,
                    width: (box[2] - box[0]).toDouble() / 4,
                    height: (box[3] - box[1]).toDouble() / 4,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red, width: 2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          color: Colors.red.withOpacity(0.7),
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            "${detection['label']} (${(detection['confidence'] * 100).toStringAsFixed(1)}%)",
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.hearing),
                      label: const Text("Speak Again"),
                      onPressed: () {
                        if (controller.detections.isNotEmpty) {
                          final label = controller.detections[0]['label'];
                          controller.tts.speak("I see $label");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                    ),
                  ),
                )
              ],
            );
          }),
        );
      },
    );
  }
}
