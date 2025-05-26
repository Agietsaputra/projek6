import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:apa/app/data/api_provider.dart';
import 'package:apa/app/routes/app_pages.dart';

class RegisterController extends GetxController {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController(); // Tambahkan ini

  final ApiProvider api = Get.find();

  void register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Nama, Email dan Password wajib diisi');
      return;
    }

    // Opsional: validasi email menggunakan regex sederhana
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      Get.snackbar('Error', 'Email tidak valid');
      return;
    }

    try {
      final response = await api.register(name, email, password);

      if (response.containsKey('user_id')) {
        Get.snackbar('Success', 'Registrasi berhasil, silakan login');
        Get.offNamed(Routes.LOGIN);
      } else {
        Get.snackbar('Error', response['message'] ?? 'Registrasi gagal');
      }
    } catch (e) {
      Get.snackbar('Error', 'Registrasi gagal: $e');
    }
  }
}
