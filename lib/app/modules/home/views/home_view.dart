import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:apa/app/modules/home/controllers/home_controller.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: const Color(0xFFE1F6F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A3F),
        centerTitle: true,
        elevation: 0,
        title: SizedBox(
          height: 40,
          child: Image.asset(
            'assets/images/aset.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Obx(() {
            final name = controller.name.value.isNotEmpty ? controller.name.value : 'User';
            final lastRun = controller.lastRun.value;
            final totalKm = controller.totalDistanceThisWeek.value;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Halo, $name 👋",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A3F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Sudah siap untuk stretching & lari hari ini?",
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "📊 Ringkasan Aktivitas",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A3F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  summaryRow(
                    "Lari Terakhir",
                    lastRun != null
                        ? "🕒 ${lastRun['durasi']?.toString() ?? '0'} menit - ${(lastRun['jarak'] ?? 0.0).toStringAsFixed(2)} KM"
                        : "Belum ada",
                  ),
                  summaryRow("Total Minggu Ini", "🏃‍♂️ ${totalKm.toStringAsFixed(2)} KM"),
                  const SizedBox(height: 24),
                  const Text(
                    "📈 Grafik Mingguan",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A3F),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
                      ],
                    ),
                    child: Obx(() {
                      final data = controller.chartData;
                      final days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

                      return BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          barGroups: days.asMap().entries.map((entry) {
                            final index = entry.key;
                            final value = data[entry.value] ?? 0.0;
                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: value,
                                  color: const Color(0xFF72DEC2),
                                  width: 14,
                                  borderRadius: BorderRadius.circular(4),
                                )
                              ],
                            );
                          }).toList(),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final index = value.toInt();
                                  if (index >= 0 && index < days.length) {
                                    return Text(
                                      days[index],
                                      style: const TextStyle(fontSize: 10, color: Color(0xFF1A1A3F)),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                getTitlesWidget: (value, _) => Text(
                                  value.toString(),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                            ),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(show: true),
                          borderData: FlBorderData(show: false),
                          barTouchData: BarTouchData(enabled: true),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A1A3F),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.replay, color: Color(0xFF72DEC2)),
                          label: const Text(
                            "Mulai Stretching",
                            style: TextStyle(color: Color(0xFF72DEC2), fontWeight: FontWeight.bold),
                          ),
                          onPressed: () => Get.toNamed('/gerakan'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A1A3F),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.directions_run, color: Color(0xFF72DEC2)),
                          label: const Text(
                            "Mulai Lari",
                            style: TextStyle(color: Color(0xFF72DEC2), fontWeight: FontWeight.bold),
                          ),
                          onPressed: () => Get.toNamed('/mulai-lari'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    "💡 Tips Hari Ini:",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A3F),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: const Text(
                      "“Stretching sebelum lari bantu mencegah cedera!”",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    "📰 Artikel Terkini",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A3F),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Obx(() {
                    final articles = controller.articles;
                    if (articles.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text("Tidak ada artikel tersedia."),
                      );
                    }

                    return ListView.builder(
                      itemCount: articles.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final article = articles[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                          ),
                          child: ListTile(
                            leading: const Icon(Icons.article_outlined, color: Color(0xFF1A1A3F)),
                            title: Text(
                              article.judul,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              DateFormat('dd MMM yyyy', 'id_ID').format(article.tanggal),
                              style: const TextStyle(color: Colors.black54),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                            onTap: () {
                              Get.defaultDialog(
                                title: article.judul,
                                content: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(article.isi),
                                ),
                                radius: 12,
                                titleStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A3F),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  }),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1A1A3F),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          switch (index) {
            case 0:
              Get.offAllNamed('/home');
              break;
            case 1:
              Get.offAllNamed('/gerakan');
              break;
            case 2:
              Get.offAllNamed('/history');
              break;
            case 3:
              Get.offAllNamed('/visualisasi');
              break;
            case 4:
              Get.offAllNamed('/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Deteksi'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Visualisasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget summaryRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 15, color: Color(0xFF1A1A3F)),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
