import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geocoding/geocoding.dart'; 

class OrderController extends GetxController {
  final mapController = MapController();
  
  final namaC = TextEditingController();
  final noTelpC = TextEditingController();
  final alamatC = TextEditingController(); 
  final noteC = TextEditingController(); 
  
  var currentPosition = LatLng(-7.9213, 112.5996).obs; 
  var currentZoom = 15.0.obs;
  var addressMap = "Tap peta untuk pilih lokasi".obs; 
  var markers = <Marker>[].obs;
  var isLoading = false.obs;

  var useHighAccuracy = true.obs; 

  var selectedService = "".obs;
  var selectedPickupDate = "".obs; 
  var selectedDeliveryDate = "".obs; 
  var selectedTime = "".obs; 

  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(seconds: 1), () => getCurrentLocation());
  }

  // --- FUNGSI SAAT PETA DI-TAP (BARU) ---
  Future<void> onMapTap(TapPosition tapPosition, LatLng point) async {
    // 1. Pindahkan Marker ke titik yang diklik
    _updateMarker(point);

    // 2. Isi text koordinat di bawah peta
    addressMap.value = "Lat: ${point.latitude.toStringAsFixed(5)}, Lng: ${point.longitude.toStringAsFixed(5)}";

    // 3. Cari Alamat Asli (Reverse Geocoding)
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        point.latitude, 
        point.longitude
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // Format alamat: Jalan, Kecamatan, Kota
        String fullAddress = "${place.street}, ${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}";
        
        // Update Text Field Alamat secara otomatis
        alamatC.text = fullAddress; 
      }
    } catch (e) {
      print("Gagal convert alamat: $e");
      alamatC.text = "Lokasi terpilih (Koordinat: ${point.latitude}, ${point.longitude})";
    }
  }

  // Helper untuk update marker & kamera
  void _updateMarker(LatLng point) {
    currentPosition.value = point;
    markers.clear();
    markers.add(
      Marker(
        point: point,
        width: 80,
        height: 80,
        // Icon Marker Besar & Jelas
        child: const Icon(Icons.location_on, color: Colors.red, size: 50),
      ),
    );
    // Opsional: Pindahkan kamera ke titik baru
    // mapController.move(point, currentZoom.value); 
  }

  // --- FUNGSI GPS (MODIFIKASI DIKIT) ---
  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        addressMap.value = "GPS mati";
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      LocationAccuracy accuracy = useHighAccuracy.value 
          ? LocationAccuracy.bestForNavigation 
          : LocationAccuracy.medium;

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: accuracy);
      LatLng point = LatLng(position.latitude, position.longitude);
      
      // Gunakan logika yang sama dengan Tap Map
      _updateMarker(point);
      mapController.move(point, currentZoom.value);
      
      // Ambil alamat juga saat pertama kali load
      onMapTap(TapPosition(Offset.zero, Offset.zero), point);

    } catch (e) {
      print("Error Map: $e");
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

  void toggleLocationMode() {
    useHighAccuracy.toggle();
    getCurrentLocation();
  }

  // --- SUBMIT ---
  Future<void> submitOrder() async {
    if (namaC.text.isEmpty || noTelpC.text.isEmpty || selectedService.value.isEmpty) {
      Get.snackbar("Peringatan", "Mohon lengkapi data", backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      Get.snackbar("Error", "Login dulu", backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      await Supabase.instance.client.from('orders').insert({
        'user_id': user.id,
        'nama': namaC.text,
        'no_telp': noTelpC.text,
        'alamat_lengkap': alamatC.text,
        'detail_lokasi': "${currentPosition.value.latitude}, ${currentPosition.value.longitude}",
        'layanan': selectedService.value,
        'berat_items': noteC.text,
        'tgl_ambil': selectedPickupDate.value,
        'tgl_antar': selectedDeliveryDate.value,
        'waktu_jemput': selectedTime.value,
        'status': 'Sedang Dicuci',
      });

      Get.snackbar("Sukses", "Pesanan dibuat!", backgroundColor: Colors.green, colorText: Colors.white);
      clearForm();
    } catch (e) {
      Get.snackbar("Gagal", "Error: $e", backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    namaC.clear();
    noTelpC.clear();
    alamatC.clear();
    noteC.clear();
    selectedService.value = "";
    selectedPickupDate.value = "";
    selectedDeliveryDate.value = "";
    selectedTime.value = "";
  }
}