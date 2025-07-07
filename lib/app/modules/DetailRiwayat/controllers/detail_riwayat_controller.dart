import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

class DetailRiwayatController extends GetxController {
  late int durasi;
  late double jarak;
  late List<LatLng> rute;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;

    durasi = args['durasi'] is int ? args['durasi'] : int.tryParse('${args['durasi']}') ?? 0;
    jarak = args['jarak'] is double ? args['jarak'] : double.tryParse('${args['jarak']}') ?? 0.0;

    final rawRute = args['rute'];
    if (rawRute is List) {
      rute = rawRute.map((e) {
        final lat = e['latitude'] ?? e['lat'] ?? 0.0;
        final lng = e['longitude'] ?? e['lng'] ?? 0.0;
        return LatLng(lat, lng);
      }).toList();
    } else {
      rute = [];
    }
  }

  // Format durasi ke MM:SS
  String get formattedDuration {
    final m = (durasi ~/ 60).toString().padLeft(2, '0');
    final s = (durasi % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // Format jarak ke 2 digit desimal
  String get formattedDistance => '${jarak.toStringAsFixed(2)} km';
}
