import 'package:apa/app/modules/gerakan/controllers/gerakan_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GerakanView extends GetView<GerakanController> {
  const GerakanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F6F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A3F),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF72DEC2)),
          onPressed: () => Get.offAllNamed('/home'),
        ),
        title: const Text(
          'Gerakan Pemanasan',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Color(0xFF72DEC2),
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF72DEC2)),
            onPressed: () {
              Get.defaultDialog(
                title: 'Reset Semua?',
                middleText: 'Yakin ingin mengulang semua gerakan?',
                textCancel: 'Batal',
                textConfirm: 'Ya',
                confirmTextColor: Colors.white,
                onConfirm: () {
                  controller.resetAll();
                  Get.back();
                },
              );
            },
          )
        ],
      ),
      body: SafeArea(
        child: Obx(
          () => Column(
            children: [
              if (controller.allCompleted)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '✅ Semua gerakan selesai!',
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListView.separated(
                    itemCount: controller.exercises.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final exercise = controller.exercises[index];
                      final imageName =
                          'assets/images/${exercise.name.toLowerCase().replaceAll(' ', '_')}.png';

                      final progress = (exercise.secondsHeld / exercise.duration)
                          .clamp(0.0, 1.0);

                      return GestureDetector(
                        onTap: () async {
                          final result = await Get.toNamed(
                            '/tutorial',
                            arguments: exercise.name,
                          );
                          if (result == true) {
                            controller.markCompleted(exercise.name);
                          }
                        },
                        child: Row(
                          children: [
                            Image.asset(
                              imageName,
                              width: 50,
                              height: 50,
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.image_not_supported),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    exercise.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 8,
                                      backgroundColor: Colors.grey.shade300,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        exercise.isCompleted
                                            ? Colors.green
                                            : const Color(0xFF72DEC2),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${exercise.secondsHeld}s / ${exercise.duration}s',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              exercise.isCompleted
                                  ? Icons.check_circle
                                  : Icons.circle_outlined,
                              color: exercise.isCompleted ? Colors.green : Colors.grey,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: controller.allCompleted
                        ? const Color(0xFF1A1A3F)
                        : Colors.grey.shade400,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: controller.allCompleted
                      ? () => Get.toNamed('/mulai-lari')
                      : () {
                          controller.cekSemuaGerakan();
                        },
                  child: const Text(
                    "Mulai Lari",
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xFF72DEC2),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
