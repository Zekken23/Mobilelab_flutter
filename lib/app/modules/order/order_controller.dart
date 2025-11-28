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
  final itemsC = TextEditingController(); // Untuk list pakaian
  
  // --- STATE VARIABLES ---
  var currentPosition = LatLng(-7.9213, 112.5996).obs; 
  var currentZoom = 15.0.obs;
  var addressMap = "Mencari lokasi...".obs;
  var markers = <Marker>[].obs;
  
  var isLoading = false.obs;

  // Pilihan User
  var selectedService = "".obs;
  var selectedPickupDate = "".obs;
  var selectedDeliveryDate = "".obs;
  var selectedTime = "".obs;

  @override
  void onInit() {
    super.onInit();
    // Delay sedikit agar map siap
    Future.delayed(const Duration(seconds: 1), () => getCurrentLocation());
  }

  // --- FUNGSI MAPS (SAMA SEPERTI SEBELUMNYA) ---
  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      currentPosition.value = LatLng(position.latitude, position.longitude);
      addressMap.value = "Lat: ${position.latitude}, Lng: ${position.longitude}";

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
      Get.snackbar("Info", "Gagal memuat lokasi: $e");
    }
  }

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

  // --- FUNGSI SUBMIT KE SUPABASE ---
  Future<void> submitOrder() async {
    if (namaC.text.isEmpty || noTelpC.text.isEmpty || selectedService.value.isEmpty) {
      Get.snackbar("Error", "Mohon lengkapi Nama, No Telp, dan Pilih Service");
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

      Get.snackbar("Sukses", "Pesanan berhasil dibuat!");
      Get.back(); // Kembali ke dashboard
    } catch (e) {
      Get.snackbar("Error", "Gagal membuat pesanan: $e");
    } finally {
      isLoading.value = false;
    }
  }
}