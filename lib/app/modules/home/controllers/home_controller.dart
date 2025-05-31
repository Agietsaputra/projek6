import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:apa/app/data/api_provider.dart';

class HomeController extends GetxController {
  final ApiProvider _apiProvider = Get.find();
  var email = ''.obs;
  var photoUrl = ''.obs;

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
        // Tambahkan jika backend menyimpan URL foto
        photoUrl.value = profile['photo'] ?? '';
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        email.value = user.email ?? '';
        photoUrl.value = user.photoURL ?? '';
        return;
      }

      final box = GetStorage();
      final storedEmail = box.read('userEmail');
      final storedPhoto = box.read('photo');

      if (storedEmail != null) {
        email.value = storedEmail;
      }

      if (storedPhoto != null) {
        photoUrl.value = storedPhoto;
      }
    } catch (e) {
      print('Error mengambil profil: $e');
      final box = GetStorage();
      email.value = box.read('userEmail') ?? 'Gagal memuat email';
      photoUrl.value = box.read('photo') ?? '';
    }
  }
}
