import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import '../controllers/deteksi_controller.dart';

class DeteksiView extends GetView<DeteksiController> {
  const DeteksiView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F6F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A3F),
        title: const Text(
          'Deteksi Gerakan',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF72DEC2),
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF72DEC2)),
      ),
      body: SafeArea(
        child: Obx(() {
          if (!controller.isCameraInitialized.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // 🔲 Kamera dalam rasio portrait (3:4)
              AspectRatio(
                aspectRatio: 3 / 4,
                child: CameraPreview(controller.cameraController!),
              ),
              const SizedBox(height: 20),

              // 🧠 Prediksi Gerakan
              Text(
                'Gerakan Terdeteksi:',
                style: TextStyle(fontSize: 18, color: Colors.grey[800]),
              ),
              const SizedBox(height: 10),
              Obx(() => Text(
                    controller.predictedLabel.value.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  )),

              const Spacer(),

              // 🔘 Tombol Aksi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: controller.switchCamera,
                    icon: const Icon(Icons.cameraswitch),
                    label: const Text('Ubah Kamera'),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      final label = controller.predictedLabel.value;
                      final target =
                          controller.modelMap[controller.activeModelFile.value];
                      if (label == target) {
                        Get.back(result: true);
                      } else {
                        Get.snackbar(
                          'Deteksi Gagal',
                          'Pastikan kamu melakukan gerakan $target dengan benar.',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Selesai'),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          );
        }),
      ),
    );
  }
}
