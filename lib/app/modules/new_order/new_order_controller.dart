import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // <-- DIPERLUKAN
import 'package:demo3bismillah/app/modules/laundry_home/laundry_home_controller.dart';
import 'package:demo3bismillah/app/data/models/order_model.dart'; // <-- DIPERLUKAN
import 'package:demo3bismillah/app/data/services/supabase_service.dart';

// Enum untuk pilihan pembayaran
enum PaymentMethod { qris, transfer }

class NewOrderController extends GetxController {
  // GlobalKey untuk validasi Form
  final formKey = GlobalKey<FormState>();



  // --- DITAMBAHKAN --- (Variabel untuk loading)
  final RxBool isLoading = false.obs;


  // Ambil Supabase client
  late SupabaseClient client;

  // Controller untuk setiap text field
  late TextEditingController nameController;
  late TextEditingController addressController;
  late TextEditingController phoneController;

  final RxString selectedLaundryType = 'Cuci Kiloan'.obs;
  final List<String> laundryTypes = [
    'Cuci Kiloan',
    'Cuci Kering (Dry Clean)',
    'Cuci Satuan (Bed Cover/Karpet)',
    'Setrika Saja',
  ];

  // State untuk menyimpan pilihan pembayaran
  final paymentMethod = PaymentMethod.qris.obs;

  @override
  void onInit() {
    super.onInit();
    client = Get.find<SupabaseService>().client;
    nameController = TextEditingController();
    addressController = TextEditingController();
    phoneController = TextEditingController();
  }

  @override
  void onClose() {
    // Selalu dispose controller untuk menghindari memory leak
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  // --- DITAMBAHKAN --- (Fungsi untuk set Tipe Laundry)
  void setLaundryType(String? value) {
    if (value != null) {
      selectedLaundryType.value = value;
    }
  }

  // Fungsi untuk mengubah metode pembayaran
  void setPaymentMethod(PaymentMethod? value) {
    if (value != null) {
      paymentMethod.value = value;
    }
  }

  // --- DIUBAH TOTAL --- (Fungsi ini sekarang async dan terhubung ke Supabase)
  Future<void> submitOrder() async {
    // 1. Validasi form
    if (!formKey.currentState!.validate()) {
      // Jika tidak valid, tampilkan error
      Get.snackbar(
        'Gagal',
        'Harap isi semua data yang diperlukan.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return; // Stop eksekusi
    }

    // 2. Set loading
    isLoading.value = true;

    try {
      // 3. Buat objek OrderModel dari data form
      final newOrder = OrderModel(
        customerName: nameController.text,
        phone: phoneController.text,
        address: addressController.text,
        laundryType: selectedLaundryType.value,
        // Konversi enum 'qris' menjadi string "qris"
        paymentMethod: paymentMethod.value.name,
      );

      // 4. Kirim data ke tabel 'orders' di Supabase
      await client.from('orders').insert(newOrder.toJson());

      // 5. Jika berhasil, update counter lokal (jika masih dipakai)
      //    dan tampilkan snackbar sukses
      if (Get.isRegistered<LaundryHomeController>()) {
        Get.find<LaundryHomeController>().incrementProcessingOrders();
      }

      Get.snackbar(
        'Pesanan Berhasil',
        'Pesanan untuk ${nameController.text} berhasil disimpan ke Cloud.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // 6. Kembali ke halaman sebelumnya
      Get.back();

    } catch (e) {
      // 7. Jika ada error dari Supabase, tampilkan
      Get.snackbar(
        'Error Supabase',
        'Gagal menyimpan data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      // 8. Selalu matikan loading
      isLoading.value = false;
    }
  }
}