import 'package:get/get.dart';

import '../modules/activity/bindings/activity_binding.dart';
import '../modules/activity/views/activity_view.dart';
import '../modules/deteksi/bindings/deteksi_binding.dart';
import '../modules/deteksi/views/deteksi_view.dart';
import '../modules/forgot_password/bindings/forgot_password_binding.dart';
import '../modules/forgot_password/views/forgot_password_view.dart';
import '../modules/gerakan/bindings/gerakan_binding.dart';
import '../modules/gerakan/views/gerakan_view.dart';
import '../modules/histori/bindings/histori_binding.dart';
import '../modules/histori/views/histori_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/reset_password/bindings/reset_password_binding.dart';
import '../modules/reset_password/views/reset_password_view.dart';
import '../modules/tutorial/bindings/tutorial_binding.dart';
import '../modules/tutorial/views/tutorial_view.dart';
import '../modules/verify/bindings/verify_binding.dart';
import '../modules/verify/views/verify_view.dart';
import '../modules/verify_otp_reset/bindings/verify_otp_reset_binding.dart';
import '../modules/verify_otp_reset/views/verify_otp_reset_view.dart';
import '../modules/visualisasi/bindings/visualisasi_binding.dart';
import '../modules/visualisasi/views/visualisasi_view.dart';

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
    GetPage(
      name: Routes.VERIFY,
      page: () => VerifyView(),
      binding: OtpVerifyBinding(),
    ),
    GetPage(
      name: Routes.FORGOT_PASSWORD,
      page: () => ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: Routes.VERIFY_RESET_OTP,
      page: () => VerifyOtpResetView(),
      binding: VerifyOtpResetBinding(),
    ),
    GetPage(
      name: Routes.RESET_PASSWORD,
      page: () => ResetPasswordView(),
      binding: ResetPasswordBinding(),
    ),
    GetPage(
      name: Routes.GERAKAN,
      page: () => const GerakanView(),
      binding: GerakanBinding(),
    ),
    GetPage(
      name: Routes.TUTORIAL,
      page: () => const TutorialView(),
      binding: TutorialBinding(),
    ),
    GetPage(
      name: Routes.ACTIVITY,
      page: () => const ActivityView(),
      binding: ActivityBinding(),
    ),
    GetPage(
      name: Routes.VISUALISASI,
      page: () => const VisualisasiView(),
      binding: VisualisasiBinding(),
    ),
  ];
}
