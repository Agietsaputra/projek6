import 'package:get/get.dart';

class Exercise {
  final String name;
  bool isCompleted;

  Exercise({required this.name, this.isCompleted = false});
}

class GerakanController extends GetxController {
  var exercises = <Exercise>[
    Exercise(name: 'Butt Kick'),
    Exercise(name: 'Calf Raises'),
    Exercise(name: 'Frankenstein Walk'),
    Exercise(name: 'Standing Hip Circle'),
    Exercise(name: 'Walking Lunge'),
  ].obs;

  void markCompleted(String name) {
    final index = exercises.indexWhere((e) => e.name == name);
    if (index != -1) {
      exercises[index].isCompleted = true;
      exercises.refresh();
    }
  }
}
