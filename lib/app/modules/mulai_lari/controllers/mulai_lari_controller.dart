import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'dart:async';
import 'package:apa/app/data/api_provider.dart';

class MulaiLariController extends GetxController {
  RxList<LatLng> routePoints = <LatLng>[].obs;
  RxDouble totalDistance = 0.0.obs;
  RxBool isRunning = false.obs;
  RxInt elapsedSeconds = 0.obs;
  RxDouble heading = 0.0.obs;

  Rx<LatLng?> currentLocation = Rx<LatLng?>(null);
  RxBool isLoading = true.obs;
  RxString errorMessage = ''.obs;

  StreamSubscription<Position>? positionStream;
  Timer? _timer;

  final distance = const Distance();
  late MapController mapController;

  String get formattedElapsedTime {
    final durasi = Duration(seconds: elapsedSeconds.value);
    String duaDigit(int n) => n.toString().padLeft(2, '0');
    final jam = duaDigit(durasi.inHours);
    final menit = duaDigit(durasi.inMinutes.remainder(60));
    final detik = duaDigit(durasi.inSeconds.remainder(60));
    return '$jam:$menit:$detik';
  }

  @override
  void onInit() {
    super.onInit();
    mapController = MapController();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await _checkPermission();
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      currentLocation.value = LatLng(position.latitude, position.longitude);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
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
        if (isRunning.value) {
          elapsedSeconds.value++;
        }
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
        currentLocation.value = point;

        if (isRunning.value) {
          mapController.move(point, 16.0);
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
      final api = ApiProvider();
      await api.simpanRiwayatLariLocal(
        durasi: durasi,
        jarak: jarakKm,
        rute: serializedRoute,
      );
    } catch (e) {
      Get.snackbar(
        "Gagal Simpan Riwayat",
        "$e",
        backgroundColor: Colors.red[100],
        colorText: Colors.red[900],
        snackPosition: SnackPosition.TOP,
      );
    }

    Get.toNamed('/ringkasan-lari', arguments: {
      'durasi': durasi,
      'jarak': jarakKm,
      'rute': serializedRoute,
    });
  }

  void centerToCurrentLocation() {
    final loc = currentLocation.value;
    if (loc != null) {
      mapController.move(loc, 16.0);
    } else {
      Get.snackbar("Lokasi Belum Tersedia", "Tunggu hingga lokasi diperoleh.");
    }
  }

  Future<void> _checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      throw 'GPS tidak aktif. Aktifkan terlebih dahulu.';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final result = await Geolocator.requestPermission();
      if (result == LocationPermission.denied ||
          result == LocationPermission.deniedForever) {
        throw 'Izin lokasi ditolak.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      throw 'Izin lokasi ditolak permanen. Aktifkan dari pengaturan.';
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    positionStream?.cancel();
    super.onClose();
  }
}
