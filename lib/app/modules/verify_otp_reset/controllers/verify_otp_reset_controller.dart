import 'package:apa/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apa/app/data/api_provider.dart'; // pastikan path sesuai dengan lokasi ApiProvider-mu

class VerifyOtpResetController extends GetxController {
  final otpController = TextEditingController();
  final isLoading = false.obs;

  late String email;

  @override
  void onInit() {
    super.onInit();
    email = Get.arguments;
  }

  Future<void> verifyOtp() async {
    final otp = otpController.text.trim();
    if (otp.isEmpty) {
      Get.snackbar("Error", "OTP tidak boleh kosong");
      return;
    }

    isLoading.value = true;
    try {
      final response = await ApiProvider().verifyOtpReset(email, otp);

      // Jika berhasil, arahkan ke halaman reset password
      Get.toNamed(Routes.RESET_PASSWORD, arguments: email);
      Get.snackbar("Sukses", response['message'] ?? "OTP berhasil diverifikasi");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    otpController.dispose();
    super.onClose();
  }
}
