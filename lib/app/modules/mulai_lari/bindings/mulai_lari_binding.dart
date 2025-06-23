import 'package:get/get.dart';
import '../controllers/mulai_lari_controller.dart';

class MulaiLariBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MulaiLariController>(() => MulaiLariController());
  }
}
