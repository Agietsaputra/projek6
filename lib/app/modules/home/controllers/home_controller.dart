import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:apa/app/data/api_provider.dart';

class HomeController extends GetxController {
  final ApiProvider _apiProvider = Get.find();
  var email = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserEmail();
  }

  void _loadUserEmail() async {
    try {
      final profile = await _apiProvider.getProfile();
      if (profile['email'] != null && profile['email'].toString().isNotEmpty) {
        email.value = profile['email'];
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        email.value = user.email!;
        return;
      }

      final box = GetStorage();
      final storedEmail = box.read('userEmail');
      if (storedEmail != null && storedEmail.isNotEmpty) {
        email.value = storedEmail;
        return;
      }

      email.value = 'Email tidak ditemukan';
    } catch (e) {
      print('Error mengambil profil: $e');
      final box = GetStorage();
      final storedEmail = box.read('userEmail');
      if (storedEmail != null && storedEmail.isNotEmpty) {
        email.value = storedEmail;
      } else {
        email.value = 'Gagal memuat email';
      }
    }
  }
}
