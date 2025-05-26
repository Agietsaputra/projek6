import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:apa/app/modules/register/controllers/register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 250,
              decoration: const BoxDecoration(
                color: Colors.teal,
                borderRadius:
                    BorderRadius.vertical(bottom: Radius.circular(40)),
              ),
              child: SafeArea(
                child: Row(
                  children: const [
                    SizedBox(width: 16),
                    Icon(Icons.person_add, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Text("Sign Up",
                        style: TextStyle(fontSize: 28, color: Colors.white)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Tambah input Nama
                  TextField(
                    controller: controller.nameController,
                    decoration: const InputDecoration(labelText: "Nama"),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller.emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller.passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Password"),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller.confirmPasswordController,
                    obscureText: true,
                    decoration:
                        const InputDecoration(labelText: "Confirm Password"),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (controller.passwordController.text !=
                          controller.confirmPasswordController.text) {
                        Get.snackbar(
                            "Error", "Password dan konfirmasi tidak cocok");
                      } else {
                        controller.register();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.teal,
                    ),
                    child: const Text("Sign Up",
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
