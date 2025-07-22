import 'package:get/get.dart';

import '../controllers/static_controller.dart';

class StaticBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StaticController>(
      () => StaticController(),
    );
  }
}
