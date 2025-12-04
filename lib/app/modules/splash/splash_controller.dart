// splash_controller.dart
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../routes/app_pages.dart';
import '../admin/admin_view.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _checkSessionAndRole();
  }

  Future<void> _checkSessionAndRole() async {
    // Beri jeda sedikit agar logo splash terlihat (estetika)
    await Future.delayed(const Duration(seconds: 2));

    try {
      // 1. Cek apakah ada sesi login tersimpan di HP?
      final session = Supabase.instance.client.auth.currentSession;
      
      if (session == null) {
        // Jika tidak ada sesi, lempar ke Login
        Get.offAllNamed(Routes.LOGIN);
      } else {
        // 2. Jika ada sesi, CEK ROLE user tersebut di Database
        // Kita perlu request ke tabel 'profiles' untuk memastikan dia admin atau bukan
        final user = Supabase.instance.client.auth.currentUser;
        
        if (user != null) {
          final profile = await Supabase.instance.client
              .from('profiles')
              .select('role')
              .eq('id', user.id)
              .maybeSingle();
          
          String role = profile?['role'] ?? 'user';

          // 3. Arahkan sesuai Role
          if (role == 'admin') {
            // Jika Admin -> Masuk ke Admin Dashboard
            Get.offAll(() => const AdminView());
          } else {
            // Jika User Biasa -> Masuk ke User Dashboard
            Get.offAllNamed(Routes.DASHBOARD);
          }
        } else {
          // Fallback jika user null (jarang terjadi)
          Get.offAllNamed(Routes.LOGIN);
        }
      }
    } catch (e) {
      // Jika terjadi error (misal tidak ada internet saat cek role),
      // amannya lempar ke Login atau User Dashboard.
      // Di sini kita lempar ke Login agar user login ulang.
      print("Error Splash: $e");
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}