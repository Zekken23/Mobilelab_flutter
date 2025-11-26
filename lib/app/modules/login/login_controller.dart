// login_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../routes/app_pages.dart';

class LoginController extends GetxController {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  var isLoading = false.obs;
  var isObscure = true.obs;

  Future<void> login() async {
    isLoading.value = true;
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: emailC.text,
        password: passC.text,
      );
      Get.offAllNamed(Routes.DASHBOARD);
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}

// login_view.dart
// (Bagian UI sederhana, implementasikan TextField dan Button sesuai gambar Login)
// Gunakan Obx(() => ...) untuk membungkus tombol login agar loading state terlihat.