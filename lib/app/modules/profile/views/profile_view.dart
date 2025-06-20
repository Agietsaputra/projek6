import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import 'package:apa/app/routes/app_pages.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileView extends GetView<ProfileController> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() =>
            Text(controller.isEditMode.value ? 'Edit Profile' : 'Profile')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.offNamed(Routes.HOME),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return controller.isEditMode.value
            ? _buildEditForm(context)
            : _buildProfileView(context);
      }),
    );
  }

  Widget _buildProfileView(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Obx(() {
          final photoUrl = controller.userPhoto.value;
          return CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: photoUrl.isNotEmpty
                ? NetworkImage(photoUrl)
                : const AssetImage('assets/images/profile.png') as ImageProvider,
          );
        }),
        const SizedBox(height: 10),
        Obx(() => Text(
              controller.userName.value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            )),
        const SizedBox(height: 4),
        Obx(() => Text(controller.userEmail.value)),
        const SizedBox(height: 30),
        ListTile(
          leading: const Icon(Icons.edit),
          title: const Text('Edit Profile'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            controller.nameController.text = controller.userName.value;
            controller.emailController.text = controller.userEmail.value;
            controller.phoneController.text = controller.userPhone.value;
            controller.usernameController.text = controller.userUsername.value;
            controller.gender.value = controller.userGender.value;
            controller.isEditMode.value = true;
          },
        ),
        ListTile(
          leading: const Icon(Icons.history),
          title: const Text('Aktivitas Saya'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Get.toNamed(Routes.ACTIVITY);
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete),
          title: const Text('Hapus Akun'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Get.defaultDialog(
              title: 'Konfirmasi',
              middleText: 'Apakah kamu yakin ingin menghapus akun?',
              textConfirm: 'Ya',
              textCancel: 'Batal',
              confirmTextColor: Colors.white,
              onConfirm: () {
                Get.back();
                controller.deleteAccount();
              },
            );
          },
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Get.defaultDialog(
                    title: 'Konfirmasi',
                    middleText: 'Apakah kamu yakin ingin keluar?',
                    textConfirm: 'Ya',
                    textCancel: 'Batal',
                    confirmTextColor: Colors.white,
                    onConfirm: () {
                      Get.back();
                      controller.logout();
                    },
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.teal,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildEditForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            TextFormField(
              controller: controller.nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) =>
                  value!.isEmpty ? 'Name cannot be empty' : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: controller.usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
              validator: (value) =>
                  value!.isEmpty ? 'Username cannot be empty' : null,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: controller.gender.value.isEmpty
                  ? null
                  : controller.gender.value,
              decoration: const InputDecoration(labelText: 'Gender'),
              items: ['Male', 'Female']
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (value) {
                controller.gender.value = value!;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: controller.phoneController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: controller.emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) =>
                  value!.isEmpty ? 'Email cannot be empty' : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  controller.updateProfile();
                }
              },
              child: const Text('Save'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.teal,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                controller.isEditMode.value = false;
              },
              icon: const Icon(Icons.cancel),
              label: const Text('Batal'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
