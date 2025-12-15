import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../routes/app_pages.dart';

class AdminController extends GetxController {
  var orders = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  var tabIndex = 0.obs;
  var notifications = <Map<String, dynamic>>[].obs;
  var unreadCount = 0.obs;

  // Controller untuk Input Ganti Akun
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final courierC = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchAllOrders();
    fetchNotifications();
  }

  List<Map<String, dynamic>> get activeOrders => orders.where((order) {
        String status = order['status'] ?? "";
        // Tampilkan yang BELUM selesai
        return status != "Selesai" && status != "Sampai Tujuan";
      }).toList();

  List<Map<String, dynamic>> get historyOrders => orders.where((order) {
        String status = order['status'] ?? "";
        // Tampilkan yang SUDAH selesai
        return status == "Selesai" || status == "Sampai Tujuan";
      }).toList();

  // --- FETCH ORDERS ---
  Future<void> fetchAllOrders() async {
    isLoading.value = true;
    try {
      final response = await Supabase.instance.client
          .from('orders')
          .select()
          .order('created_at', ascending: false);

      orders.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error fetch: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch All Notification
  Future<void> fetchNotifications() async {
    try {
      final response = await Supabase.instance.client
          .from('notification')
          .select()
          .order('created_at', ascending: false);
      notifications.value = List<Map<String, dynamic>>.from(response);

      unreadCount.value =
          notifications.where((n) => n['is_read'] == false).length;
    } catch (e) {
      print("Error fetch notification: $e");
    }
  }

  // --- UPDATE STATUS ---
  Future<void> updateStatus(int idOrder, String newStatus,
      {String? namaKurir}) async {
    try {
      await Supabase.instance.client
          .from('orders')
          .update({'status': newStatus}).eq('id', idOrder);

      // 🔔 SIMPAN RIWAYAT NOTIFIKASI ADMIN
      if (newStatus == "Selesai") {
        await Supabase.instance.client.from('notification').insert({
          'order_id': idOrder,
          'title': 'Pesanan Selesai 🎉',
          'is_read': false,
          'message': 'Pesanan #$idOrder telah selesai diproses',
          'type': 'order_complete',
        });
      }

      await fetchAllOrders();

      Get.snackbar("Sukses", "Status berubah: $newStatus",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Gagal", "$e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void changeTabIndex(int index) {
    tabIndex.value = index;
  }

  // --- FITUR BARU: GANTI EMAIL ---
  Future<void> updateEmail() async {
    if (emailC.text.isEmpty || !emailC.text.contains('@')) {
      Get.snackbar("Error", "Email tidak valid",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(email: emailC.text),
      );

      // Update juga di tabel profiles agar sinkron
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client
            .from('profiles')
            .update({'email': emailC.text}).eq('id', user.id);
      }

      Get.back();
      emailC.clear();
      Get.snackbar("Sukses",
          "Email berhasil diganti! Silakan cek inbox email baru untuk konfirmasi.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4));
    } catch (e) {
      Get.snackbar("Gagal", "Error: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // --- FITUR BARU: GANTI PASSWORD ---
  Future<void> updatePassword() async {
    if (passC.text.length < 6) {
      Get.snackbar("Error", "Password minimal 6 karakter",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: passC.text),
      );

      Get.back();
      passC.clear();
      Get.snackbar("Sukses", "Password berhasil diubah",
          backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Gagal", "Error: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    Get.offAllNamed(Routes.LOGIN);
  }
}
