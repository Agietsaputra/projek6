import 'package:apa/app/modules/verify/controllers/verify_controller.dart';
import 'package:get/get.dart';

class OtpVerifyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OtpVerifyController>(() => OtpVerifyController());
  }
}
