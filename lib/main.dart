import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/routes/app_pages.dart';
import 'Utility/translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Force portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  
  // Check if language is already selected
  final prefs = await SharedPreferences.getInstance();
  final String? language = prefs.getString('selectedLanguage');
  
  final String initialRoute = language == null ? Routes.LANGUAGESELECTION : Routes.BOTTOMNAV;

  runApp(
    GetMaterialApp(
      title: "Beenai Sense",
      initialRoute: initialRoute,
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: language == 'ur-PK' ? const Locale('ur', 'PK') : const Locale('en', 'US'),
      fallbackLocale: const Locale('en', 'US'),
      getPages: AppPages.routes,
    ),
  );
}
