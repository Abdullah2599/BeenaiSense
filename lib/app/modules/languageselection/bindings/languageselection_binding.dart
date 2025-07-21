import 'package:get/get.dart';

import '../controllers/languageselection_controller.dart';

class LanguageselectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LanguageselectionController>(
      () => LanguageselectionController(),
    );
  }
}
