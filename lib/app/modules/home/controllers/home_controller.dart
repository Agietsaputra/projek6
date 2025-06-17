import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:apa/app/data/api_provider.dart';

class HomeController extends GetxController {
  final ApiProvider _apiProvider = Get.find();
  final box = GetStorage();

  var email = ''.obs;
  var name = ''.obs;
  var photoUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  void _loadUserData() async {
    try {
      // Coba ambil dari API (jika login manual)
      final profile = await _apiProvider.getProfile();
      if (profile.isNotEmpty) {
        email.value = profile['email'] ?? '';
        name.value = profile['name'] ?? '';
        photoUrl.value = profile['photo'] ?? '';

        // Simpan ke storage untuk fallback
        box.write('userEmail', email.value);
        box.write('name', name.value);
        box.write('photo', photoUrl.value);
        return;
      }
    } catch (e) {
      print('⚠️ Gagal ambil dari API: $e');
    }

    try {
      // Coba ambil dari Firebase (jika login Google)
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        email.value = user.email ?? '';
        name.value = user.displayName ?? '';
        photoUrl.value = user.photoURL ?? '';

        // Simpan ke storage juga
        box.write('userEmail', email.value);
        box.write('name', name.value);
        box.write('photo', photoUrl.value);
        return;
      }
    } catch (e) {
      print('⚠️ Gagal ambil dari Firebase: $e');
    }

    // Terakhir fallback dari local storage
    email.value = box.read('userEmail') ?? 'Tidak ada email';
    name.value = box.read('name') ?? 'Pengguna';
    photoUrl.value = box.read('photo') ?? '';
  }
}
