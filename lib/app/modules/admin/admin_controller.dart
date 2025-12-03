import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../routes/app_pages.dart';

class AdminController extends GetxController {
  var orders = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllOrders();
  }

  // Ambil SEMUA pesanan (Khusus Admin)
  Future<void> fetchAllOrders() async {
    isLoading.value = true;
    try {
      final response = await Supabase.instance.client
          .from('orders')
          .select()
          .order('created_at', ascending: false); // Urutkan dari yang terbaru
      
      orders.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error fetch orders: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Update Status Pesanan
  Future<void> updateStatus(int idOrder, String newStatus) async {
    try {
      await Supabase.instance.client
          .from('orders')
          .update({'status': newStatus})
          .eq('id', idOrder);
      
      // Refresh list setelah update
      await fetchAllOrders();
      Get.back(); // Tutup bottom sheet
      Get.snackbar("Sukses", "Status diubah menjadi $newStatus", backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Gagal", "Error: $e", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    Get.offAllNamed(Routes.LOGIN);
  }
}