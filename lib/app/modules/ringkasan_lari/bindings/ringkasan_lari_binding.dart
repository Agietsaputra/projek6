import 'package:get/get.dart';
import '../controllers/ringkasan_lari_controller.dart';

class RingkasanLariBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RingkasanLariController>(() => RingkasanLariController());
  }
}
