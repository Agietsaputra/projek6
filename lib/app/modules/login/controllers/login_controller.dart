import 'dart:io';

import 'package:apa/app/modules/activity/controllers/activity_controller.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:apa/app/data/api_provider.dart';
import 'package:apa/app/routes/app_pages.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  final identifierController = TextEditingController(); // Email atau Username
  final passwordController = TextEditingController();
  final ApiProvider api = Get.find();
  final storage = const FlutterSecureStorage();

  final isLoading = false.obs;

  /// 🔐 Untuk toggle visibility password
  final isPasswordHidden = true.obs;
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

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

  void logActivity(String message) {
    final box = GetStorage();
    final now = DateTime.now().toIso8601String();
    final List<dynamic> activityList = box.read('activity') ?? [];

    activityList.add({
      'message': message,
      'timestamp': now,
    });

    box.write('activity', activityList);
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
        print(token);
        final userData = response['data'] ?? {};

        // ✅ Gantikan blok ini:
        if (token != null && userData is Map) {
          final username = userData['username'] ?? '';
          final email = userData['email'] ?? '';
          final name = userData['name'] ?? '';
          final photo = userData['photo'] ?? '';

          // Simpan ke storage
          await storage.write(key: 'token', value: token);
          await storage.write(key: 'user_name', value: username);
          await storage.write(key: 'email', value: email);

          final box = GetStorage();
          box.write('userName', name);
          box.write('userEmail', email);
          box.write('userUsername', username);
          box.write('userPhoto', photo);

          // ✅ Simpan juga ke SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('email', email);

          // ✅ Simpan aktivitas login
          final activityController = Get.find<ActivityController>();
          final deviceName = await getDeviceName();

          activityController.addHistory(LoginHistory(
            email: email,
            provider: 'manual',
            loginTime: DateTime.now(),
            device: deviceName,
          ));

          Get.snackbar(
            'Login Berhasil',
            'Selamat datang, ${username.isNotEmpty ? username : 'pengguna'}!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 2),
          );

          Get.offAllNamed(Routes.HOME);
        }
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

  Future<String> getDeviceName() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return '${androidInfo.manufacturer} ${androidInfo.model}';
    } else {
      return 'Unknown Device';
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
      box.write('userPhoto', googleUser.photoUrl);
      box.write('userName', googleUser.displayName ?? '');
      box.write('userEmail', googleUser.email);
      box.write('userPassword', '*'); // placeholder
      box.write('authType', 'google');
      final username = googleUser.displayName ?? 'User';
      final emailValue = googleUser.email;
      final img = googleUser.photoUrl ?? '';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('photo', googleUser.photoUrl ?? '');
      await prefs.setString('username', username);
      await prefs.setString('email', emailValue);
      await prefs.setString('img', img);

      final activityController = Get.put(ActivityController());
      final deviceName = await getDeviceName();
      activityController.addHistory(LoginHistory(
          email: emailValue,
          provider: 'google',
          loginTime: DateTime.now(),
          device: deviceName));
      final keys = prefs.getKeys();
      final prefsMap = <String, dynamic>{};
      for (String key in keys) {
        prefsMap[key] = prefs.get(key);
      }
      print('🎯 SharedPreferences: $prefsMap');
      Get.snackbar("Sukses", "Login Google berhasil");
      Get.offAllNamed(Routes.HOME);
    } catch (e) {
      Get.snackbar("Error", "Terjadi kesalahan saat login Google: $e");
    }
  }
}
