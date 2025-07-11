import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:apa/app/data/api_provider.dart';

class RingkasanLariController extends GetxController {
  late int durasi;
  late double jarak;
  late List<LatLng> route;
  final apiProvider = ApiProvider();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;

    durasi = args['durasi'] ?? 0;
    jarak = args['jarak'] ?? 0.0;

    final rawRute = args['rute'];
    if (rawRute is List) {
      // Periksa apakah elemen adalah Map (dari JSON) atau LatLng
      route = rawRute.map((e) {
        if (e is LatLng) return e;
        if (e is Map) {
          return LatLng(e['latitude'], e['longitude']);
        }
        return LatLng(0, 0); // fallback kalau formatnya aneh
      }).toList();
    } else {
      route = [];
      print("⚠️ Rute tidak valid atau null");
    }

    simpanRiwayat(); // 🟢 Simpan otomatis saat masuk
  }

  Future<void> simpanRiwayat() async {
    try {
      final ruteList = route.map((e) => {
            'latitude': e.latitude,
            'longitude': e.longitude,
          }).toList();

      await apiProvider.simpanRiwayatLariLocal(
        durasi: durasi,
        jarak: jarak,
        rute: ruteList,
      );

      print('✅ Riwayat berhasil disimpan');
    } catch (e) {
      print('❌ Gagal simpan riwayat: $e');
      Get.snackbar('Gagal', 'Riwayat tidak tersimpan: $e');
    }
  }

  /// ✅ Format waktu HH:mm:ss
  String get formattedDuration {
    final duration = Duration(seconds: durasi);
    String duaDigit(int n) => n.toString().padLeft(2, '0');
    final jam = duaDigit(duration.inHours);
    final menit = duaDigit(duration.inMinutes.remainder(60));
    final detik = duaDigit(duration.inSeconds.remainder(60));
    return '$jam:$menit:$detik';
  }

  /// ✅ Format jarak 2 digit desimal
  String get formattedDistance => '${jarak.toStringAsFixed(2)} km';
}
