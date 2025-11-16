import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:demo3bismillah/app/data/providers/auth_provider.dart';

class AuthController extends GetxController {
  final AuthProvider authProvider = Get.find(); // Ambil AuthProvider

  final formKey = GlobalKey<FormState>();
  final emailC = TextEditingController();
  final passwordC = TextEditingController();
  final isLoading = false.obs;

  @override
  void onClose() {
    emailC.dispose();
    passwordC.dispose();
    super.onClose();
  }

  // --- FUNGSI UNTUK LOGIN ---
  Future<void> login(BuildContext context) async {
    if (!formKey.currentState!.validate()) return; // Validasi form

    isLoading.value = true;
    try {
      await authProvider.login(emailC.text, passwordC.text);
      
      // Jika berhasil, GoRouter akan otomatis redirect ke '/'
      // Kita tidak perlu panggil context.go('/') di sini
      // karena akan ditangani oleh redirect di app_routes

    } catch (e) {
      Get.snackbar('Error Login', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // --- FUNGSI UNTUK REGISTER ---
  Future<void> register(BuildContext context) async {
    if (!formKey.currentState!.validate()) return; // Validasi form

    isLoading.value = true;
    try {
      await authProvider.register(emailC.text, passwordC.text);

      Get.snackbar(
        'Registrasi Berhasil',
        'Silakan cek email Anda untuk verifikasi.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      // Kembali ke halaman login setelah register
      if (context.canPop()) context.pop(); 

    } catch (e) {
      Get.snackbar('Error Register', e.toString(),
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}