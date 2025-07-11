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
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A3F),
        foregroundColor: Colors.white,
        title: const Text("Mulai Lari"),
        centerTitle: true,
      ),
      body: Obx(() {
        final lokasi = controller.currentLocation.value;
        if (lokasi == null) {
          return const Center(child: CircularProgressIndicator());
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
                // ✅ MapTiler Tile
                TileLayer(
                  urlTemplate:
                      "https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=vFDGKJX4ek3RBLCsaljd",
                  userAgentPackageName: 'com.example.apa',
                ),

                // ✅ Real-time Polyline
                Obx(() => PolylineLayer(
                      polylines: [
                        Polyline(
                          points: controller.routePoints,
                          strokeWidth: 4.0,
                          color: Colors.blueAccent,
                        ),
                      ],
                    )),

                // ✅ Marker posisi user
                Obx(() => MarkerLayer(
                      markers: [
                        Marker(
                          point: controller.currentLocation.value!,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.person_pin_circle,
                            color: Colors.red,
                            size: 40,
                          ),
                        )
                      ],
                    )),
              ],
            ),

            // ✅ Durasi dan Jarak
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => Text(
                          "⏱️ ${_formatWaktu(controller.elapsedSeconds.value)}",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        )),
                    Obx(() => Text(
                          "📏 ${(controller.totalDistance.value / 1000).toStringAsFixed(2)} KM",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        )),
                  ],
                ),
              ),
            ),

            // ✅ Tombol Pusatkan ke Lokasi
            Positioned(
              top: 100,
              right: 16,
              child: FloatingActionButton(
                heroTag: "center_button",
                backgroundColor: Colors.white,
                onPressed: () {
                  final current = controller.currentLocation.value;
                  if (current != null) {
                    controller.mapController.move(current, 16.0);
                  }
                },
                child: const Icon(Icons.my_location, color: Colors.black),
              ),
            ),

            // ✅ Tombol Mulai / Selesai
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Obx(() => ElevatedButton.icon(
                    icon: Icon(controller.isRunning.value
                        ? Icons.stop
                        : Icons.play_arrow),
                    label: Text(controller.isRunning.value
                        ? "Selesai Lari"
                        : "Mulai Lari"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.isRunning.value
                          ? Colors.red
                          : const Color(0xFF1A1A3F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (controller.isRunning.value) {
                        controller.stopRun();
                      } else {
                        controller.startRun();
                      }
                    },
                  )),
            ),
          ],
        );
      }),
    );
  }

  /// ✅ Format HH:mm:ss dari total detik
  String _formatWaktu(int detik) {
    final durasi = Duration(seconds: detik);
    String duaDigit(int n) => n.toString().padLeft(2, '0');
    final jam = duaDigit(durasi.inHours);
    final menit = duaDigit(durasi.inMinutes.remainder(60));
    final sisaDetik = duaDigit(durasi.inSeconds.remainder(60));
    return '$jam:$menit:$sisaDetik';
  }
}
