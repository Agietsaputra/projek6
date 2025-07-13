import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';

class DetailRiwayatController extends GetxController {
  late int durasi;               // 🕒 Total durasi dalam detik
  late double jarak;             // 📏 Total jarak dalam kilometer
  late List<LatLng> rute;        // 🗺️ Daftar titik rute GPS
  late DateTime tanggal;         // 📅 Tanggal aktivitas

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    durasi = args['durasi'] ?? 0;
    jarak = args['jarak'] ?? 0.0;

    // 🗓️ Parse tanggal, fallback ke waktu saat ini jika null/invalid
    tanggal = DateTime.tryParse('${args['tanggal']}') ?? DateTime.now();

    // 🧭 Parse dan konversi rute GPS
    final rawRute = args['rute'];
    if (rawRute is List) {
      rute = rawRute.map((e) {
        if (e is LatLng) return e;
        if (e is Map) {
          final lat = e['latitude'] ?? e['lat'] ?? 0.0;
          final lng = e['longitude'] ?? e['lng'] ?? 0.0;
          return LatLng(lat, lng);
        }
        return LatLng(0, 0); // Fallback jika elemen aneh
      }).toList();
    } else {
      rute = [];
      print("⚠️ Rute tidak valid atau null");
    }
  }

  /// 🕒 Format durasi ke HH:mm:ss
  String get formattedDuration {
    final duration = Duration(seconds: durasi);
    String duaDigit(int n) => n.toString().padLeft(2, '0');
    final jam = duaDigit(duration.inHours);
    final menit = duaDigit(duration.inMinutes.remainder(60));
    final detik = duaDigit(duration.inSeconds.remainder(60));
    return '$jam:$menit:$detik';
  }

  /// 📏 Format jarak ke 2 digit desimal
  String get formattedDistance => '${jarak.toStringAsFixed(2)} km';

  /// 📅 Format tanggal ke gaya lokal (Bahasa Indonesia)
  String get formattedTanggal =>
      DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(tanggal);
}
