import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../routes/app_pages.dart';

class ProfileController extends GetxController {
  
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