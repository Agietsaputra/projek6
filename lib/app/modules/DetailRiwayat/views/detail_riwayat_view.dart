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
    final startPoint = route.isNotEmpty
        ? route.first
        : const LatLng(-6.200000, 106.816666); // Default: Jakarta

    final endPoint = route.length > 1 ? route.last : null;

    return Scaffold(
      backgroundColor: const Color(0xFFE1F6F4),
      appBar: AppBar(
        title: const Text(
          'Detail Riwayat',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF72DEC2),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A1A3F),
        elevation: 0,
        automaticallyImplyLeading: false, // <- Menghapus ikon kembali
      ),
      body: Column(
        children: [
          // 🌍 PETA
          Expanded(
            flex: 2,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: startPoint,
                initialZoom: 16,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=vFDGKJX4ek3RBLCsaljd',
                  userAgentPackageName: 'com.example.apa',
                ),
                if (route.length > 1)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: route,
                        color: const Color(0xFF72DEC2),
                        strokeWidth: 4.5,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: startPoint,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        Icons.directions_run,
                        color: Colors.green,
                        size: 32,
                      ),
                    ),
                    if (endPoint != null)
                      Marker(
                        point: endPoint,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.flag,
                          color: Colors.red,
                          size: 32,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // 📋 INFORMASI
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.formattedTanggal,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A3F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '🕒 Durasi: ${controller.formattedDuration}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1A1A3F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '📏 Jarak: ${controller.formattedDistance}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1A1A3F),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Get.offNamed('/history'),
                      icon: const Icon(Icons.history, color: Color(0xFF72DEC2)),
                      label: const Text(
                        'Kembali ke Riwayat',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF72DEC2),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1A1A3F),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
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
