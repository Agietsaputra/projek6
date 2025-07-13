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

    return Scaffold(
      backgroundColor: const Color(0xFFE1F6F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A3F),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF72DEC2)),
          onPressed: () => Get.offNamed(Routes.PROFILE),
        ),
        title: const Text(
          'Riwayat Login',
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
        final historyList = controller.historyList;
        final chartData = controller.chartData;

        if (historyList.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada riwayat login.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF1A1A3F),
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }

        return Column(
          children: [
            // 📊 Chart Login
            Container(
              height: 250,
              margin: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: SfCartesianChart(
                title: const ChartTitle(
                  text: '📅 Aktivitas Login per Hari',
                  textStyle: TextStyle(
                    color: Color(0xFF1A1A3F),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                primaryXAxis: DateTimeAxis(),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries>[
                  ColumnSeries<ChartData, DateTime>(
                    dataSource: chartData,
                    xValueMapper: (data, _) => data.date,
                    yValueMapper: (data, _) => data.count,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                    name: 'Login',
                    color: const Color(0xFF72DEC2),
                  )
                ],
              ),
            ),

            // 📋 Daftar Login
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: historyList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = historyList[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF1A1A3F),
                        child: Icon(Icons.login, color: Color(0xFF72DEC2)),
                      ),
                      title: Text(
                        item.email,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1A1A3F),
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            '${item.provider} • ${formatDate(item.loginTime)}',
                            style: const TextStyle(color: Colors.black54),
                          ),
                          if (item.device.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'Device: ${item.device}',
                                style: const TextStyle(color: Colors.black54),
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
