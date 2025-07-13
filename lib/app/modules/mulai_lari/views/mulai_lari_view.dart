import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/mulai_lari_controller.dart';

class MulaiLariView extends StatelessWidget {
  const MulaiLariView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MulaiLariController>();

    return Scaffold(
      backgroundColor: const Color(0xFFE1F6F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A3F),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF72DEC2)),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Mulai Lari',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF72DEC2),
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 40),
                const SizedBox(height: 8),
                Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => controller.getCurrentLocation(),
                  child: const Text("Coba Ambil Lokasi Lagi"),
                ),
              ],
            ),
          );
        }

        final lokasi = controller.currentLocation.value;
        if (lokasi == null) {
          return const Center(child: Text("Menunggu lokasi..."));
        }

        return Stack(
          children: [
            FlutterMap(
              mapController: controller.mapController,
              options: MapOptions(
                initialCenter: lokasi,
                initialZoom: 16.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=vFDGKJX4ek3RBLCsaljd",
                  userAgentPackageName: 'com.example.apa',
                ),
                Obx(() => PolylineLayer(
                      polylines: [
                        Polyline(
                          points: controller.routePoints.toList(),
                          strokeWidth: 4.0,
                          color: Colors.blueAccent,
                        ),
                      ],
                    )),
                Obx(() => MarkerLayer(
                      markers: [
                        if (controller.currentLocation.value != null)
                          Marker(
                            point: controller.currentLocation.value!,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.person_pin_circle,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                      ],
                    )),
              ],
            ),

            // Durasi & Jarak
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Obx(() => Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "⏱️ ${_formatWaktu(controller.elapsedSeconds.value)}",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "📏 ${(controller.totalDistance.value / 1000).toStringAsFixed(2)} KM",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )),
            ),

            // Tombol center lokasi
            Positioned(
              top: 100,
              right: 16,
              child: FloatingActionButton(
                heroTag: "center_button",
                backgroundColor: Colors.white,
                onPressed: controller.centerToCurrentLocation,
                child: const Icon(Icons.my_location, color: Colors.black),
              ),
            ),

            // Tombol Mulai/Selesai Lari
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Obx(() => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: controller.isRunning.value
                            ? Colors.red
                            : const Color(0xFF1A1A3F),
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        if (controller.isRunning.value) {
                          controller.stopRun();
                        } else {
                          controller.startRun();
                        }
                      },
                      child: Text(
                        controller.isRunning.value
                            ? "Selesai Lari"
                            : "Mulai Lari",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: controller.isRunning.value
                              ? Colors.white
                              : const Color(0xFF72DEC2),
                        ),
                      ),
                    ),
                  )),
            ),
          ],
        );
      }),
    );
  }

  String _formatWaktu(int detik) {
    final durasi = Duration(seconds: detik);
    String duaDigit(int n) => n.toString().padLeft(2, '0');
    final jam = duaDigit(durasi.inHours);
    final menit = duaDigit(durasi.inMinutes.remainder(60));
    final sisaDetik = duaDigit(durasi.inSeconds.remainder(60));
    return '$jam:$menit:$sisaDetik';
  }
}
