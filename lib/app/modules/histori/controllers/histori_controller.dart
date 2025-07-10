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

      // Ambil dari local storage
      final data = await apiProvider.getRiwayatLariLocal();

      print("📦 Riwayat data lokal: $data");

      // Urutkan berdasarkan tanggal
      data.sort((a, b) {
        final aDate = DateTime.parse(a['tanggal']);
        final bDate = DateTime.parse(b['tanggal']);
        return bDate.compareTo(aDate);
      });

      riwayatLari.assignAll(data);
    } catch (e) {
      print("❌ Error fetchRiwayatLari lokal: $e");
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
