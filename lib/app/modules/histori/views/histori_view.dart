import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apa/app/modules/home/controllers/home_controller.dart';

class HistoryView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: Colors.teal[50],
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text(
          "History",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: 10, // Contoh 10 riwayat
          itemBuilder: (context, index) {
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                title: Text(
                  "Warm-up Session $index",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text("Duration: 10 minutes"),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  Get.snackbar("History", "Detail riwayat sesi $index");
                },
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Menandakan halaman ini adalah History
        onTap: (index) {
          switch (index) {
            case 0:
              Get.toNamed('/home', preventDuplicates: true);
              break;
            case 1:
              Get.toNamed('/gerakan', preventDuplicates: true);
              break;
            case 2:
              Get.toNamed('/history', preventDuplicates: true);
              break;
            case 3:
              Get.toNamed('/visualisasi', preventDuplicates: true);
              break;
            case 4:
              Get.toNamed('/profile', preventDuplicates: true);
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Deteksi'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Visualisasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
