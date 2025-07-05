// controllers/detail_riwayat_controller.dart
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
    durasi = args['durasi'] ?? 0;
    jarak = args['jarak'] ?? 0.0;

    rute = (args['rute'] as List)
        .map((e) => LatLng(e['latitude'], e['longitude']))
        .toList();
  }

  String get formattedDuration {
    final m = (durasi ~/ 60).toString().padLeft(2, '0');
    final s = (durasi % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String get formattedDistance => '${jarak.toStringAsFixed(2)} km';
}
