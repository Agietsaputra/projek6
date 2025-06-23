import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class MulaiLariController extends GetxController {
  RxList<LatLng> routePoints = <LatLng>[].obs;
  RxDouble totalDistance = 0.0.obs;
  RxBool isRunning = false.obs;
  RxInt elapsedSeconds = 0.obs;

  StreamSubscription<Position>? positionStream;
  Timer? _timer;

  final distance = const Distance();

  void startRun() async {
    try {
      await _checkPermission();

      isRunning.value = true;
      elapsedSeconds.value = 0;
      routePoints.clear();
      totalDistance.value = 0.0;

      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        elapsedSeconds.value++;
      });

      positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 5,
        ),
      ).listen((Position position) {
        final point = LatLng(position.latitude, position.longitude);
        if (routePoints.isNotEmpty) {
          totalDistance.value += distance(routePoints.last, point);
        }
        routePoints.add(point);
      });
    } catch (e) {
      Get.snackbar(
        "Izin Lokasi Gagal",
        "$e",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        duration: const Duration(seconds: 3),
      );
    }
  }

  void stopRun() {
    isRunning.value = false;
    _timer?.cancel();
    positionStream?.cancel();

    Get.toNamed('/ringkasan-lari', arguments: {
      'durasi': elapsedSeconds.value,
      'jarak': totalDistance.value / 1000, // km
      'rute': routePoints,
    });
  }

  Future<void> _checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      throw 'Layanan lokasi tidak aktif. Silakan aktifkan GPS.';
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // Tampilkan dialog alasan sebelum minta izin
      await Get.defaultDialog(
        title: "Izin Lokasi Dibutuhkan",
        middleText:
            "Aplikasi ini memerlukan akses lokasi untuk melacak rute lari kamu secara real-time.",
        confirm: ElevatedButton(
          onPressed: () async {
            Get.back(); // Tutup dialog
            final result = await Geolocator.requestPermission();
            if (result == LocationPermission.denied ||
                result == LocationPermission.deniedForever) {
              throw 'Izin lokasi ditolak.';
            }
          },
          child: const Text("Izinkan"),
        ),
        cancel: TextButton(
          onPressed: () => Get.back(),
          child: const Text("Batal"),
        ),
      );
    }

    // Jika sudah ditolak permanen
    if (permission == LocationPermission.deniedForever) {
      await Get.defaultDialog(
        title: "Izin Lokasi Ditolak Permanen",
        middleText:
            "Silakan aktifkan izin lokasi secara manual di pengaturan aplikasi agar fitur pelacakan bisa digunakan.",
        confirm: ElevatedButton(
          onPressed: () {
            Geolocator.openAppSettings();
            Get.back();
          },
          child: const Text("Buka Pengaturan"),
        ),
      );
      throw 'Izin lokasi ditolak permanen.';
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    positionStream?.cancel();
    super.onClose();
  }
}
