import 'package:get/get.dart';
import 'package:apa/app/data/api_provider.dart';

import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiProvider>(() => ApiProvider());
    Get.lazyPut<ProfileController>(
      () => ProfileController(),
    );
  }
}
