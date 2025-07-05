import 'package:apa/app/modules/ringkasan_lari/controllers/ringkasan_lari_controller.dart';
import 'package:get/get.dart';

class RingkasanLariBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RingkasanLariController>(() => RingkasanLariController());
  }
}
