import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:apa/app/data/api_provider.dart';

class RingkasanLariController extends GetxController {
  late int durasi;               // 🕒 Durasi lari dalam detik
  late double jarak;             // 📏 Jarak tempuh dalam kilometer
  late List<LatLng> route;       // 📍 Titik-titik GPS rute lari
  final apiProvider = ApiProvider();

  @override
  void onInit() {
    super.onInit();

    // Ambil data dari argument yang dikirim via Get.toNamed()
    final args = Get.arguments;

    durasi = args['durasi'] ?? 0;
    jarak = args['jarak'] ?? 0.0;

    final rawRute = args['rute'];
    if (rawRute is List) {
      route = rawRute.map((e) {
        if (e is LatLng) return e;
        if (e is Map) {
          return LatLng(e['latitude'], e['longitude']);
        }
        return LatLng(0, 0); // Fallback jika format tidak dikenali
      }).toList();
    } else {
      route = [];
      print("⚠️ Rute tidak valid atau null");
    }

    // Simpan otomatis saat halaman dimuat
    simpanRiwayat();
  }

  /// 🧠 Simpan riwayat lari secara lokal (atau backend)
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

  /// ⏱ Format durasi ke bentuk HH:mm:ss
  String get formattedDuration {
    final duration = Duration(seconds: durasi);
    String duaDigit(int n) => n.toString().padLeft(2, '0');
    final jam = duaDigit(duration.inHours);
    final menit = duaDigit(duration.inMinutes.remainder(60));
    final detik = duaDigit(duration.inSeconds.remainder(60));
    return '$jam:$menit:$detik';
  }

  /// 📏 Format jarak ke 2 digit desimal (dalam km)
  String get formattedDistance => '${jarak.toStringAsFixed(2)} km';
}
