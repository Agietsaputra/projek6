import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class TutorialController extends GetxController {
  late VideoPlayerController videoController;
  late String exerciseName;

  final isInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    exerciseName = Get.arguments ?? 'unknown';
    final path = 'assets/videos/${exerciseName.toLowerCase().replaceAll(' ', '_')}.mp4';

    videoController = VideoPlayerController.asset(path)
      ..initialize().then((_) {
        isInitialized.value = true;
        videoController.play();
        update();
      });
  }

  @override
  void onClose() {
    videoController.dispose();
    super.onClose();
  }
}
