import 'package:get/get.dart';
import '../controllers/gerakan_controller.dart';

class GerakanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<GerakanController>(() => GerakanController());
  }
}
