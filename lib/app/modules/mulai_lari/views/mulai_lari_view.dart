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
      appBar: AppBar(title: const Text("Mulai Lari")),
      body: Obx(() {
        return Column(
          children: [
            Expanded(
              child: FlutterMap(
                mapController: controller.mapController,
                options: MapOptions(
                  initialCenter: controller.routePoints.isNotEmpty
                      ? controller.routePoints.last
                      : LatLng(-6.200000, 106.816666), // Default Jakarta
                  initialZoom: 16.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: controller.routePoints,
                        strokeWidth: 4.0,
                        color: Colors.blue,
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
                                angle: controller.heading.value *
                                    (3.14 / 180), // konversi ke radian
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
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    "Durasi: ${formatDuration(controller.elapsedSeconds.value)}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    "Jarak: ${(controller.totalDistance.value / 1000).toStringAsFixed(2)} km",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 16),
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
