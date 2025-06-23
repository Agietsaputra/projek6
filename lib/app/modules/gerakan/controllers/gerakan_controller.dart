import 'dart:async';
import 'package:get/get.dart';

class Exercise {
  final String name;
  final int duration; // durasi target dalam detik
  bool isCompleted;
  int secondsHeld;

  Exercise({
    required this.name,
    required this.duration,
    this.isCompleted = false,
    this.secondsHeld = 0,
  });
}

class GerakanController extends GetxController {
  var exercises = <Exercise>[
    Exercise(name: 'Butt Kick', duration: 30),
    Exercise(name: 'Calf Raises', duration: 20),
    Exercise(name: 'Frankenstein Walk', duration: 25),
    Exercise(name: 'Standing Hip Circle', duration: 20),
    Exercise(name: 'Walking Lunge', duration: 30),
  ].obs;

  Timer? _timer;
  String? _currentExerciseName;

  void startCounting(String name) {
    if (_currentExerciseName == name) return; // skip jika sudah counting
    stopCounting(); // hentikan timer lain

    _currentExerciseName = name;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final index = exercises.indexWhere((e) => e.name == name);
      if (index != -1 && !exercises[index].isCompleted) {
        exercises[index].secondsHeld++;

        if (exercises[index].secondsHeld >= exercises[index].duration) {
          exercises[index].isCompleted = true;
          stopCounting();
          print('✅ ${name} selesai');
        }

        exercises.refresh();
      }
    });

    print('⏱️ Mulai menghitung: $name');
  }

  void stopCounting() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
      print('🛑 Timer dihentikan');
    }
    _currentExerciseName = null;
  }

  void resetProgress(String name) {
    final index = exercises.indexWhere((e) => e.name == name);
    if (index != -1) {
      exercises[index].secondsHeld = 0;
      exercises[index].isCompleted = false;
      exercises.refresh();
    }
  }

  // Untuk debugging manual
  void markCompleted(String name) {
    final index = exercises.indexWhere((e) => e.name == name);
    if (index != -1) {
      exercises[index].isCompleted = true;
      exercises.refresh();
      stopCounting();
    }
  }
}
