import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/mulai_lari_controller.dart';

class MulaiLariView extends GetView<MulaiLariController> {
  const MulaiLariView({Key? key}) : super(key: key);

  String formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F6F4),
      appBar: AppBar(
        title: const Text("Mulai Lari"),
        backgroundColor: const Color(0xFF1A1A3F),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Obx(() {
        if (controller.currentLocation.value == null &&
            controller.routePoints.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // === MAP ===
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: controller.mapController,
                    options: MapOptions(
                      initialCenter: controller.routePoints.isNotEmpty
                          ? controller.routePoints.last
                          : controller.currentLocation.value!,
                      initialZoom: 16.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: const ['a', 'b', 'c'],
                        userAgentPackageName: 'com.example.app',
                      ),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: controller.routePoints,
                            strokeWidth: 4.0,
                            color: Colors.cyan,
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: controller.routePoints.isNotEmpty
                            ? [
                                Marker(
                                  point: controller.routePoints.last,
                                  width: 60,
                                  height: 60,
                                  child: Transform.rotate(
                                    angle: controller.heading.value * (3.14 / 180),
                                    child: const Icon(
                                      Icons.navigation,
                                      color: Colors.red,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ]
                            : [],
                      ),
                    ],
                  ),

                  // === Recenter Button ===
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: FloatingActionButton(
                      heroTag: "recenter",
                      onPressed: () {
                        final current = controller.routePoints.isNotEmpty
                            ? controller.routePoints.last
                            : controller.currentLocation.value;
                        if (current != null) {
                          controller.mapController.move(current, 16.0);
                        }
                      },
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1A1A3F),
                      child: const Icon(Icons.my_location),
                    ),
                  ),
                ],
              ),
            ),

            // === INFO & BUTTON ===
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Durasi: ${formatDuration(controller.elapsedSeconds.value)}",
                    style: const TextStyle(fontSize: 18, color: Color(0xFF1A1A3F)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Jarak: ${(controller.totalDistance.value / 1000).toStringAsFixed(2)} km",
                    style: const TextStyle(fontSize: 18, color: Color(0xFF1A1A3F)),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: Icon(controller.isRunning.value
                          ? Icons.stop
                          : Icons.play_arrow),
                      label: Text(controller.isRunning.value
                          ? "Selesai Lari"
                          : "Mulai Lari"),
                      onPressed: controller.isRunning.value
                          ? controller.stopRun
                          : controller.startRun,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1A3F),
                        foregroundColor: const Color(0xFF72DEC2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
