import 'package:beenai_sense/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StaticView extends StatefulWidget {
  const StaticView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _StaticViewState createState() => _StaticViewState();
}

class _StaticViewState extends State<StaticView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: -200,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward().then((_) async {
      // Check if language is already selected
      final prefs = await SharedPreferences.getInstance();
      final String? language = prefs.getString('selectedLanguage');
      bool isLanguageSelected = language != null;

      PermissionStatus cameraStatus = await Permission.camera.request();
      // Request microphone permission
      PermissionStatus microphoneStatus = await Permission.microphone.request();
      // Navigate to the appropriate screen after animation completes

      if (cameraStatus.isGranted && microphoneStatus.isGranted && isLanguageSelected) {
        Get.offNamed(Routes.BOTTOMNAV);
      } else {
        Get.offNamed(Routes.LANGUAGESELECTION);
      } 

      // Future.delayed(const Duration(seconds: 0), () {
      //   if (isLanguageSelected) {
      //     Get.offNamed(Routes.BOTTOMNAV);
      //   } else {
      //     Get.offNamed(Routes.LANGUAGESELECTION);
      //   }
      // });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(toolbarHeight: 0, surfaceTintColor: Colors.transparent),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_animation.value, 0),
                child: Center(
                  child: Image.asset('assets/logo.png', width: 150),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
