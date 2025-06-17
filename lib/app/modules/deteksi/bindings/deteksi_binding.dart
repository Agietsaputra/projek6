import 'package:apa/app/modules/deteksi/controllers/deteksi_controller.dart';
import 'package:get/get.dart';


class DeteksiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DeteksiController());
  }
}
