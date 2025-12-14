import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../routes/app_pages.dart';

class DashboardController extends GetxController {
  var tabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    
    // --- LOGIKA MENANGKAP NAVIGASI DARI NOTIFIKASI ---
    // Jika ada arguments berupa angka (index tab), pindah ke tab tersebut.
    // Contoh: Notifikasi diklik -> kirim arguments: 2 -> Buka Tab History
    if (Get.arguments != null && Get.arguments is int) {
      tabIndex.value = Get.arguments;
    }
  }

  void changeTabIndex(int index) {
    tabIndex.value = index;
  }

  Future<void> logout() async {
    Get.defaultDialog(
      title: "Logout",
      middleText: "Apakah Anda yakin ingin keluar?",
      textConfirm: "Ya, Keluar",
      textCancel: "Batal",
      confirmTextColor: Get.theme.scaffoldBackgroundColor,
      buttonColor: Get.theme.primaryColor,
      onConfirm: () async {
        await Supabase.instance.client.auth.signOut();
        Get.offAllNamed(Routes.LOGIN); 
      },
    );
  }
}