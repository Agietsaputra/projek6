import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/histori_controller.dart';

class HistoriView extends GetView<HistoriController> {
  const HistoriView({super.key});

  // ✅ Format durasi ke HH:mm:ss
  String formatDurasi(int detik) {
    final durasi = Duration(seconds: detik);
    String duaDigit(int n) => n.toString().padLeft(2, '0');
    final jam = duaDigit(durasi.inHours);
    final menit = duaDigit(durasi.inMinutes.remainder(60));
    final sisaDetik = duaDigit(durasi.inSeconds.remainder(60));
    return '$jam:$menit:$sisaDetik';
  }

  // ✅ Format tanggal dari string atau map
  String formatTanggal(dynamic tanggalRaw) {
    DateTime? date;

    if (tanggalRaw is String) {
      date = DateTime.tryParse(tanggalRaw);
    } else if (tanggalRaw is Map && tanggalRaw.containsKey("\$date")) {
      date = DateTime.tryParse(tanggalRaw["\$date"]);
    }

    if (date == null) return '-';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F6F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A3F),
        foregroundColor: Colors.white,
        title: const Text('Riwayat Lari'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.offAllNamed('/home'),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.riwayatLari.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada riwayat lari.',
              style: TextStyle(
                color: Color(0xFF1A1A3F),
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.riwayatLari.length,
          itemBuilder: (context, index) {
            final item = controller.riwayatLari[index];
            final durasiDetik = item['durasi'] ?? 0;
            final durasi = formatDurasi(durasiDetik);
            final jarak = "${(item['jarak'] ?? 0.0).toStringAsFixed(2)} km";
            final tanggal = formatTanggal(item['tanggal']);

            final List<dynamic> ruteRaw = item['rute'] ?? [];
            final List<LatLng> rute = ruteRaw
                .where((e) => e['latitude'] != null && e['longitude'] != null)
                .map((e) => LatLng(e['latitude'], e['longitude']))
                .toList();

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                leading: const Icon(Icons.directions_run, color: Color(0xFF1A1A3F)),
                title: Text(
                  "Durasi: $durasi",
                  style: const TextStyle(color: Colors.black87),
                ),
                subtitle: Text(
                  "Jarak: $jarak",
                  style: const TextStyle(color: Colors.black54),
                ),
                trailing: Text(
                  tanggal != '-' ? tanggal : 'Tanggal tidak diketahui',
                  style: const TextStyle(color: Color(0xFF1A1A3F)),
                ),
                onTap: () {
                  Get.toNamed('/detail-riwayat', arguments: {
                    'durasi': durasiDetik,
                    'jarak': item['jarak'],
                    'rute': rute,
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
