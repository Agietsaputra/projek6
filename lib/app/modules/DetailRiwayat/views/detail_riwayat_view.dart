import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

import '../controllers/detail_riwayat_controller.dart';

class DetailRiwayatView extends GetView<DetailRiwayatController> {
  const DetailRiwayatView({super.key});

  Future<void> _simpanSebagaiGambar(GlobalKey key) async {
    try {
      final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final status = await Permission.storage.request();
      if (!status.isGranted) {
        Get.snackbar('Izin ditolak', 'Tidak dapat menyimpan gambar');
        return;
      }

      final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(pngBytes),
        quality: 100,
        name: 'riwayat_lari_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (result['isSuccess'] == true) {
        Get.snackbar('✅ Berhasil', 'Tersimpan ke galeri');
      } else {
        Get.snackbar('❌ Gagal', 'Gagal menyimpan gambar');
      }
    } catch (e) {
      Get.snackbar('❌ Error', '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey();
    final route = controller.rute;
    final startPoint = route.isNotEmpty ? route.first : const LatLng(0, 0);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A3F),
      appBar: AppBar(
        title: const Text('Detail Riwayat'),
        backgroundColor: const Color(0xFF1A1A3F),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: RepaintBoundary(
              key: key,
              child: FlutterMap(
                options: MapOptions(initialCenter: startPoint, initialZoom: 16),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  if (route.length > 1)
                    PolylineLayer(
                      polylines: [
                        Polyline(points: route, color: Colors.cyanAccent, strokeWidth: 4.0),
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
          ),
          const SizedBox(height: 12),
          Text(
            'Durasi: ${controller.formattedDuration}',
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
          Text(
            'Jarak: ${controller.formattedDistance}',
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF72DEC2),
                  foregroundColor: Colors.black,
                ),
                onPressed: () => _simpanSebagaiGambar(key),
                icon: const Icon(Icons.download),
                label: const Text('Simpan ke Galeri'),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                onPressed: () => Get.offNamed('/histori'),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali'),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
