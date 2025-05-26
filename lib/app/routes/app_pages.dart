import 'package:get/get.dart';

import 'package:apa/app/modules/home/bindings/home_binding.dart';
import 'package:apa/app/modules/home/views/home_view.dart';

import 'package:apa/app/modules/login/bindings/login_binding.dart';
import 'package:apa/app/modules/login/views/login_view.dart';

import 'package:apa/app/modules/register/bindings/register_binding.dart';
import 'package:apa/app/modules/register/views/register_view.dart';

import 'package:apa/app/modules/profile/bindings/profile_binding.dart';
import 'package:apa/app/modules/profile/views/profile_view.dart';

import 'package:apa/app/modules/histori/bindings/histori_binding.dart';
import 'package:apa/app/modules/histori/views/histori_view.dart';

import 'package:apa/app/modules/deteksi/bindings/deteksi_binding.dart';
import 'package:apa/app/modules/deteksi/views/deteksi_view.dart';
import 'package:apa/app/modules/deteksi/views/deteksi_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: Routes.PROFILE,
      page: () => ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: Routes.HISTORY,
      page: () => HistoryView(),
      binding: HistoriBinding(),
    ),
    GetPage(
      name: Routes.DETEKSI,
      page: () => DeteksiView(),
      binding: DeteksiBinding(),
    ),
  ];
}
