import 'package:apa/app/data/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:apa/app/routes/app_pages.dart';
import 'package:apa/app/modules/login/bindings/login_binding.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp();
  await initializeDateFormatting('id_ID', null);
  

  // // ✅ Tambahkan ApiProvider
  // Get.put(ApiProvider());

  // // 🔍 (Opsional) Cek token di awal startup
  // await Get.find<ApiProvider>().debugStorage();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print("Build MyApp");
    return GetMaterialApp(
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      initialBinding: LoginBinding(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
