import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apa/app/data/api_provider.dart';

class RegisterController extends GetxController {
  final ApiProvider apiProvider = Get.find<ApiProvider>();

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  var isOtpRequested = false.obs;

  // Tahap 1: Kirim data registrasi dan OTP ke backend
  Future<void> register() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar('Error', 'Semua field wajib diisi');
      return;
    }

    if (password != confirmPassword) {
      Get.snackbar('Error', 'Password dan konfirmasi tidak cocok');
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      Get.snackbar('Error', 'Email tidak valid');
      return;
    }

    if (password.length < 6) {
      Get.snackbar('Error', 'Password minimal 6 karakter');
      return;
    }

    try {
      final response = await apiProvider.register(username, email, password);
      Get.snackbar('Sukses', 'OTP telah dikirim ke email');
      isOtpRequested.value = true;
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  // Tahap 2: Verifikasi OTP
  Future<void> verifyOtpAndFinish() async {
    final email = emailController.text.trim();
    final otp = otpController.text.trim();

    if (email.isEmpty || otp.isEmpty) {
      Get.snackbar('Error', 'Email dan OTP wajib diisi');
      return;
    }

    try {
      final result = await apiProvider.verifyOtp(email, otp);
      Get.snackbar('Sukses', result['message'] ?? 'OTP terverifikasi');
      Get.offAllNamed('/login'); // navigasi ke halaman login setelah sukses
    } catch (e) {
      Get.snackbar('Error', e.toString());
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    emailController.dispose();
    otpController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
