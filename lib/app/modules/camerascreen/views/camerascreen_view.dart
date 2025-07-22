// ui/camera_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import '../controllers/camerascreen_controller.dart';

class CamerascreenView extends GetView<CamerascreenController> {
  const CamerascreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.cameraController == null || !controller.cameraController!.value.isInitialized) {
        return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator()),
        );
      }

      return GestureDetector(
        onDoubleTap: controller.onDoubleTap,
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            controller.swipeLeft();
          } else {
            controller.swipeRight();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              CameraPreview(controller.cameraController!),

              Positioned(
                top: 40,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "Swipe left/right anywhere. Double tap to activate.",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 180,
                  padding: const EdgeInsets.only(bottom: 20, top: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          controller.modes[controller.selectedIndex.value],
                          key: ValueKey(controller.selectedIndex.value),
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      SingleChildScrollView(
                        controller: controller.scrollController,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: List.generate(controller.modes.length, (index) {
                            final isSelected = controller.selectedIndex.value == index;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: GestureDetector(
                                onTap: () {
                                  controller.selectedIndex.value = index;
                                  controller.speakMode();
                                  controller.scrollToIndex(index);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.blue
                                        : Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: isSelected
                                        ? [const BoxShadow(color: Colors.blue, blurRadius: 6, offset: Offset(0, 3))]
                                        : [],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        controller.getModeIcon(index),
                                        color: isSelected ? Colors.black : Colors.white,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        controller.modes[index],
                                        style: TextStyle(
                                          color: isSelected ? Colors.black : Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
