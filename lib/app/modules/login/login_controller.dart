import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../routes/app_pages.dart';
import '../admin/admin_view.dart'; 

class LoginController extends GetxController {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  var isLoading = false.obs;
  var isObscure = true.obs;

  Future<void> login() async {
    // Validasi input kosong
    if (emailC.text.isEmpty || passC.text.isEmpty) {
      Get.snackbar("Error", "Email dan Password harus diisi", 
        backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;

    try {
      // 1. Proses Login Authentication
      final AuthResponse res = await Supabase.instance.client.auth.signInWithPassword(
        email: emailC.text,
        password: passC.text,
      );

      // 2. Jika Login Berhasil, Cek Role di Database
      if (res.user != null) {
        // Ambil data 'role' dari tabel profiles sesuai ID user yang login
        final profile = await Supabase.instance.client
            .from('profiles')
            .select('role')
            .eq('id', res.user!.id)
            .maybeSingle(); // Gunakan maybeSingle agar tidak error jika data belum ada
        
        // Default ke 'user' jika data null atau kolom role kosong
        String role = profile?['role'] ?? 'user';

        // 3. Arahkan Halaman Sesuai Role
        if (role == 'admin') {
          // Masuk ke Halaman Admin
          Get.offAll(() => const AdminView()); 
        } else {
          // Masuk ke Halaman User Biasa
          Get.offAllNamed(Routes.DASHBOARD); 
        }
      }
    } catch (e) {
      // Menangkap Error (Password salah / User tidak ditemukan)
      Get.snackbar(
        "Login Gagal", 
        "Email atau password salah, atau terjadi kesalahan jaringan.",
        backgroundColor: Colors.red, 
        colorText: Colors.white
      );
      print("Error Login: $e");
    } finally {
      isLoading.value = false;
    }
  }
}