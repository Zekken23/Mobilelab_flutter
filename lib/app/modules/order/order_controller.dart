import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geocoding/geocoding.dart';

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

  // --- TAMBAHAN BARU: DATA SEMUA LAYANAN (Slide Bar Data) ---
  final List<Map<String, String>> serviceList = [
    {"name": "Cuci Basah", "image": "assets/cucibasah.png"},
    {"name": "Cuci Kering", "image": "assets/cucikering.png"},
    {"name": "Setrika Wangi", "image": "assets/setrika.png"},
    {"name": "Cuci Sepatu", "image": "assets/sepatu.png"},
    {"name": "Cuci Tas", "image": "assets/tas.png"},
    {"name": "Cuci Helm", "image": "assets/helm.png"},
    {"name": "Cuci Spray", "image": "assets/spray.png"},
    {"name": "Cuci Boneka", "image": "assets/boneka.png"},
    {"name": "Cuci Jas/Gaun", "image": "assets/dress.png"},
    {"name": "Cuci Kiloan", "image": "assets/cucibasah.png"},
  ];

  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(seconds: 1), () => getCurrentLocation());

    if (Get.arguments != null) {
      selectedService.value = Get.arguments.toString();
    }
  }

  // --- FUNGSI MAPS TETAP SAMA ---
  Future<void> onMapTap(TapPosition tapPosition, LatLng point) async {
    _updateMarker(point);
    addressMap.value = "Lat: ${point.latitude.toStringAsFixed(5)}, Lng: ${point.longitude.toStringAsFixed(5)}";

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(point.latitude, point.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String fullAddress = "${place.street}, ${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}";
        alamatC.text = fullAddress;
      }
    } catch (e) {
      print("Gagal convert alamat: $e");
      alamatC.text = "Lokasi terpilih (Koordinat: ${point.latitude}, ${point.longitude})";
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

      LocationAccuracy accuracy = useHighAccuracy.value ? LocationAccuracy.bestForNavigation : LocationAccuracy.medium;
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: accuracy);
      LatLng point = LatLng(position.latitude, position.longitude);

      _updateMarker(point);
      mapController.move(point, currentZoom.value);
      onMapTap(TapPosition(Offset.zero, Offset.zero), point);
    } catch (e) {
      print("Error Map: $e");
    }
  }

  // --- SUBMIT ORDER TETAP SAMA ---
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
      final orderData = {
        'nama': namaC.text,
        'no_telp': noTelpC.text,
        'layanan': selectedService.value,
        'alamat': alamatC.text,
        'note': noteC.text,
        'waktu': "${selectedPickupDate.value} - ${selectedTime.value}"
      };

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

      clearForm();
      Get.off(() => const OrderSuccessView(), arguments: orderData);

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