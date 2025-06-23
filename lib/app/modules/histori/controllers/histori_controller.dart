import 'package:get/get.dart';
import 'package:apa/app/data/api_provider.dart';

class HistoriController extends GetxController {
  final apiProvider = ApiProvider();

  var isLoading = true.obs;
  var riwayatLari = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchRiwayatLari();
  }

  Future<void> fetchRiwayatLari() async {
    try {
      isLoading.value = true;
      final data = await apiProvider.getRiwayatLari();
      riwayatLari.value = data;
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
