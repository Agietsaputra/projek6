import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:apa/app/data/api_provider.dart';

class HomeController extends GetxController {
  final ApiProvider _apiProvider = Get.find();
  final _storage = const FlutterSecureStorage();
  var email = ''.obs; // Untuk menyimpan nama pengguna

  @override
  void onInit() {
    super.onInit();
    _loadUserEmail();
  }

  // Ambil nama pengguna dari storage
  void _loadUserEmail() async {
    try {
      final profile = await _apiProvider.getProfile();
      email.value = profile['email'] ?? 'Email tidak ditemukan'; // Menyimpan email dari profil
    } catch (e) {
      print('Error mengambil profil: $e');
      email.value = 'Gagal memuat email';
    }
  }
}
