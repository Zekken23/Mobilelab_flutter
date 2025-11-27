import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../routes/app_pages.dart';

class DashboardController extends GetxController {
  // Index untuk Bottom Navigation Bar (0 = Home, 1 = Order, 2 = Profile)
  var tabIndex = 0.obs;

  // Mengganti Tab
  void changeTabIndex(int index) {
    tabIndex.value = index;
  }

  // Fungsi Log Out Supabase
  Future<void> logout() async {
    // 1. Tampilkan dialog konfirmasi (Opsional tapi UX bagus)
    Get.defaultDialog(
      title: "Logout",
      middleText: "Apakah Anda yakin ingin keluar?",
      textConfirm: "Ya, Keluar",
      textCancel: "Batal",
      confirmTextColor: Get.theme.scaffoldBackgroundColor, // Putih/Biru muda
      buttonColor: Get.theme.primaryColor,
      onConfirm: () async {
        // 2. Proses Logout Supabase
        await Supabase.instance.client.auth.signOut();
        
        // 3. Kembali ke halaman Login & hapus history page sebelumnya
        Get.offAllNamed(Routes.LOGIN); 
      },
    );
  }
}