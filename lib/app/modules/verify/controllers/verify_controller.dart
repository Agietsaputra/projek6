import 'package:get/get.dart';
import 'package:flutter/material.dart';

class OtpVerifyController extends GetxController {
  final emailController = TextEditingController();
  final otpController = TextEditingController();

  // Contoh fungsi verify OTP (panggil API di sini)
  Future<void> verifyOtp() async {
    final email = emailController.text.trim();
    final otp = otpController.text.trim();

    if (email.isEmpty || otp.isEmpty) {
      Get.snackbar('Error', 'Email dan OTP harus diisi');
      return;
    }

    try {
      // Panggil API lewat provider, contoh:
      // final res = await apiProvider.verifyOtp(email, otp);

      // Contoh dummy sukses
      Get.snackbar('Sukses', 'OTP terverifikasi');
      Get.offAllNamed('/home'); // Ganti sesuai rute home kamu
    } catch (e) {
      Get.snackbar('Error', 'OTP tidak valid atau gagal verifikasi');
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    otpController.dispose();
    super.onClose();
  }
}
