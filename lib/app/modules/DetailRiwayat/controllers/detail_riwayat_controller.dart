import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';

class DetailRiwayatController extends GetxController {
  late int durasi;
  late double jarak;
  late List<LatLng> rute;
  late DateTime tanggal;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;

    durasi = args['durasi'] ?? 0;
    jarak = args['jarak'] ?? 0.0;
    tanggal = DateTime.tryParse('${args['tanggal']}') ?? DateTime.now();

    final rawRute = args['rute'];
    if (rawRute is List) {
      rute = rawRute.map((e) {
        if (e is LatLng) return e;
        if (e is Map) {
          final lat = e['latitude'] ?? e['lat'] ?? 0.0;
          final lng = e['longitude'] ?? e['lng'] ?? 0.0;
          return LatLng(lat, lng);
        }
        return LatLng(0, 0);
      }).toList();
    } else {
      rute = [];
      print("⚠️ Rute tidak valid atau null");
    }
  }

  /// Format waktu HH:mm:ss
  String get formattedDuration {
    final duration = Duration(seconds: durasi);
    String duaDigit(int n) => n.toString().padLeft(2, '0');
    final jam = duaDigit(duration.inHours);
    final menit = duaDigit(duration.inMinutes.remainder(60));
    final detik = duaDigit(duration.inSeconds.remainder(60));
    return '$jam:$menit:$detik';
  }

  /// Format jarak
  String get formattedDistance => '${jarak.toStringAsFixed(2)} km';

  /// Format tanggal lokal
  String get formattedTanggal =>
      DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(tanggal);
}
