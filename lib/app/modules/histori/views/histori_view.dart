import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/histori_controller.dart';

class HistoriView extends GetView<HistoriController> {
  const HistoriView({super.key});

  String formatDurasi(int detik) {
    final menit = detik ~/ 60;
    final sisaDetik = detik % 60;
    return '${menit.toString().padLeft(2, '0')}:${sisaDetik.toString().padLeft(2, '0')}';
  }

  String formatTanggal(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '-';
    final date = DateTime.tryParse(isoDate);
    if (date == null) return '-';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Lari')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.riwayatLari.isEmpty) {
          return const Center(child: Text('Belum ada riwayat lari.'));
        }

        return ListView.builder(
          itemCount: controller.riwayatLari.length,
          itemBuilder: (context, index) {
            final item = controller.riwayatLari[index];
            final durasiDetik = item['durasi'] ?? 0;
            final durasi = formatDurasi(durasiDetik);
            final jarak = (item['jarak'] ?? 0.0).toStringAsFixed(2);
            final tanggal = formatTanggal(item['tanggal'] ?? '-');

            final List<dynamic> ruteRaw = item['rute'] ?? [];
            final List<LatLng> rute = ruteRaw.map((e) {
              return LatLng(e['latitude'], e['longitude']);
            }).toList();

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: ListTile(
                leading: const Icon(Icons.directions_run, color: Color(0xFF1A1A3F)),
                title: Text("Durasi: $durasi", style: const TextStyle(color: Colors.black87)),
                subtitle: Text("Jarak: $jarak km", style: const TextStyle(color: Colors.black54)),
                trailing: Text(tanggal, style: const TextStyle(color: Color(0xFF1A1A3F))),
                onTap: () {
                  Get.toNamed('/detail-riwayat', arguments: {
                    'durasi': durasiDetik,
                    'jarak': item['jarak'],
                    'route': rute,
                  });
                },
              ),
            );
          },
        );
      }),
    );
  }
}
