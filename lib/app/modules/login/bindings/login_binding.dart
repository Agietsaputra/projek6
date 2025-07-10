import 'package:apa/app/modules/activity/controllers/activity_controller.dart';
import 'package:get/get.dart';
import 'package:apa/app/data/api_provider.dart';
import '../controllers/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiProvider>(() => ApiProvider());
    Get.lazyPut<LoginController>(
      () => LoginController(),
    );
    Get.lazyPut<ActivityController>(() => ActivityController());
  }
}
