import 'dart:convert';

import 'package:beenai_sense/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StaticView extends StatefulWidget {
  const StaticView({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _StaticViewState createState() => _StaticViewState();
}

const gistUrl =
    "https://gist.githubusercontent.com/Abdullah2599/49dd6ce5d5ce716d65ebd6a8a938e1d4/raw/gistfile1.json";

class _StaticViewState extends State<StaticView>
    with SingleTickerProviderStateMixin {
      
  Future<void> _loadConfig() async {
    try {
      final response = await http
          .get(Uri.parse(gistUrl))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['baseUrl'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('baseUrl', data['baseUrl']);
          print("✅ Base URL set to ${data['baseUrl']}");
        }
      }
    } catch (e) {
      print("⚠️ Could not fetch config from Gist: $e");
    }
  }

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: -200,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward().then((_) async {
      // 🔹 fetch baseUrl first
      await _loadConfig();
      // Check if language is already selected
      final prefs = await SharedPreferences.getInstance();
      final String? language = prefs.getString('selectedLanguage');
      bool isLanguageSelected = language != null;
      // check if permissions are granted (do not request here)
      PermissionStatus cameraStatus = await Permission.camera.status;
      PermissionStatus microphoneStatus = await Permission.microphone.status;
      bool isPermissionsGranted =
          cameraStatus.isGranted && microphoneStatus.isGranted;

      if (isLanguageSelected && isPermissionsGranted) {
        Get.offNamed(Routes.BOTTOMNAV);
      } else if (isLanguageSelected && !isPermissionsGranted) {
        Get.offNamed(Routes.PERMISSIONS);
      } else {
        Get.offNamed(Routes.LANGUAGESELECTION);
      }
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 0,
      ),
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
