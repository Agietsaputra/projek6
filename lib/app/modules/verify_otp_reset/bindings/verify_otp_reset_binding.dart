// verify_otp_reset/bindings/verify_otp_reset_binding.dart
import 'package:get/get.dart';
import '../controllers/verify_otp_reset_controller.dart';

class VerifyOtpResetBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => VerifyOtpResetController());
  }
}
