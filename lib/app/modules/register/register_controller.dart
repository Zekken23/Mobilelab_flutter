import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../routes/app_pages.dart';

class RegisterController extends GetxController {
  // Text Controllers
  final namaC = TextEditingController();
  final noHpC = TextEditingController();
  final alamatC = TextEditingController();
  final emailC = TextEditingController();
  final passC = TextEditingController();

  var isLoading = false.obs;
  var isObscure = true.obs; // Untuk hide/show password

  Future<void> register() async {
    // 1. Validasi Input
    if (namaC.text.isEmpty || noHpC.text.isEmpty || alamatC.text.isEmpty || emailC.text.isEmpty || passC.text.isEmpty) {
      Get.snackbar("Error", "Semua data wajib diisi", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;

    try {
      // 2. Daftar ke Supabase Auth (Email & Password)
      final AuthResponse res = await Supabase.instance.client.auth.signUp(
        email: emailC.text,
        password: passC.text,
      );

      // 3. Jika sukses, simpan data profil ke tabel 'profiles'
      if (res.user != null) {
        await Supabase.instance.client.from('profiles').insert({
          'id': res.user!.id, // ID ini menyambungkan Auth dengan Tabel Profile
          'nama': namaC.text,
          'no_hp': noHpC.text,
          'alamat': alamatC.text,
          'email': emailC.text,
        });

        Get.snackbar("Sukses", "Akun berhasil dibuat! Silakan Login.", backgroundColor: Colors.green, colorText: Colors.white);
        
        // Redirect ke halaman Login
        Get.offAllNamed(Routes.LOGIN);
      }
    } catch (e) {
      Get.snackbar("Gagal", "Terjadi kesalahan: ${e.toString()}", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}