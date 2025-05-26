import 'package:get/get.dart';
import 'package:apa/app/modules/deteksi/controllers/deteksi_controller.dart';

class DeteksiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeteksiController>(() => DeteksiController());
  }
}
