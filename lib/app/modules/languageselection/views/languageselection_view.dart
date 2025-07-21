import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/languageselection_controller.dart';

class LanguageselectionView extends GetView<LanguageselectionController> {
  const LanguageselectionView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.speakLanguageInstructions();
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (TapDownDetails details) {
          final Size screenSize = MediaQuery.of(context).size;
          final double dx = details.globalPosition.dx;
          final double dy = details.globalPosition.dy;

          final double height = screenSize.height;
          final double centerZoneTop = height * 0.35;
          final double centerZoneBottom = height * 0.65;

          final bool isCenterZone =
              dy >= centerZoneTop && dy <= centerZoneBottom;
          final bool isTopTap = dy < centerZoneTop;
          final bool isBottomTap = dy > centerZoneBottom;

          if (isCenterZone) {
            controller.speakLanguageInstructions(); // Replay instructions
          } else if (isTopTap) {
            controller.selectEnglish();
          } else if (isBottomTap) {
            controller.selectUrdu();
          }
        },

        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', width: 150, height: 150),
              const SizedBox(height: 40),
              const Text(
                'Welcome to Beenai Sense',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Tap the top for English\nTap the bottom for Urdu',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
