import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../routes/app_pages.dart';

class ProfileController extends GetxController {
  // --- VARIABEL PROFILE ---
  var nama = "Loading...".obs;
  var email = "Loading...".obs;
  var alamat = "Loading...".obs;
  
  // --- VARIABEL PESANAN (BARU) ---
  var lastOrderStatus = "Belum ada pesanan".obs;
  var lastOrderDate = "-".obs;
  var progressValue = 0.0.obs; 

  // Controller untuk Form Edit
  final editNamaC = TextEditingController();
  final editAlamatC = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
    fetchLastOrder(); // <--- Sekarang ini tidak akan error
  }

  // --- 1. AMBIL DATA PROFILE ---
  Future<void> fetchProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) {
        nama.value = data['nama'] ?? "User";
        alamat.value = data['alamat'] ?? "Belum diisi";
        email.value = data['email'] ?? user.email ?? "-";
      }
    } catch (e) {
      print("Error fetch profile: $e");
    }
  }

  // --- 2. AMBIL STATUS PESANAN TERAKHIR (INI YANG SEBELUMNYA HILANG) ---
  Future<void> fetchLastOrder() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final response = await Supabase.instance.client
          .from('orders')
          .select()
          .eq('user_id', user.id) // Filter pesanan milik user ini saja
          .order('created_at', ascending: false) // Urutkan dari yang terbaru
          .limit(1)
          .maybeSingle();

      if (response != null) {
        String status = response['status'] ?? "Sedang Dicuci";
        lastOrderStatus.value = status;
        
        // Format tanggal sederhana
        String rawDate = response['created_at'].toString();
        lastOrderDate.value = "Dibuat: ${rawDate.split('T')[0]}"; // Ambil tanggalnya saja

        // Logic Progress Bar (0.0 sampai 1.0)
        if (status == "Sedang Dicuci") {
          progressValue.value = 0.25;
        } else if (status == "Sedang Dijemur") {
          progressValue.value = 0.50;
        } else if (status == "Sedang Disetrika") {
          progressValue.value = 0.75;
        } else if (status == "Siap Diambil") {
          progressValue.value = 1.0;
        } else {
          progressValue.value = 0.1; // Default
        }
      } else {
        lastOrderStatus.value = "Belum ada pesanan";
        progressValue.value = 0.0;
      }
    } catch (e) {
      print("Error fetch order: $e");
    }
  }

  // --- 3. DIALOG EDIT PROFILE ---
  void showEditDialog() {
    editNamaC.text = nama.value;
    editAlamatC.text = alamat.value;

    Get.defaultDialog(
      title: "Edit Profile",
      contentPadding: const EdgeInsets.all(20),
      content: Column(
        children: [
          TextField(
            controller: editNamaC,
            decoration: const InputDecoration(labelText: "Nama", border: OutlineInputBorder()),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: editAlamatC,
            maxLines: 3,
            decoration: const InputDecoration(labelText: "Alamat", border: OutlineInputBorder()),
          ),
        ],
      ),
      textConfirm: "Simpan",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      buttonColor: Colors.blue,
      onConfirm: () {
        updateProfile();
        Get.back();
      },
    );
  }

  // --- 4. UPDATE DATA KE SUPABASE ---
  Future<void> updateProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      await Supabase.instance.client.from('profiles').update({
        'nama': editNamaC.text,
        'alamat': editAlamatC.text,
      }).eq('id', user.id);

      nama.value = editNamaC.text;
      alamat.value = editAlamatC.text;

      Get.snackbar("Sukses", "Profile diperbarui", backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Gagal", "Error: $e", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // --- 5. LOGOUT ---
  Future<void> logout() async {
    Get.defaultDialog(
      title: "Logout",
      middleText: "Yakin ingin keluar?",
      textConfirm: "Ya",
      textCancel: "Batal",
      onConfirm: () async {
        await Supabase.instance.client.auth.signOut();
        Get.offAllNamed(Routes.LOGIN);
      },
    );
  }
}