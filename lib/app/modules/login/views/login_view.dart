import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import '../../../routes/app_pages.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A3F), // Ungu tua (background dominan)
      body: SafeArea(
        child: Stack(
          children: [
            // Logo tetap
            Positioned(
              top: 30,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/images/logo3.png',
                height: 280,
                fit: BoxFit.contain,
              ),
            ),

            // Konten scroll
            SingleChildScrollView(
              padding: const EdgeInsets.only(top: 320, bottom: 24),
              child: Container(
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFE1F6F4), // Biru kehijauan terang (kontainer)
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Welcome Back!!!",
                      style: TextStyle(fontSize: 18, color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Login",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Email
                    TextField(
                      controller: controller.identifierController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecoration("Email", Icons.email),
                    ),
                    const SizedBox(height: 16),

                    // Password
                    Obx(() => TextField(
                          controller: controller.passwordController,
                          obscureText: controller.isPasswordHidden.value,
                          decoration: _inputDecorationPassword(
                            "Password",
                            Icons.lock,
                            controller.isPasswordHidden.value,
                            () => controller.isPasswordHidden.toggle(),
                          ),
                        )),
                    const SizedBox(height: 10),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Get.toNamed(Routes.FORGOT_PASSWORD),
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1A1A3F),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Tombol Login
                    Obx(() => SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1A1A3F),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: controller.isLoading.value
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  )
                                : const Text(
                                    "Login",
                                    style: TextStyle(
                                      color: Color(0xFF72DEC2),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        )),
                    const SizedBox(height: 24),

                    // Google Login
                    const Center(
                      child: Text(
                        "Or login with",
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.g_mobiledata,
                              color: Colors.red, size: 40),
                          onPressed: controller.signInWithGoogle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Register
                    Center(
                      child: TextButton(
                        onPressed: () => Get.toNamed(Routes.REGISTER),
                        child: const Text.rich(
                          TextSpan(
                            text: "Don’t have an account? ",
                            children: [
                              TextSpan(
                                text: "Register",
                                style: TextStyle(
                                  color: Color(0xFF00798C),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Color(0xFF1A1A3F)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  InputDecoration _inputDecorationPassword(
    String label,
    IconData icon,
    bool isHidden,
    VoidCallback toggleVisibility,
  ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Color(0xFF1A1A3F)),
      suffixIcon: IconButton(
        icon: Icon(
          isHidden ? Icons.visibility_off : Icons.visibility,
          color: Color(0xFF1A1A3F),
        ),
        onPressed: toggleVisibility,
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}
