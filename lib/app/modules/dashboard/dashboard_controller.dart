import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../routes/app_pages.dart';

class DashboardController extends GetxController {
  // Contoh fungsi logout untuk tombol di dashboard
  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    Get.offAllNamed(Routes.LOGIN);
  }
}