import 'dart:io'; // <--- WAJIB ADA: Untuk menangani File gambar
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../routes/app_pages.dart';

class ProfileController extends GetxController {
  // --- VARIABEL UI (OBSERVABLE) ---
  var nama = "Loading...".obs;
  var email = "Loading...".obs;
  var alamat = "Loading...".obs;
  var avatarUrl = "".obs; // URL Foto Profile
  
  // Variabel untuk Progress Order
  var lastOrderStatus = "Belum ada pesanan".obs;
  var lastOrderDate = "-".obs;
  var progressValue = 0.0.obs; 

  // Controller untuk Form Edit
  final editNamaC = TextEditingController();
  final editAlamatC = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Panggil fungsi ini begitu halaman dibuka
    fetchProfileData();
    fetchLastOrder();
  }

  // --- 1. AMBIL DATA PROFILE (TERMASUK FOTO) ---
  Future<void> fetchProfileData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      // Ambil data dari tabel 'profiles'
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) {
        nama.value = data['nama'] ?? "User Tanpa Nama";
        alamat.value = data['alamat'] ?? "Alamat belum diisi";
        email.value = data['email'] ?? user.email ?? "-";
        
        // --- KUNCI AGAR FOTO TIDAK HILANG ---
        // Ambil URL dari database dan masukkan ke variabel
        avatarUrl.value = data['avatar_url'] ?? ""; 
      }
    } catch (e) {
      print("Error mengambil profile: $e");
    }
  }

  // --- 2. UPLOAD FOTO KE SUPABASE ---
  Future<void> uploadAvatar() async {
    final ImagePicker picker = ImagePicker();
    // Pilih foto dari galeri
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image == null) return; // Batal pilih

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    Get.showSnackbar(const GetSnackBar(message: "Mengupload foto...", duration: Duration(seconds: 1)));

    try {
      final File file = File(image.path);
      final String fileExt = image.path.split('.').last;
      // Nama file unik berdasarkan waktu
      final String fileName = '${user.id}/${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      // 1. Upload ke Storage Bucket 'avatars'
      await Supabase.instance.client.storage
          .from('avatars')
          .upload(fileName, file);

      // 2. Dapatkan URL Publik agar bisa dilihat
      final String publicUrl = Supabase.instance.client.storage
          .from('avatars')
          .getPublicUrl(fileName);

      // 3. SIMPAN URL KE DATABASE (Agar permanen)
      await Supabase.instance.client.from('profiles').update({
        'avatar_url': publicUrl
      }).eq('id', user.id);

      // 4. Update Tampilan Aplikasi
      avatarUrl.value = publicUrl;
      
      Get.snackbar("Sukses", "Foto profil berhasil disimpan!", 
        backgroundColor: Colors.green, colorText: Colors.white);

    } catch (e) {
      Get.snackbar("Gagal", "Error upload: $e", 
        backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // --- 3. FETCH ORDER TERAKHIR (Fix Error) ---
  Future<void> fetchLastOrder() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final response = await Supabase.instance.client
          .from('orders')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        String status = response['status'] ?? "Sedang Dicuci";
        lastOrderStatus.value = status;
        
        String rawDate = response['created_at'].toString();
        lastOrderDate.value = "Dibuat: ${rawDate.split('T')[0]}";

        if (status == "Sedang Dicuci") progressValue.value = 0.25;
        else if (status == "Sedang Dijemur") progressValue.value = 0.50;
        else if (status == "Sedang Disetrika") progressValue.value = 0.75;
        else if (status == "Siap Diambil") progressValue.value = 1.0;
        else progressValue.value = 0.1;
      } 
    } catch (e) {
      print("Error order: $e");
    }
  }

  // --- 4. DIALOG EDIT PROFILE ---
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
            decoration: const InputDecoration(labelText: "Nama Lengkap", border: OutlineInputBorder()),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: editAlamatC,
            maxLines: 3,
            decoration: const InputDecoration(labelText: "Alamat Lengkap", border: OutlineInputBorder()),
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

  // --- 5. UPDATE DATA NAMA & ALAMAT ---
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

      Get.snackbar("Berhasil", "Data profil diperbarui!", backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      Get.snackbar("Gagal", "Error: $e", backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // --- 6. LOGOUT ---
  Future<void> logout() async {
    Get.defaultDialog(
      title: "Logout",
      middleText: "Yakin ingin keluar?",
      textConfirm: "Ya",
      textCancel: "Batal",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        await Supabase.instance.client.auth.signOut();
        Get.offAllNamed(Routes.LOGIN);
      },
    );
  }
}