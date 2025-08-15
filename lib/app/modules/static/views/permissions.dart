import 'package:beenai_sense/Utility/tts_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionOnboardingView extends StatefulWidget {
  const PermissionOnboardingView({Key? key}) : super(key: key);

  @override
  State<PermissionOnboardingView> createState() =>
      _PermissionOnboardingViewState();
}

class _PermissionOnboardingViewState extends State<PermissionOnboardingView> {
  // final TTSHelper tts = TTSHelper();

  @override
  void initState() {
    super.initState();
    TTSHelper.initTTS();
    _speakIntro();
  }

  Future<void> _speakIntro() async {
    await TTSHelper.speakTranslated("welcome_permissions_intro");
  }

  Future<void> _requestPermissions() async {
    var cameraStatus = await Permission.camera.request();
    var micStatus = await Permission.microphone.request();

    if (cameraStatus.isGranted && micStatus.isGranted) {
      await TTSHelper.speakTranslated("thank_you_permissions_granted");
      await Future.delayed(const Duration(seconds: 4));
      Get.offNamed('/bottomnav'); // Navigate to main app
    } else if (cameraStatus.isPermanentlyDenied ||
        micStatus.isPermanentlyDenied) {
      await TTSHelper.speakTranslated("permissions_permanently_denied");
      await openAppSettings();
    } else {
      await TTSHelper.speakTranslated("permissions_denied");
    }
  }

  @override
  void dispose() {
    TTSHelper.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _requestPermissions,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/logo.png', width: 120),
                  const SizedBox(height: 40),
                  Text(
                    "beenai_sense_requires_camera_and_microphone_access".tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black, fontSize: 22),
                  ),
                  const SizedBox(height: 40),
                  // ElevatedButton(
                  //   onPressed: _requestPermissions,
                  //   style: ElevatedButton.styleFrom(
                  //     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  //     backgroundColor: Colors.blue,
                  //     textStyle: const TextStyle(fontSize: 20),
                  //   ),
                  //   child: const Text("Grant Access"),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
