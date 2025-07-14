import 'package:get/get.dart';

import '../modules/OCR/bindings/ocr_binding.dart';
import '../modules/OCR/views/ocr_view.dart';
import '../modules/bottomnav/bindings/bottomnav_binding.dart';
import '../modules/bottomnav/views/bottomnav_view.dart';
import '../modules/camerascreen/bindings/camerascreen_binding.dart';
import '../modules/camerascreen/views/camerascreen_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/objectdetection/bindings/objectdetection_binding.dart';
import '../modules/objectdetection/views/objectdetection_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.BOTTOMNAV;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.CAMERASCREEN,
      page: () => const CamerascreenView(),
      binding: CamerascreenBinding(),
    ),
    GetPage(
      name: _Paths.BOTTOMNAV,
      page: () => const BottomnavView(),
      binding: BottomnavBinding(),
    ),
    GetPage(
      name: _Paths.OCR,
      page: () => const OcrView(),
      binding: OcrBinding(),
    ),
    GetPage(
      name: _Paths.OBJECTDETECTION,
      page: () => const ObjectdetectionView(),
      binding: ObjectdetectionBinding(),
    ),
  ];
}
