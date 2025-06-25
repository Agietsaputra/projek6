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

      // Debug log jika perlu
      // print("📦 Data Diterima: $data");

      // Urutkan berdasarkan tanggal (jika tersedia)
      data.sort((a, b) {
        final aDate = DateTime.tryParse(a['tanggal'] ?? '') ?? DateTime(1970);
        final bDate = DateTime.tryParse(b['tanggal'] ?? '') ?? DateTime(1970);
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
}
