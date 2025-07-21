import 'package:beenai_sense/Utility/Colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/languageselection_controller.dart';


class LanguageselectionView extends GetView<LanguageselectionController> {
  const LanguageselectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double height = screenSize.height;

    // Zone boundaries
    final double centerZoneTop = height * 0.35;
    final double centerZoneBottom = height * 0.65;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (TapDownDetails details) {
          final double dy = details.globalPosition.dy;

          final bool isCenterZone = dy >= centerZoneTop && dy <= centerZoneBottom;
          final bool isTopTap = dy < centerZoneTop;
          final bool isBottomTap = dy > centerZoneBottom;

          if (isCenterZone) {
            controller.speakLanguageInstructions();
          } else if (isTopTap) {
            controller.selectEnglish();
          } else if (isBottomTap) {
            controller.selectUrdu();
          }
        },
        child: Column(
          children: [
            // Top Zone
            Expanded(
              flex: 3,
              child: Container(
                color: AppColors.primary.withOpacity(0.1),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.language, color: Colors.white70, size: 36),
                    SizedBox(height: 8),
                    Text(
                      'Tap here for English',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Center Zone
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.secondary.withOpacity(0.15),
                      AppColors.secondary.withOpacity(0.05),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.replay_circle_filled, color: Colors.white54, size: 40),
                    SizedBox(height: 8),
                    Text(
                      'Tap here to replay instructions',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Zone
            Expanded(
              flex: 3,
              child: Container(
                color: AppColors.primary.withOpacity(0.1),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.language, color: Colors.white70, size: 36),
                    SizedBox(height: 8),
                    Text(
                      'اردو کے لیے یہاں تھپتھپائیں',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
