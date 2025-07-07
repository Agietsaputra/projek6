import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/detail_riwayat_controller.dart';

class DetailRiwayatView extends GetView<DetailRiwayatController> {
  const DetailRiwayatView({super.key});

  @override
  Widget build(BuildContext context) {
    final route = controller.rute;
    final startPoint = route.isNotEmpty ? route.first : const LatLng(0, 0);
    final endPoint = route.length > 1 ? route.last : null;

    return Scaffold(
      backgroundColor: const Color(0xFFE1F6F4),
      appBar: AppBar(
        title: const Text('Detail Riwayat'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A1A3F),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // === Peta ===
          Expanded(
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
                        color: Colors.cyan,
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
                      child: const Icon(Icons.play_arrow, color: Colors.green, size: 32),
                    ),
                    if (endPoint != null)
                      Marker(
                        point: endPoint,
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.flag, color: Colors.red, size: 32),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // === Info Durasi & Jarak ===
          const SizedBox(height: 12),
          Text(
            'Durasi: ${controller.formattedDuration}',
            style: const TextStyle(fontSize: 18, color: Color(0xFF1A1A3F)),
          ),
          Text(
            'Jarak: ${controller.formattedDistance}',
            style: const TextStyle(fontSize: 18, color: Color(0xFF1A1A3F)),
          ),
          const SizedBox(height: 16),

          // === Tombol kembali ===
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A3F),
                foregroundColor: const Color(0xFF72DEC2),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Get.offAllNamed('/history'),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Kembali'),
            ),
          ),
        ],
      ),
    );
  }
}
