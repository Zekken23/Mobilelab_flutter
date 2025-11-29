import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderController extends GetxController {
  final mapController = MapController();
  
  // --- TEXT CONTROLLERS ---
  final namaC = TextEditingController();
  final noTelpC = TextEditingController();
  final alamatC = TextEditingController();
  final itemsC = TextEditingController(); 
  
  // --- STATE VARIABLES ---
  var currentPosition = LatLng(-7.9213, 112.5996).obs; 
  var currentZoom = 15.0.obs;
  var addressMap = "Mencari lokasi...".obs; 
  var markers = <Marker>[].obs;
  var isLoading = false.obs;

  // --- MODUL 5 FEATURES ---
  var useHighAccuracy = true.obs; // Toggle: True = GPS, False = Network

  // --- PILIHAN USER ---
  var selectedService = "".obs;
  var selectedPickupDate = "".obs; 
  var selectedDeliveryDate = "".obs; 
  var selectedTime = "".obs; 

  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(seconds: 1), () => getCurrentLocation());
  }

  // --- FUNGSI MAPS ---
  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        addressMap.value = "GPS/Lokasi dimatikan";
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      LocationAccuracy accuracy = useHighAccuracy.value 
          ? LocationAccuracy.bestForNavigation // GPS
          : LocationAccuracy.medium;           // Network

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
      );

      currentPosition.value = LatLng(position.latitude, position.longitude);
      
      String mode = useHighAccuracy.value ? "GPS" : "Network";
      addressMap.value = "Lat: ${position.latitude.toStringAsFixed(5)}, Lng: ${position.longitude.toStringAsFixed(5)} ($mode)";

      markers.clear();
      markers.add(
        Marker(
          point: currentPosition.value,
          width: 80,
          height: 80,
          child: const Icon(Icons.location_on, color: Colors.red, size: 50),
        ),
      );

      mapController.move(currentPosition.value, currentZoom.value);
    } catch (e) {
      addressMap.value = "Gagal ambil lokasi";
      print("Error: $e");
    }
  }

  // --- ZOOM CONTROLS ---
  void zoomIn() {
    if (currentZoom.value < 18) {
      currentZoom.value++;
      mapController.move(currentPosition.value, currentZoom.value);
    }
  }

  void zoomOut() {
    if (currentZoom.value > 5) {
      currentZoom.value--;
      mapController.move(currentPosition.value, currentZoom.value);
    }
  }

  void toggleLocationMode() {
    useHighAccuracy.toggle();
    getCurrentLocation();
    Get.snackbar(
      "Mode Berubah", 
      useHighAccuracy.value ? "Mode GPS Diaktifkan" : "Mode Network (Hemat Baterai)",
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 1),
      backgroundColor: Colors.black54,
      colorText: Colors.white
    );
  }

  // --- FUNGSI SUBMIT KE SUPABASE ---
  Future<void> submitOrder() async {
    // Validasi sederhana
    if (namaC.text.isEmpty || noTelpC.text.isEmpty || selectedService.value.isEmpty) {
      Get.snackbar("Error", "Mohon lengkapi Nama, No Telp, dan Pilih Service", 
        backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      await Supabase.instance.client.from('orders').insert({
        'nama': namaC.text,
        'no_telp': noTelpC.text,
        'alamat_lengkap': alamatC.text,
        'detail_lokasi': "${currentPosition.value.latitude}, ${currentPosition.value.longitude}",
        'layanan': selectedService.value,
        'berat_items': itemsC.text,
        'tgl_ambil': selectedPickupDate.value,
        'tgl_antar': selectedDeliveryDate.value,
        'waktu_jemput': selectedTime.value,
      });

      // Notifikasi Sukses
      Get.snackbar("Berhasil", "Pesanan berhasil dikirim!", 
        backgroundColor: Colors.green, colorText: Colors.white);
      
      // Reset Form
      clearForm();
      
    } catch (e) {
      Get.snackbar("Gagal", "Error: $e", 
        backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // --- RESET FORM SETELAH SUBMIT ---
  void clearForm() {
    namaC.clear();
    noTelpC.clear();
    alamatC.clear();
    itemsC.clear();
    selectedService.value = "";
    selectedPickupDate.value = "";
    selectedDeliveryDate.value = "";
    selectedTime.value = "";
    getCurrentLocation(); // Refresh lokasi
  }
}