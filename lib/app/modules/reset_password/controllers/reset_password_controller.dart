import 'package:apa/app/data/api_provider.dart';
import 'package:apa/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ResetPasswordController extends GetxController {
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final isLoading = false.obs;

  late String email;
  final _apiProvider = ApiProvider(); // gunakan api provider kamu

  @override
  void onInit() {
    super.onInit();
    email = Get.arguments;
  }

  Future<void> resetPassword() async {
    final password = passwordController.text.trim();
    final confirm = confirmController.text.trim();

    if (password.isEmpty || confirm.isEmpty) {
      Get.snackbar("Error", "Password tidak boleh kosong");
      return;
    }

    if (password.length < 6) {
      Get.snackbar("Error", "Password minimal 6 karakter");
      return;
    }

    if (password != confirm) {
      Get.snackbar("Error", "Password tidak cocok");
      return;
    }

    isLoading.value = true;
    try {
      final result = await _apiProvider.resetPassword(email, password);

      if (result['message']?.toString().toLowerCase().contains("berhasil") == true ||
          result['success'] == true) {
        Get.offAllNamed(Routes.LOGIN);
        Get.snackbar("Berhasil", "Password berhasil direset");
      } else {
        Get.snackbar("Gagal", result['message'] ?? 'Reset password gagal');
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    passwordController.dispose();
    confirmController.dispose();
    super.onClose();
  }
}
