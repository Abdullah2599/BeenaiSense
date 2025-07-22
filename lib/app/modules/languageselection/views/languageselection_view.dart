import 'package:beenai_sense/Utility/Colors.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
      backgroundColor: AppColors.whiteColor,
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
                decoration: BoxDecoration(
                // color: AppColors.secondary.withValues(alpha: 0.5),
                gradient: LinearGradient(
                  colors: [
                    AppColors.secondary.withValues(alpha: 0.7),
                    AppColors.secondary,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20), bottom: Radius.circular(20)),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    FaIcon(FontAwesomeIcons.language, color: Colors.white, size: 36),
                    SizedBox(height: 12),
                    Text(
                      'Tap here for English',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
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
                  color: AppColors.whiteColor,
                 
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    FaIcon(FontAwesomeIcons.repeat, color: Colors.black, size: 40),
                    SizedBox(height: 8),
                    Text(
                      'Tap here to replay instructions',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
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
                decoration: BoxDecoration(
                // color: AppColors.primary.withValues(alpha: 0.5),
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20), bottom: Radius.circular(20)),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:  [
                    FaIcon(FontAwesomeIcons.language, color: Colors.white, size: 36),
                    SizedBox(height: 12),
                    Text(
                      'اردو کے لیے یہاں ٹیپ کریں',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontFamily: GoogleFonts.notoNastaliqUrdu().fontFamily,
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
