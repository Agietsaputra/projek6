import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apa/app/modules/home/controllers/home_controller.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.find<HomeController>();

    final List<Map<String, String>> stretches = [
      {
        "title": "Joging",
        "image": "assets/images/foto1.jpg",
        "description":
            "Joging adalah latihan kardio ringan yang bermanfaat untuk kesehatan jantung dan meningkatkan stamina."
      },
      {
        "title": "P Balap",
        "image": "assets/images/foto3.jpg",
        "description":
            "P balap adalah bentuk lari cepat yang memacu kekuatan otot dan refleks secara maksimal."
      },
      {
        "title": "P Balap",
        "image": "assets/images/foto2.jpg",
        "description":
            "Latihan ini menekankan kecepatan dan efisiensi gerak tubuh selama berlari."
      },
      {
        "title": "P Balap",
        "image": "assets/images/foto4.jpg",
        "description":
            "Baik dilakukan dalam latihan interval untuk meningkatkan daya tahan tubuh."
      },
    ];

    return Scaffold(
      backgroundColor: Colors.teal[50],
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text(
          "Stretching",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Obx(() {
                  final photo = controller.photoUrl.value;
                  return CircleAvatar(
                    radius: 40,
                    backgroundImage: photo.isNotEmpty
                        ? NetworkImage(photo)
                        : const AssetImage('assets/images/profile.png')
                            as ImageProvider,
                  );
                }),
                const SizedBox(width: 12),
                Expanded(
                  child: Obx(() => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, ${controller.name.value.isNotEmpty ? controller.name.value : 'User'}!',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          const Text(
                            "Selamat Datang Di Aplikasi Saya",
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      )),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: stretches.length,
                itemBuilder: (context, index) {
                  final stretch = stretches[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          stretch["image"]!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        stretch["title"]!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Get.to(() => StretchDetailPage(
                              title: stretch["title"]!,
                              image: stretch["image"]!,
                              description: stretch["description"]!,
                            ));
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
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

class StretchDetailPage extends StatelessWidget {
  final String title;
  final String image;
  final String description;

  const StretchDetailPage({
    Key? key,
    required this.title,
    required this.image,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Image.asset(image, height: 200, fit: BoxFit.cover),
              const SizedBox(height: 16),
              Text(
                description,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
