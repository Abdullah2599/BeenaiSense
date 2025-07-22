import 'package:beenai_sense/Utility/language_helper.dart';
import 'package:beenai_sense/Utility/theme_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/routes/app_pages.dart';
import 'Utility/translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final prefs = await SharedPreferences.getInstance();
  final String? language = prefs.getString('selectedLanguage');
  final locale = language == 'ur-PK' ? const Locale('ur', 'PK') : const Locale('en', 'US');

  Get.put(ThemeController());
  Get.put(LanguageHelper());

  runApp(MyApp(locale: locale));
}

class MyApp extends StatelessWidget {
  final Locale locale;
  MyApp({required this.locale});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find();

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(0.75)),
      child: Obx(() {
        return GetMaterialApp(
          title: "Beenai Sense",
          debugShowCheckedModeBanner: false,
          locale: locale,
          fallbackLocale: const Locale('en', 'US'),
          translations: AppTranslations(),
          initialRoute: Routes.STATIC,
          getPages: AppPages.routes,
          theme: themeController.currentTheme.value,
        );
      }),
    );
  }
}
