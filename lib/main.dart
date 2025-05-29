import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:apa/app/routes/app_pages.dart';
import 'package:apa/app/modules/login/bindings/login_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class AppInit extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        // Jika error
        if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(child: Text('Error saat inisialisasi Firebase: ${snapshot.error}')),
            ),
          );
        }

        // Jika sudah selesai inisialisasi
        if (snapshot.connectionState == ConnectionState.done) {
          return MyApp();
        }

        // Loading screen selama menunggu
        return MaterialApp(
          home: Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        );
      },
    );
  }
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
      // Tambahkan theme supaya yakin bukan masalah tema gelap/terang
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
