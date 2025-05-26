import 'package:get/get.dart';

import '../controllers/histori_controller.dart';

class HistoriBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HistoriController>(
      () => HistoriController(),
    );
  }
}
