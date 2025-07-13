import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../controllers/visualisasi_controller.dart';

class VisualisasiView extends GetView<VisualisasiController> {
  const VisualisasiView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VisualisasiController());

    return Scaffold(
      backgroundColor: const Color(0xFFE1F6F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A3F),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF72DEC2)),
          onPressed: () => Get.offAllNamed('/home'),
        ),
        title: const Text(
          'Visualisasi Artikel',
          style: TextStyle(
            color: Color(0xFF72DEC2),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.articles.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF1A1A3F)));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // 📅 CHART PER TANGGAL
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                ),
                height: 280,
                child: SfCartesianChart(
                  title: const ChartTitle(
                    text: '📅 Jumlah Artikel per Hari',
                    textStyle: TextStyle(
                      color: Color(0xFF1A1A3F),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  primaryXAxis: DateTimeAxis(),
                  series: <CartesianSeries>[
                    LineSeries<ChartData, DateTime>(
                      dataSource: controller.chartPerTanggal,
                      xValueMapper: (data, _) => data.date,
                      yValueMapper: (data, _) => data.count,
                      color: const Color(0xFF72DEC2),
                      dataLabelSettings: const DataLabelSettings(isVisible: true),
                      markerSettings: const MarkerSettings(isVisible: true),
                    )
                  ],
                ),
              ),

              // 🌐 CHART PER DOMAIN
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                ),
                height: 280,
                child: SfCartesianChart(
                  title: const ChartTitle(
                    text: '🌐 Artikel per Sumber Domain',
                    textStyle: TextStyle(
                      color: Color(0xFF1A1A3F),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  primaryXAxis: CategoryAxis(),
                  series: <CartesianSeries>[
                    ColumnSeries<ChartDomain, String>(
                      dataSource: controller.chartPerDomain,
                      xValueMapper: (data, _) => data.domain,
                      yValueMapper: (data, _) => data.count,
                      color: const Color(0xFF72DEC2),
                      dataLabelSettings: const DataLabelSettings(isVisible: true),
                    )
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
