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
        title: const Text("History", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: 10, // Menampilkan 10 riwayat (contoh)
          itemBuilder: (context, index) {
            return Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                title: Text("Warm-up Session $index",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Duration: 10 minutes"),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  Get.snackbar("History", "Detail riwayat sesi $index");
                },
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Menandakan bahwa ini adalah halaman Home
        onTap: (index) {
          if (index == 0) {
            Get.toNamed('/home',
                preventDuplicates: true); // Menambahkan preventDuplicates
          } else if (index == 1) {
            Get.toNamed('/deteksi', preventDuplicates: true);
          } else if (index == 2) {
            Get.toNamed('/history', preventDuplicates: true);
          } else if (index == 3) {
            Get.toNamed('/profile', preventDuplicates: true);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt), label: 'Deteksi'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedItemColor: Colors.blue, // Mengatur warna ikon yang dipilih
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
