import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class Exercise {
  final String name;
  final int duration; // dalam detik
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

  /// Dipanggil dari DeteksiController ketika gerakan dikenali
  void updateFromPrediction(String name) {
    final index = exercises.indexWhere((e) => e.name == name);
    if (index == -1 || exercises[index].isCompleted) return;

    startCounting(name);
  }

  void startCounting(String name) {
    if (_currentExerciseName == name) return;
    stopCounting();

    _currentExerciseName = name;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final index = exercises.indexWhere((e) => e.name == name);
      if (index != -1 && !exercises[index].isCompleted) {
        exercises[index].secondsHeld++;

        if (exercises[index].secondsHeld >= exercises[index].duration) {
          exercises[index].isCompleted = true;
          stopCounting();
          print('✅ $name selesai');

          // Jika semua selesai, tampilkan notifikasi
          if (allCompleted) {
            Future.delayed(const Duration(milliseconds: 300), cekSemuaGerakan);
          }
        }

        exercises.refresh();
      }
    });

    print('⏱️ Mulai menghitung: $name');
  }

  void stopCounting() {
    _timer?.cancel();
    _timer = null;
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

  void markCompleted(String name) {
    final index = exercises.indexWhere((e) => e.name == name);
    if (index != -1) {
      exercises[index].isCompleted = true;
      exercises.refresh();
      stopCounting();
    }
  }

  /// True jika semua gerakan sudah selesai
  bool get allCompleted => exercises.every((e) => e.isCompleted);

  /// 🔔 Cek semua gerakan dan tampilkan notifikasi
  void cekSemuaGerakan() {
    if (allCompleted) {
      Get.snackbar(
        '🎉 Semua Gerakan Selesai',
        'Kamu telah menyelesaikan semua pemanasan!',
        backgroundColor: Colors.green[100],
        colorText: Colors.black,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } else {
      final belum = exercises.where((e) => !e.isCompleted).map((e) => e.name).join(', ');
      Get.snackbar(
        '⏳ Gerakan Belum Selesai',
        'Masih ada gerakan: $belum',
        backgroundColor: Colors.orange[100],
        colorText: Colors.black,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// 🔁 Reset semua gerakan ke kondisi awal
  void resetAll() {
    for (var e in exercises) {
      e.isCompleted = false;
      e.secondsHeld = 0;
    }
    exercises.refresh();
  }
}
