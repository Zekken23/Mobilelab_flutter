import 'package:flutter/material.dart'; 
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// --- 1. IMPORT GEOLOCATOR & GEOCODING ---
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../../routes/app_pages.dart';
import '../order/order_controller.dart'; 

class DashboardController extends GetxController {
  var tabIndex = 0.obs;

  // --- 2. VARIABEL LOKASI ---
  var currentAddress = "Mencari lokasi...".obs; 
  var isLoadingLocation = true.obs;

  // --- SEARCH LOGIC ---
  final searchC = TextEditingController();
  var isSearching = false.obs; 
  var searchResults = <Map<String, dynamic>>[].obs; 

  // Master Data Layanan
  final List<Map<String, dynamic>> allItems = [
    {"name": "Cuci Basah", "image": "assets/cucibasah.png", "type": "Layanan"},
    {"name": "Cuci Kering", "image": "assets/cucikering.png", "type": "Layanan"},
    {"name": "Setrika Wangi", "image": "assets/setrika.png", "type": "Layanan"},
    {"name": "Cuci Sepatu", "image": "assets/sepatu.png", "type": "Layanan"},
    {"name": "Cuci Tas", "image": "assets/tas.png", "type": "Layanan"},
    {"name": "Cuci Helm", "image": "assets/helm.png", "type": "Layanan"},
    {"name": "Cuci Boneka", "image": "assets/boneka.png", "type": "Layanan"},
    // Tambahkan item lain jika perlu
  ];

  @override
  void onInit() {
    super.onInit();
    
    // --- 3. PANGGIL FUNGSI LOKASI SAAT LOAD ---
    fetchLocation();

    if (Get.arguments != null && Get.arguments is int) {
      tabIndex.value = Get.arguments;
    }
  }

  // --- 4. FUNGSI AMBIL LOKASI RINGKAS ---
  Future<void> fetchLocation() async {
    isLoadingLocation.value = true;
    try {
      // Cek apakah GPS nyala
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        currentAddress.value = "GPS Mati";
        return;
      }

      // Cek Izin Aplikasi
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          currentAddress.value = "Izin Ditolak";
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        currentAddress.value = "Izin Permanen Ditolak";
        return;
      }

      // Ambil Koordinat (Latitude, Longitude)
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Convert Koordinat jadi Alamat (Reverse Geocoding)
      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // Format Ringkas: Kecamatan, Kota (Contoh: Tegalgondo, Malang)
        currentAddress.value = "${place.subLocality}, ${place.locality}";
      } else {
        currentAddress.value = "Lokasi tidak dikenali";
      }
    } catch (e) {
      print("Error Location: $e");
      currentAddress.value = "Gagal memuat";
    } finally {
      isLoadingLocation.value = false;
    }
  }

  // --- FUNGSI SEARCH & NAVIGASI (TETAP SAMA) ---

  void runFilter(String enteredKeyword) {
    if (enteredKeyword.isEmpty) {
      isSearching.value = false;
      searchResults.clear();
    } else {
      isSearching.value = true;
      searchResults.value = allItems
          .where((item) => item["name"]
              .toString()
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }
  }

  void changeTabIndex(int index) {
    if (index != 0) {
      searchC.clear();
      isSearching.value = false;
    }
    tabIndex.value = index;
  }

  void navigateToOrder(String serviceName) {
    tabIndex.value = 1; 
    try {
      if (Get.isRegistered<OrderController>()) {
        final orderC = Get.find<OrderController>();
        orderC.clearForm(); 
        orderC.selectedService.value = serviceName;
      }
    } catch (e) {
      print("OrderController belum siap: $e");
    }
    searchC.clear();
    isSearching.value = false;
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