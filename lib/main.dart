import 'package:beenai_sense/Utility/language_helper.dart';
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
  
  // Determine initial route
  final String initialRoute = language == null ? Routes.LANGUAGESELECTION : Routes.BOTTOMNAV;
  
  // Determine locale based on saved preference
  final locale = language == 'ur-PK' 
      ? const Locale('ur', 'PK') 
      : const Locale('en', 'US');
      
  // Register language helper as singleton for global access
  Get.put(LanguageHelper());

  runApp(
    GetMaterialApp(
      title: "Beenai Sense",
      initialRoute: initialRoute,
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: locale,
      fallbackLocale: const Locale('en', 'US'),
      getPages: AppPages.routes,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: Colors.blue,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontFamily: 'Roboto'),
        ),
      ),
    ),
  );
}
