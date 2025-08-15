import 'package:beenai_sense/Utility/Colors.dart';
import 'package:beenai_sense/app/modules/OCR/views/ocr_view.dart';
import 'package:beenai_sense/app/modules/chatbot/views/chatbot_view.dart';
import 'package:beenai_sense/app/modules/objectdetection/views/objectdetection_view.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../controllers/bottomnav_controller.dart';

class BottomnavView extends GetView<BottomnavController> {
  const BottomnavView({super.key});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            controller.swipeLeft();
          } else {
            controller.swipeRight();
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          extendBody: true,
          appBar: AppBar(
            backgroundColor: AppColors.whiteColor,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 80,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
            ),
            title: Image.asset("assets/logo.png", height: 100),
            centerTitle: true,
          ),
          body: Obx(() {
            return SafeArea(
              top: false, // You already have AppBar
              bottom: false, // Let bottom bar handle it
              child: Stack(
                children: List.generate(controller.modes.length, (index) {
                  return Offstage(
                    offstage: controller.selectedIndex.value != index,
                    child: TickerMode(
                      enabled: controller.selectedIndex.value == index,
                      child: Padding(
                        padding: EdgeInsets.only(
                          // top: 50, // Height of your app bar
                          bottom: 160, // Height of your custom bottom nav
                        ),
                        child: _buildViewForIndex(index),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),

          // Bottom mode bar

          // place holder bottom bar
          bottomNavigationBar: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 160,
              padding: EdgeInsets.only(
                top: 10,
                bottom: MediaQuery.of(context).padding.bottom + 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    offset: const Offset(0, -2),
                    blurRadius: 3,
                  ),
                ],
              ),
              child: Column(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      controller.modes[controller.selectedIndex.value].tr,
                      key: ValueKey(controller.selectedIndex.value),
                      style: TextStyle(
                        color: AppColors.blackColor,
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
                        final isSelected =
                            controller.selectedIndex.value == index;
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.secondary
                                  : AppColors.blackColor.withValues(
                                      alpha: 0.35,
                                    ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: isSelected
                                  ? [
                                      const BoxShadow(
                                        color: AppColors.secondary,
                                        blurRadius: 2,
                                        offset: Offset(0, 1),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FaIcon(
                                  controller.getModeIcon(index),
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  controller.modes[index].tr,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
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
        ),
      );
    });
  }
}

Widget _buildViewForIndex(int index) {
  switch (index) {
    case 0:
      return ObjectdetectionView();
    case 1:
      return OcrView();
    case 2:
      return ChatbotView();
    case 3:
      return Placeholder(); // Color Identifier
    case 4:
      return Placeholder(); // Scene Describer
    default:
      return Center(child: Text("Invalid index"));
  }
}
