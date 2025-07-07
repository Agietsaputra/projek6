import 'package:apa/app/modules/ringkasan_lari/controllers/ringkasan_lari_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class RingkasanLariView extends GetView<RingkasanLariController> {
  const RingkasanLariView({super.key});

  @override
  Widget build(BuildContext context) {
    final route = controller.route;
    final startPoint = route.isNotEmpty ? route.first : const LatLng(-6.200000, 106.816666); // Default ke Jakarta

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ringkasan Lari'),
        backgroundColor: const Color(0xFF1A1A3F),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: startPoint,
                initialZoom: 16,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                if (route.length > 1)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: route,
                        color: Colors.blue,
                        strokeWidth: 4.0,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: startPoint,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.directions_run, color: Colors.green, size: 32),
                    ),
                    if (route.length > 1)
                      Marker(
                        point: route.last,
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.flag, color: Colors.red, size: 32),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Durasi: ${controller.formattedDuration}', style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 8),
                  Text('Jarak: ${controller.formattedDistance}', style: const TextStyle(fontSize: 20)),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Get.offAllNamed('/home'),
                      icon: const Icon(Icons.home),
                      label: const Text('Kembali ke Beranda'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFF1A1A3F),
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
