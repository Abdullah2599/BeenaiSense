import 'package:get/get.dart';

import '../controllers/camerascreen_controller.dart';

class CamerascreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CamerascreenController>(
      () => CamerascreenController(),
    );
  }
}
