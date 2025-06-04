import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';

import '../controllers/deteksi_controller.dart';

class DeteksiView extends GetView<DeteksiController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pose Detection'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Pilih Model:', style: TextStyle(fontSize: 18)),
            Obx(() {
              return DropdownButton<String>(
                hint: Text('Pilih model'),
                value: controller.activeModelFile.value == '' ? null : controller.activeModelFile.value,
                items: controller.modelMap.entries
                    .map(
                      (e) => DropdownMenuItem<String>(
                        value: e.key,
                        child: Text(e.value),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) controller.activeModelFile(val);
                },
              );
            }),
            SizedBox(height: 16),

            Obx(() {
              if (controller.activeModelFile.value == '') {
                return Text('Silakan pilih model dulu');
              }
              return ElevatedButton(
                onPressed: () {
                  if (!controller.isCameraInitialized.value) {
                    controller.startCamera();
                  } else {
                    controller.stopCamera();
                  }
                },
                child: Text(
                  controller.isCameraInitialized.value ? 'Stop Kamera' : 'Mulai Kamera',
                ),
              );
            }),

            SizedBox(height: 20),

            Obx(() => Text(
                  'Hasil prediksi: ${controller.predictedLabel.value}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )),

            SizedBox(height: 20),

            Obx(() {
              if (!controller.isCameraInitialized.value) {
                return Text('Kamera belum aktif');
              }
              if (controller.cameraController == null ||
                  !controller.cameraController!.value.isInitialized) {
                return Text('Loading kamera...');
              }
              return AspectRatio(
                aspectRatio: controller.cameraController!.value.aspectRatio,
                child: CameraPreview(controller.cameraController!),
              );
            }),
          ],
        ),
      ),
    );
  }
}
