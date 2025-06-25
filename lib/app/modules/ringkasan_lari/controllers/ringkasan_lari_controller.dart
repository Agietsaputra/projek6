import 'package:get/get.dart';
import 'package:apa/app/data/api_provider.dart';

class RingkasanLariController extends GetxController {
  late int durasi;
  late double jarak;
  final apiProvider = ApiProvider();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    durasi = args['durasi'] ?? 0;
    jarak = args['jarak'] ?? 0.0;

    simpanRiwayat(); // 🟢 Simpan otomatis saat masuk
  }

  Future<void> simpanRiwayat() async {
    try {
      await apiProvider.simpanRiwayatLari(durasi: durasi, jarak: jarak);
      print('✅ Riwayat berhasil disimpan');
    } catch (e) {
      print('❌ Gagal simpan riwayat: $e');
      Get.snackbar('Gagal', 'Riwayat tidak tersimpan: $e');
    }
  }

  String get formattedDuration {
    final m = (durasi ~/ 60).toString().padLeft(2, '0');
    final s = (durasi % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get formattedDistance => '${jarak.toStringAsFixed(2)} km';
}
