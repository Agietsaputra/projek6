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
      ),
      body: SafeArea(
        child: Obx(
          () => Column(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(20),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.exercises.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final exercise = controller.exercises[index];
                            final imageName =
                                'assets/images/${exercise.name.toLowerCase().replaceAll(' ', '_')}.png';

                            return GestureDetector(
                              onTap: () async {
                                final result = await Get.toNamed('/tutorial', arguments: exercise.name);
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
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      exercise.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    exercise.isCompleted
                                        ? Icons.check_circle
                                        : Icons.circle_outlined,
                                    color: exercise.isCompleted ? Colors.green : Colors.grey,
                                    size: 28,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1A3F),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    // Ganti snackbar dengan navigasi ke halaman mulai lari
                    Get.toNamed('/mulai-lari');
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
