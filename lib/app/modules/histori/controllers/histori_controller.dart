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

      final data = await apiProvider.getRiwayatLariLocal();
      print("📦 Riwayat data lokal: ${data.length}");

      final Map<String, Map<String, dynamic>> uniqueByDate = {};

      for (var item in data) {
        if (item.containsKey('tanggal')) {
          final tanggalKey = parseTanggal(item['tanggal'])
              .toIso8601String()
              .substring(0, 10); // yyyy-MM-dd

          if (!uniqueByDate.containsKey(tanggalKey)) {
            uniqueByDate[tanggalKey] = item;
          }
        }
      }

      final uniqueList = uniqueByDate.values.toList();
      uniqueList.sort((a, b) {
        final aDate = parseTanggal(a['tanggal']);
        final bDate = parseTanggal(b['tanggal']);
        return bDate.compareTo(aDate);
      });

      riwayatLari.assignAll(uniqueList);
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
      return DateTime.tryParse(raw)?.toLocal() ?? DateTime(1970);
    } else if (raw is Map && raw.containsKey("\$date")) {
      return DateTime.tryParse(raw["\$date"])?.toLocal() ?? DateTime(1970);
    }
    return DateTime(1970);
  }

  /// ✅ Format durasi detik ke HH:mm:ss
  String formatDurasi(int durasiDetik) {
    final durasi = Duration(seconds: durasiDetik);
    String duaDigit(int n) => n.toString().padLeft(2, '0');
    final jam = duaDigit(durasi.inHours);
    final menit = duaDigit(durasi.inMinutes.remainder(60));
    final detik = duaDigit(durasi.inSeconds.remainder(60));
    return '$jam:$menit:$detik';
  }
}
