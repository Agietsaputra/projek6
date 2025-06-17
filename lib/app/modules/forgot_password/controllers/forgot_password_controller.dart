import 'package:apa/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apa/app/data/api_provider.dart'; // pastikan ini diimpor

class ForgotPasswordController extends GetxController {
  final emailController = TextEditingController();
  final isLoading = false.obs;

  final ApiProvider _apiProvider = ApiProvider(); // Gunakan ApiProvider

  Future<void> sendOtp() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      Get.snackbar("Invalid", "Email tidak boleh kosong");
      return;
    }

    if (!GetUtils.isEmail(email)) {
      Get.snackbar("Invalid", "Format email tidak valid");
      return;
    }

    isLoading.value = true;
    try {
      final result = await _apiProvider.requestOtpReset(email);
      // Navigasi ke halaman verifikasi dengan membawa email
      Get.toNamed(Routes.VERIFY_RESET_OTP, arguments: email);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
