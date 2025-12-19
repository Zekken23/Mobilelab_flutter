import 'package:flutter/material.dart'; // Tambahkan ini untuk Colors di snackbar
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HistoryController extends GetxController {
  var myOrders = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyOrders();
  }

  Future<void> fetchMyOrders() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    isLoading.value = true;
    try {
      final response = await Supabase.instance.client
          .from('orders')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      
      myOrders.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error fetch history: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- FUNGSI HAPUS HISTORY (BARU) ---
  Future<void> deleteOrder(int idOrder) async {
    try {
      // 1. Hapus dari database Supabase
      await Supabase.instance.client
          .from('orders')
          .delete()
          .eq('id', idOrder); // Pastikan nama kolom ID di tabelmu adalah 'id'

      // 2. Hapus dari list lokal (biar UI langsung update tanpa loading ulang)
      myOrders.removeWhere((order) => order['id'] == idOrder);

      Get.snackbar(
        "Berhasil", 
        "Riwayat pesanan dihapus",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(10),
      );
    } catch (e) {
      Get.snackbar(
        "Gagal", 
        "Terjadi kesalahan: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}