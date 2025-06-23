import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import 'package:apa/app/routes/app_pages.dart';

class ProfileView extends GetView<ProfileController> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE1F6F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A3F),
        title: Obx(() => Text(
              controller.isEditMode.value ? 'Edit Profil' : 'Profil',
              style: const TextStyle(color: Color(0xFF72DEC2), fontWeight: FontWeight.bold),
            )),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF72DEC2)),
          onPressed: () => Get.offNamed(Routes.HOME),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF1A1A3F)));
        }

        return controller.isEditMode.value
            ? _buildEditForm(context)
            : _buildProfileView(context);
      }),
    );
  }

  Widget _buildProfileView(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Obx(() {
            final photoUrl = controller.userPhoto.value;
            return CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade300,
              backgroundImage: photoUrl.isNotEmpty
                  ? NetworkImage(photoUrl)
                  : const AssetImage('assets/images/profile.png') as ImageProvider,
            );
          }),
          const SizedBox(height: 16),
          Obx(() => Text(
                controller.userName.value,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A3F)),
              )),
          const SizedBox(height: 4),
          Obx(() => Text(
                controller.userEmail.value,
                style: const TextStyle(color: Colors.black54),
              )),
          const SizedBox(height: 30),

          _buildMenuItem(Icons.edit, 'Edit Profil', () {
            controller.nameController.text = controller.userName.value;
            controller.emailController.text = controller.userEmail.value;
            controller.phoneController.text = controller.userPhone.value;
            controller.usernameController.text = controller.userUsername.value;
            controller.gender.value = controller.userGender.value;
            controller.isEditMode.value = true;
          }),

          _buildMenuItem(Icons.history, 'Aktivitas Saya', () {
            Get.toNamed(Routes.ACTIVITY);
          }),

          _buildMenuItem(Icons.delete, 'Hapus Akun', () {
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
          }),

          const SizedBox(height: 24),

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
            icon: const Icon(Icons.logout, color: Color(0xFF72DEC2)),
            label: const Text(
              'Keluar',
              style: TextStyle(color: Color(0xFF72DEC2), fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A3F),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1A1A3F)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildEditForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            _buildInput(controller.nameController, 'Nama'),
            _buildInput(controller.usernameController, 'Username'),
            DropdownButtonFormField<String>(
              value: controller.gender.value.isEmpty ? null : controller.gender.value,
              decoration: const InputDecoration(labelText: 'Jenis Kelamin'),
              items: ['Male', 'Female']
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (value) {
                controller.gender.value = value!;
              },
            ),
            const SizedBox(height: 10),
            _buildInput(controller.phoneController, 'No. Telepon', keyboardType: TextInputType.phone),
            _buildInput(controller.emailController, 'Email'),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  controller.updateProfile();
                }
              },
              child: const Text('Simpan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A3F),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                foregroundColor: const Color(0xFF72DEC2),
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
                backgroundColor: Colors.grey,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        keyboardType: keyboardType,
        validator: (value) => value!.isEmpty ? '$label tidak boleh kosong' : null,
      ),
    );
  }
}
