import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/detail_riwayat_controller.dart';
import 'dart:ui' as ui;
import 'package:latlong2/latlong.dart';

class DetailRiwayatView extends GetView<DetailRiwayatController> {
  const DetailRiwayatView({super.key});

  @override
  Widget build(BuildContext context) {
    final route = controller.rute;

    return Scaffold(
      backgroundColor: const Color(0xFFE1F6F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A3F),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Detail Riwayat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.offNamed('/history'),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // === Rute dengan shadow ===
            AspectRatio(
              aspectRatio: 1.5,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.white, Color(0xFFE1F6F4)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: CustomPaint(
                  painter: RoutePainter(route),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // === Card informasi ===
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                color: Colors.white,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Column(
                    children: [
                      Text(
                        controller.formattedTanggal,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A3F),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '🕒 Waktu: ${controller.formattedDuration}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        '📏 Jarak: ${controller.formattedDistance}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// =============================
// CustomPainter: RoutePainter
// =============================
class RoutePainter extends CustomPainter {
  final List<LatLng> route;
  RoutePainter(this.route);

  @override
  void paint(Canvas canvas, Size size) {
    if (route.length < 2) return;

    const padding = 16.0;

    double minLat = route.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    double maxLat = route.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    double minLng = route.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    double maxLng = route.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

    double latRange = (maxLat - minLat).abs();
    double lngRange = (maxLng - minLng).abs();
    latRange = latRange == 0 ? 0.001 : latRange;
    lngRange = lngRange == 0 ? 0.001 : lngRange;

    final path = ui.Path();

    for (int i = 0; i < route.length; i++) {
      final lat = route[i].latitude;
      final lng = route[i].longitude;

      final dx = ((lng - minLng) / lngRange) * (size.width - 2 * padding) + padding;
      final dy = ((maxLat - lat) / latRange) * (size.height - 2 * padding) + padding;

      if (i == 0) {
        path.moveTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
      }
    }

    final paintShadow = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paintShadow);

    final paintLine = Paint()
      ..color = Colors.blue
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, paintLine);

    // Start Point (Green)
    final start = route.first;
    final startOffset = Offset(
      ((start.longitude - minLng) / lngRange) * (size.width - 2 * padding) + padding,
      ((maxLat - start.latitude) / latRange) * (size.height - 2 * padding) + padding,
    );
    canvas.drawCircle(startOffset, 6, Paint()..color = Colors.green);

    // End Point (Red)
    final end = route.last;
    final endOffset = Offset(
      ((end.longitude - minLng) / lngRange) * (size.width - 2 * padding) + padding,
      ((maxLat - end.latitude) / latRange) * (size.height - 2 * padding) + padding,
    );
    canvas.drawCircle(endOffset, 6, Paint()..color = Colors.red);
  }

  @override
  bool shouldRepaint(RoutePainter oldDelegate) {
    return oldDelegate.route != route;
  }
}