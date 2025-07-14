import 'package:get/get.dart';

import '../controllers/objectdetection_controller.dart';

class ObjectdetectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ObjectdetectionController>(
      () => ObjectdetectionController(),
    );
  }
}
