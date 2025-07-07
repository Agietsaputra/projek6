import 'package:get/get.dart';
import 'package:apa/app/data/api_provider.dart';

class HistoriController extends GetxController {
  final ApiProvider apiProvider = ApiProvider();

  final isLoading = true.obs;
  final riwayatLari = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchRiwayatLari();
  }

  Future<void> fetchRiwayatLari() async {
    try {
      isLoading.value = true;

      // Ambil data dari API
      final data = await apiProvider.getRiwayatLari();

      print("📦 Riwayat data mentah: $data");

      // Urutkan berdasarkan tanggal (format string / {"\$date": ...})
      data.sort((a, b) {
        final aDate = parseTanggal(a['tanggal']);
        final bDate = parseTanggal(b['tanggal']);
        return bDate.compareTo(aDate); // terbaru di atas
      });

      // Simpan ke variabel observable
      riwayatLari.assignAll(data);
    } catch (e) {
      print("❌ Error fetchRiwayatLari: $e");
      Get.snackbar(
        'Gagal Memuat Data',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }

  DateTime parseTanggal(dynamic raw) {
    if (raw is String) {
      return DateTime.tryParse(raw) ?? DateTime(1970);
    } else if (raw is Map && raw.containsKey("\$date")) {
      return DateTime.tryParse(raw["\$date"]) ?? DateTime(1970);
    }
    return DateTime(1970);
  }
}
