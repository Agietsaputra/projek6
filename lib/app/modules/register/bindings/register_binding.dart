import 'package:get/get.dart';
import 'package:apa/app/data/api_provider.dart';
import '../controllers/register_controller.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiProvider>(() => ApiProvider());
    Get.lazyPut<RegisterController>(
      () => RegisterController(),
    );
  }
}
