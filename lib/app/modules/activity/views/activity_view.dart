import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../controllers/activity_controller.dart';
import '../../../routes/app_pages.dart';

class ActivityView extends GetView<ActivityController> {
  const ActivityView({super.key});

  String formatDate(DateTime dateTime) {
    return DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ActivityController());
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Login'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.offNamed(Routes.PROFILE),
        ),
      ),
      body: Obx(() {
        final historyList = controller.historyList;
        final chartData = controller.chartData;

        if (historyList.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada riwayat login.',
              style: TextStyle(fontSize: 16),
            ),
          );
        }

        return Column(
          children: [
            // Chart Visualisasi Login per Hari
            SizedBox(
              height: 250,
              child: SfCartesianChart(
                title: ChartTitle(text: 'Aktivitas Login per Hari'),
                primaryXAxis: DateTimeAxis(),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries>[
                  ColumnSeries<ChartData, DateTime>(
                    dataSource: chartData,
                    xValueMapper: (data, _) => data.date,
                    yValueMapper: (data, _) => data.count,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                    name: 'Login',
                    color: Colors.blue,
                  )
                ],
              ),
            ),
            const Divider(),

            // Daftar Riwayat Login
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: historyList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = historyList[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      leading: const CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.login, color: Colors.white),
                      ),
                      title: Text(
                        item.email,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            '${item.provider} • ${formatDate(item.loginTime)}',
                            style: TextStyle(color: theme.hintColor),
                          ),
                          if (item.device.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Device: ${item.device}',
                                style: TextStyle(color: theme.hintColor),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
