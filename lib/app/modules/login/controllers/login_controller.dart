import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:apa/app/data/api_provider.dart';
import 'package:apa/app/routes/app_pages.dart';

class LoginController extends GetxController {
  final identifierController = TextEditingController(); // Email atau Username
  final passwordController = TextEditingController();
  final ApiProvider api = Get.find(); // Instance ApiProvider
  final storage = const FlutterSecureStorage();

  final isLoading = false.obs;

  void login() async {
    final emailOrUsername = identifierController.text.trim();
    final password = passwordController.text.trim();

    if (emailOrUsername.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Input Tidak Lengkap',
        'Email/Username dan password wajib diisi',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    isLoading.value = true;

    try {
      // Panggil login method di ApiProvider
      final response = await api.login(emailOrUsername, password);

      if (response.containsKey('access_token')) {
        final token = response['access_token'];
        final userData = response['data'] ?? {};

        // Simpan token & data user ke storage
        await storage.write(key: 'token', value: token);
        await storage.write(key: 'user_name', value: userData['username'] ?? '');
        await storage.write(key: 'email', value: userData['email'] ?? '');

        Get.snackbar(
          'Login Berhasil',
          'Selamat datang, ${userData['username'] ?? 'pengguna'}!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );

        // Pindah ke halaman Home
        Get.offAllNamed(Routes.HOME);
      } else {
        Get.snackbar(
          'Login Gagal',
          response['message'] ?? 'Email atau password salah',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Terjadi Kesalahan',
        'Gagal login. Coba lagi. Error: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    identifierController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
