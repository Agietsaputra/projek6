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
    final startPoint = route.isNotEmpty
        ? route.first
        : const LatLng(-6.200000, 106.816666); // Default ke Jakarta

    final endPoint = route.length > 1 ? route.last : null;

    return Scaffold(
      backgroundColor: const Color(0xFFE1F6F4),
      appBar: AppBar(
        title: const Text(
          'Ringkasan Lari',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF72DEC2),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A1A3F),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // 🌍 PETA DENGAN RUTE
          Expanded(
            flex: 2,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: startPoint,
                initialZoom: 16,
              ),
              children: [
                // 🗺️ Layer Map dari MapTiler
                TileLayer(
                  urlTemplate:
                      'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=vFDGKJX4ek3RBLCsaljd',
                  userAgentPackageName: 'com.example.apa',
                ),

                // 🔵 Garis Rute Lari
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

                // 📍 Marker Start & End
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

          // 📊 RINGKASAN INFORMASI
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
                    blurRadius: 12,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🕒 Durasi
                  Text(
                    'Durasi: ${controller.formattedDuration}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A3F),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 📏 Jarak
                  Text(
                    'Jarak: ${controller.formattedDistance}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A3F),
                    ),
                  ),
                  const Spacer(),

                  // 🔙 Tombol kembali
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Get.offAllNamed('/home'),
                      icon: const Icon(Icons.home, color: Color(0xFF72DEC2)),
                      label: const Text(
                        'Kembali ke Beranda',
                        style: TextStyle(
                          fontSize: 18,
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
