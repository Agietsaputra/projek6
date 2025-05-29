import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:apa/app/data/api_provider.dart';
import 'package:apa/app/routes/app_pages.dart';

class ProfileController extends GetxController {
  final ApiProvider api = Get.find();
  final box = GetStorage();

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
  var userPhoto = ''.obs; // foto profil

  // Untuk dropdown gender di form edit
  var gender = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserDataFromStorage();
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

  void loadUserDataFromStorage() {
    final storedName = box.read('userName') ?? '';
    final storedPhoto = box.read('userPhoto') ?? '';
    final storedEmail = box.read('userEmail') ?? '';

    if (storedName.isNotEmpty) userName.value = storedName;
    if (storedPhoto.isNotEmpty) userPhoto.value = storedPhoto;
    if (storedEmail.isNotEmpty) userEmail.value = storedEmail;
  }

  void fetchProfile() async {
    isLoading.value = true;
    try {
      final profile = await api.getProfile();

      emailController.text = profile['email'] ?? '';
      nameController.text = profile['name'] ?? '';
      phoneController.text = profile['phone'] ?? '';
      usernameController.text = profile['username'] ?? '';

      // Update reactive vars dari API jika ada, kalau tidak pakai yang dari storage
      userEmail.value = profile['email'] ?? userEmail.value;
      userName.value = profile['name'] ?? userName.value;
      userPhone.value = profile['phone'] ?? userPhone.value;
      userUsername.value = profile['username'] ?? userUsername.value;
      userRole.value = profile['role'] ?? userRole.value;
      userGender.value = profile['gender'] ?? userGender.value;

      // Prioritaskan foto profil dari API, jika tidak ada gunakan foto dari storage (Google)
      if (profile['photo'] != null && profile['photo'].toString().isNotEmpty) {
        userPhoto.value = profile['photo'];
        // Simpan juga ke storage biar update foto tersimpan
        box.write('userPhoto', profile['photo']);
      } else {
        // Jika foto dari API tidak ada, gunakan foto yang sudah ada di storage
        if (userPhoto.value.isNotEmpty) {
          box.write('userPhoto', userPhoto.value);
        }
      }

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

      // Update reactive vars kecuali userPhoto tetap pakai yang terakhir valid (biasanya dari API)
      userName.value = name;
      userEmail.value = emailController.text.trim();
      userPhone.value = phoneController.text.trim();
      userUsername.value = usernameController.text.trim();
      userGender.value = gender.value;

      isEditMode.value = false; // kembali ke mode view
      passwordController.clear();

      // Refresh profile dari API lagi untuk mendapatkan data terbaru termasuk foto
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
      await box.erase();
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
      await box.erase();
      Get.offAllNamed(Routes.LOGIN);
    } catch (e) {
      Get.snackbar('Error', 'Gagal logout: $e');
    } finally {
      isLoading.value = false;
    }
  }

  bool validatePassword(String password) {
    final regex = RegExp(r'^(?=.*[0-9]).{6,}$');
    return regex.hasMatch(password);
  }
}
