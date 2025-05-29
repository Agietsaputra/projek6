import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:apa/app/data/api_provider.dart';
import 'package:apa/app/routes/app_pages.dart';

class ProfileController extends GetxController {
  final ApiProvider api = Get.find();
  final storage = const FlutterSecureStorage();

  // Controllers untuk form input
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final usernameController = TextEditingController();

  // Reactive variables untuk UI
  var isLoading = false.obs;
  var isEditMode = false.obs;

  var userName = ''.obs;
  var userEmail = ''.obs;
  var userRole = ''.obs;
  var userPhone = ''.obs;
  var userUsername = ''.obs;
  var userGender = ''.obs;
  var userPhoto = ''.obs; // Tambahan untuk foto profil

  // Untuk dropdown gender di form edit
  var gender = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    usernameController.dispose();
    super.onClose();
  }

  void fetchProfile() async {
    isLoading.value = true;
    try {
      final profile = await api.getProfile();

      // Assign data ke controllers dan reactive vars
      emailController.text = profile['email'] ?? '';
      nameController.text = profile['name'] ?? '';
      phoneController.text = profile['phone'] ?? '';
      usernameController.text = profile['username'] ?? '';

      userEmail.value = profile['email'] ?? '';
      userName.value = profile['name'] ?? '';
      userPhone.value = profile['phone'] ?? '';
      userUsername.value = profile['username'] ?? '';
      userRole.value = profile['role'] ?? '';
      userGender.value = profile['gender'] ?? '';
      userPhoto.value = profile['photo'] ?? ''; // Ambil URL foto profil

      gender.value = userGender.value;
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil profil: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void updateProfile() async {
    final name = nameController.text.trim();
    if (name.isEmpty) {
      Get.snackbar('Error', 'Nama tidak boleh kosong');
      return;
    }

    isLoading.value = true;

    try {
      final response = await api.updateProfile(
        email: emailController.text.trim().isEmpty
            ? null
            : emailController.text.trim(),
        password: passwordController.text.trim().isEmpty
            ? null
            : passwordController.text.trim(),
        name: name,
        phone: phoneController.text.trim(),
        username: usernameController.text.trim(),
        gender: gender.value,
      );

      Get.snackbar(
          'Success', response['message'] ?? 'Profil berhasil diperbarui');

      // Update reactive vars
      userName.value = name;
      userEmail.value = emailController.text.trim();
      userPhone.value = phoneController.text.trim();
      userUsername.value = usernameController.text.trim();
      userGender.value = gender.value;

      isEditMode.value = false; // kembali ke mode view
      passwordController.clear();

      fetchProfile();
    } catch (e) {
      Get.snackbar('Error', 'Gagal memperbarui profil: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void deleteAccount() async {
    isLoading.value = true;
    try {
      final response = await api.deleteAccount();
      await storage.deleteAll();
      Get.snackbar('Success', response['message'] ?? 'Akun berhasil dihapus');
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      Get.snackbar('Error', 'Gagal menghapus akun: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    isLoading.value = true;
    try {
      await api.logout();
      await storage.deleteAll();
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      Get.snackbar('Error', 'Gagal logout: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Contoh validasi password (minimal 6 karakter & ada angka)
  bool validatePassword(String password) {
    final regex = RegExp(r'^(?=.*[0-9]).{6,}$');
    return regex.hasMatch(password);
  }
}
