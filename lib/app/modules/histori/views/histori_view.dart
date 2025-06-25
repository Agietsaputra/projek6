import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/histori_controller.dart';

class HistoriView extends GetView<HistoriController> {
  const HistoriView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F6F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A3F),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF72DEC2)),
          onPressed: () => Get.offAllNamed('/home'),
        ),
        title: const Text(
          "Riwayat Lari",
          style: TextStyle(color: Color(0xFF72DEC2), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1A1A3F)),
          );
        }

        if (controller.riwayatLari.isEmpty) {
          return const Center(
            child: Text(
              "Belum ada riwayat lari.",
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "📈 Grafik Jarak Lari (km)",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A3F),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: AspectRatio(
                  aspectRatio: 1.6,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, _) {
                              final index = value.toInt();
                              if (index >= 0 && index < controller.riwayatLari.length) {
                                final tanggal = controller.riwayatLari[index]['tanggal'] ?? '';
                                final split = tanggal.split('-');
                                return Text(
                                  split.length >= 2 ? '${split[2]}/${split[1]}' : '',
                                  style: const TextStyle(fontSize: 10, color: Color(0xFF1A1A3F)),
                                );
                              }
                              return const Text('');
                            },
                            interval: 1,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, _) => Text(
                              value.toStringAsFixed(0),
                              style: const TextStyle(fontSize: 10),
                            ),
                            reservedSize: 30,
                          ),
                        ),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: controller.riwayatLari
                              .asMap()
                              .entries
                              .map((e) => FlSpot(
                                    e.key.toDouble(),
                                    (e.value['jarak'] ?? 0).toDouble(),
                                  ))
                              .toList(),
                          isCurved: true,
                          color: const Color(0xFF72DEC2),
                          barWidth: 3,
                          belowBarData: BarAreaData(
                            show: true,
                            color: const Color(0xFF72DEC2).withOpacity(0.2),
                          ),
                          dotData: FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                "📋 Daftar Riwayat",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A3F),
                ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                itemCount: controller.riwayatLari.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final item = controller.riwayatLari[index];
                  final durasi = item['durasi']?.toString() ?? '0';
                  final jarak = (item['jarak'] ?? 0).toStringAsFixed(2);
                  final tanggal = item['tanggal'] ?? '-';

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.directions_run, color: Color(0xFF1A1A3F)),
                      title: Text(
                        "Durasi: $durasi detik",
                        style: const TextStyle(color: Colors.black87),
                      ),
                      subtitle: Text(
                        "Jarak: $jarak km",
                        style: const TextStyle(color: Colors.black54),
                      ),
                      trailing: Text(
                        tanggal,
                        style: const TextStyle(color: Color(0xFF1A1A3F), fontWeight: FontWeight.w500),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}
