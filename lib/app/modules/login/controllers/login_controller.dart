import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:apa/app/data/api_provider.dart';
import 'package:apa/app/routes/app_pages.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginController extends GetxController {
  final identifierController = TextEditingController(); // Email atau Username
  final passwordController = TextEditingController();
  final ApiProvider api = Get.find();
  final storage = const FlutterSecureStorage();

  final isLoading = false.obs;

  // Firebase Auth & Google Sign-In
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  var user = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    user.value = _auth.currentUser;
    _auth.authStateChanges().listen((User? u) {
      user.value = u;
    });
  }

  /// Login via API biasa
  Future<void> login() async {
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
      final response = await api.login(emailOrUsername, password);

      if (response.containsKey('access_token')) {
        final token = response['access_token'];
        final userData = response['data'] ?? {};

        // Simpan token & user data ke FlutterSecureStorage
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

  /// Login dengan Google Sign-In
  Future<void> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut(); // Optional: logout sebelumnya
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        Get.snackbar("Login Dibatalkan", "Pengguna membatalkan login Google.");
        return;
      }

      // Firebase Auth credential dengan Google
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
      user.value = _auth.currentUser;

      // Simpan data ke GetStorage
      final box = GetStorage();
      box.write('userName', googleUser.displayName ?? '');
      box.write('userEmail', googleUser.email);
      box.write('userPassword', '*'); // placeholder
      box.write('authType', 'google');

      Get.snackbar("Sukses", "Login Google berhasil");
      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan saat login Google: $e");
    }
  }
}
