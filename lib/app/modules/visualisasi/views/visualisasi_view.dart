import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../controllers/visualisasi_controller.dart';

class VisualisasiView extends GetView<VisualisasiController> {
  const VisualisasiView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VisualisasiController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visualisasi Artikel'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.articles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),

              // CHART PER TANGGAL
              SizedBox(
                height: 250,
                child: SfCartesianChart(
                  title: ChartTitle(text: 'Jumlah Artikel per Hari'),
                  primaryXAxis: DateTimeAxis(),
                  series: <CartesianSeries>[
                    LineSeries<ChartData, DateTime>(
                      dataSource: controller.chartPerTanggal,
                      xValueMapper: (data, _) => data.date,
                      yValueMapper: (data, _) => data.count,
                      dataLabelSettings:
                          const DataLabelSettings(isVisible: true),
                      markerSettings: const MarkerSettings(isVisible: true),
                    )
                  ],
                ),
              ),

              const Divider(),

              // CHART PER DOMAIN
              SizedBox(
                height: 250,
                child: SfCartesianChart(
                  title: ChartTitle(text: 'Jumlah Artikel per Sumber (Domain)'),
                  primaryXAxis: CategoryAxis(),
                  series: <CartesianSeries>[
                    ColumnSeries<ChartDomain, String>(
                      dataSource: controller.chartPerDomain,
                      xValueMapper: (data, _) => data.domain,
                      yValueMapper: (data, _) => data.count,
                      dataLabelSettings:
                          const DataLabelSettings(isVisible: true),
                    )
                  ],
                ),
              ),

              const Divider(),

              // LIST ARTIKEL
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.articles.length,
                itemBuilder: (context, index) {
                  final article = controller.articles[index];
                  return ListTile(
                    title: Text(article.judul),
                    subtitle: Text(DateFormat('dd MMM yyyy', 'id_ID')
                        .format(article.tanggal)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      Get.defaultDialog(
                        title: article.judul,
                        content: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(article.isi),
                        ),
                      );
                    },
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
