import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  final Rx<ThemeData> currentTheme = ThemeData().obs;

  @override
  void onInit() {
    super.onInit();
    _setThemeFromSavedLanguage(); // Load theme on startup
  }

  void _setThemeFromSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final language = prefs.getString('selectedLanguage') ?? 'en-US';
    updateThemeBasedOnLanguage(language);
  }

  void updateThemeBasedOnLanguage(String languageCode) {
    if (languageCode == 'ur-PK') {
      currentTheme.value = ThemeData(
        textTheme: GoogleFonts.notoNastaliqUrduTextTheme(),
        useMaterial3: true,
        primaryColor: Colors.blue,
      );
    } else {
      currentTheme.value = ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
        primaryColor: Colors.blue,
      );
    }
  }
}

