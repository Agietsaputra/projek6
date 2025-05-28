import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apa/app/routes/app_pages.dart';
import 'package:apa/app/modules/login/bindings/login_binding.dart'; // <--- Tambahkan import ini

void main() {
  runApp(
      GetMaterialApp(
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      initialBinding: LoginBinding(), // <--- Ini WAJIB jika langsung ke /login
    ),
  );
}
