import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geocoding/geocoding.dart';

// --- IMPORT PERUBAHAN 1: Pastikan path ini sesuai dengan lokasi file OrderSuccessView kamu ---
import '../order/order_success_view.dart'; 

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

    // --- PERUBAHAN 2: Tangkap data layanan dari Dashboard ---
    if (Get.arguments != null) {
      selectedService.value = Get.arguments.toString();
    }
  }

  // --- FUNGSI SAAT PETA DI-TAP ---
  Future<void> onMapTap(TapPosition tapPosition, LatLng point) async {
    _updateMarker(point);

    addressMap.value =
        "Lat: ${point.latitude.toStringAsFixed(5)}, Lng: ${point.longitude.toStringAsFixed(5)}";

    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(point.latitude, point.longitude);

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String fullAddress =
            "${place.street}, ${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}";
        alamatC.text = fullAddress;
      }
    } catch (e) {
      print("Gagal convert alamat: $e");
      alamatC.text =
          "Lokasi terpilih (Koordinat: ${point.latitude}, ${point.longitude})";
    }
  }

  void _updateMarker(LatLng point) {
    currentPosition.value = point;
    markers.clear();
    markers.add(
      Marker(
        point: point,
        width: 80,
        height: 80,
        child: const Icon(Icons.location_on, color: Colors.red, size: 50),
      ),
    );
  }

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

      Position position =
          await Geolocator.getCurrentPosition(desiredAccuracy: accuracy);
      LatLng point = LatLng(position.latitude, position.longitude);

      _updateMarker(point);
      mapController.move(point, currentZoom.value);
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
    if (namaC.text.isEmpty ||
        noTelpC.text.isEmpty ||
        selectedService.value.isEmpty) {
      Get.snackbar("Peringatan", "Mohon lengkapi data",
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      Get.snackbar("Error", "Login dulu",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      // 1. Simpan dulu data ke variabel lokal untuk dikirim ke halaman sukses
      final orderData = {
        'nama': namaC.text,
        'no_telp': noTelpC.text,
        'layanan': selectedService.value,
        'alamat': alamatC.text,
        'note': noteC.text,
        'waktu': "${selectedPickupDate.value} - ${selectedTime.value}"
      };

      // 2. Insert ke Database Supabase
      await Supabase.instance.client.from('orders').insert({
        'user_id': user.id,
        'nama': namaC.text,
        'no_telp': noTelpC.text,
        'alamat_lengkap': alamatC.text,
        'detail_lokasi':
            "${currentPosition.value.latitude}, ${currentPosition.value.longitude}",
        'layanan': selectedService.value,
        'berat_items': noteC.text,
        'tgl_ambil': selectedPickupDate.value,
        'tgl_antar': selectedDeliveryDate.value,
        'waktu_jemput': selectedTime.value,
        'status': 'Sedang Dicuci',
      });

      // --- PERUBAHAN 3: Navigasi ke Halaman Sukses ---
      clearForm();
      Get.off(() => const OrderSuccessView(), arguments: orderData);

    } catch (e) {
      Get.snackbar("Gagal", "Error: $e",
          backgroundColor: Colors.red, colorText: Colors.white);
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