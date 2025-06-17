import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/register_controller.dart';
import '../../../routes/app_pages.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A3F), // Warna utama sama seperti login
      body: SafeArea(
        child: Stack(
          children: [
            // Logo
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

            // Form scrollable
            SingleChildScrollView(
              padding: const EdgeInsets.only(top: 330, bottom: 24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFE1F6F4), // Sama dengan login
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Hello...",
                        style: TextStyle(fontSize: 18, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Register",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Username
                      TextField(
                        controller: controller.usernameController,
                        decoration: _inputDecoration("Username", Icons.person),
                      ),
                      const SizedBox(height: 16),

                      // Email
                      TextField(
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration("Email", Icons.email),
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextField(
                        controller: controller.passwordController,
                        obscureText: true,
                        decoration: _inputDecoration("Password", Icons.lock),
                      ),
                      const SizedBox(height: 16),

                      // Confirm Password
                      TextField(
                        controller: controller.confirmPasswordController,
                        obscureText: true,
                        decoration: _inputDecoration("Confirm Password", Icons.lock_outline),
                      ),
                      const SizedBox(height: 24),

                      // Tombol Register
                      ElevatedButton(
                        onPressed: controller.isOtpRequested.value ? null : controller.register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A1A3F),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          controller.isOtpRequested.value ? 'OTP Terkirim' : 'Register',
                          style: const TextStyle(
                            color: Color(0xFF72DEC2),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // OTP Verification
                      if (controller.isOtpRequested.value) ...[
                        TextField(
                          controller: controller.otpController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration("Kode OTP", Icons.verified),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: controller.verifyOtpAndFinish,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A1A3F),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            "Verifikasi OTP",
                            style: TextStyle(
                              color: Color(0xFF72DEC2),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Login Link
                      Center(
                        child: TextButton(
                          onPressed: () => Get.toNamed(Routes.LOGIN),
                          child: const Text.rich(
                            TextSpan(
                              text: "Already have an account? ",
                              children: [
                                TextSpan(
                                  text: "Login",
                                  style: TextStyle(
                                    color: Color(0xFF00798C),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
}
