import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/ringkasan_lari_controller.dart';

class RingkasanLariView extends GetView<RingkasanLariController> {
  const RingkasanLariView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F6F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A3F),
        title: const Text(
          'Ringkasan Lari',
          style: TextStyle(color: Color(0xFF72DEC2)),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF72DEC2)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_run, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            Text(
              'Durasi Lari',
              style: TextStyle(fontSize: 20, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              controller.formattedDuration,
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            Text(
              'Jarak Tempuh',
              style: TextStyle(fontSize: 20, color: Colors.grey[700]),
            ),
            const SizedBox(height: 8),
            Text(
              controller.formattedDistance,
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  await controller.apiProvider.simpanRiwayatLari(
                    durasi: controller.durasi,
                    jarak: controller.jarak,
                  );
                  Get.snackbar(
                    '✅ Berhasil',
                    'Riwayat lari disimpan',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                  Get.offAllNamed('/home');
                } catch (e) {
                  Get.snackbar(
                    '❌ Gagal',
                    '$e',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
              icon: const Icon(Icons.save),
              label: const Text("Simpan ke History"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A3F),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
