import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'dart:async';

import 'package:apa/app/data/api_provider.dart'; // ✅ Sesuaikan dengan path project kamu

class MulaiLariController extends GetxController {
  RxList<LatLng> routePoints = <LatLng>[].obs;
  RxDouble totalDistance = 0.0.obs;
  RxBool isRunning = false.obs;
  RxInt elapsedSeconds = 0.obs;
  RxDouble heading = 0.0.obs;

  Rx<LatLng?> currentLocation = Rx<LatLng?>(null);

  StreamSubscription<Position>? positionStream;
  Timer? _timer;

  final distance = const Distance();
  late MapController mapController;

  @override
  void onInit() {
    super.onInit();
    mapController = MapController();
    getCurrentLocation(); // Ambil posisi awal saat init
  }

  Future<void> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      currentLocation.value = LatLng(position.latitude, position.longitude);
    } catch (e) {
      Get.snackbar("Lokasi Gagal", "$e");
    }
  }

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
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 5,
        ),
      ).listen((Position position) {
        final point = LatLng(position.latitude, position.longitude);

        if (routePoints.isNotEmpty) {
          totalDistance.value += distance(routePoints.last, point);
        }

        routePoints.add(point);
        heading.value = position.heading;

        if (isRunning.value) {
          mapController.move(point, 16.0); // follow user
        }
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

  void stopRun() async {
    isRunning.value = false;
    _timer?.cancel();
    positionStream?.cancel();

    final serializedRoute = routePoints
        .map((e) => {'latitude': e.latitude, 'longitude': e.longitude})
        .toList();

    final durasi = elapsedSeconds.value;
    final jarakKm = totalDistance.value / 1000;

    try {
      // ✅ Kirim ke backend
      final api = ApiProvider();
      await api.simpanRiwayatLari(
        durasi: durasi,
        jarak: jarakKm,
        rute: serializedRoute,
      );
    } catch (e) {
      Get.snackbar("Gagal Simpan Riwayat", "$e",
          backgroundColor: Colors.red[100],
          colorText: Colors.red[900],
          snackPosition: SnackPosition.TOP);
    }

    // ✅ Navigasi ke ringkasan
    Get.toNamed('/ringkasan-lari', arguments: {
      'durasi': durasi,
      'jarak': jarakKm,
      'rute': serializedRoute,
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
      await Get.defaultDialog(
        title: "Izin Lokasi Dibutuhkan",
        middleText:
            "Aplikasi ini memerlukan akses lokasi untuk melacak rute lari kamu secara real-time.",
        confirm: ElevatedButton(
          onPressed: () async {
            Get.back();
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
