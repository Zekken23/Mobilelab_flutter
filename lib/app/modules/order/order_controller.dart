import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class OrderController extends GetxController {
  final mapController = MapController();
  
  // Koordinat Default (Kampus UMM)
  final defaultLocation = LatLng(-7.9213, 112.5996);

  var currentPosition = LatLng(-7.9213, 112.5996).obs;
  var currentZoom = 15.0.obs;
  var address = "Siap mencari lokasi...".obs;
  var markers = <Marker>[].obs;

  @override
  void onInit() {
    super.onInit();
    Future.delayed(Duration(seconds: 1), () => getCurrentLocation());
  }

  Future<void> getCurrentLocation() async {
    address.value = "Sedang mencari sinyal GPS...";
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        address.value = "GPS mati. Menggunakan lokasi default.";
        _useDefaultLocation();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          address.value = "Izin ditolak. Menggunakan lokasi default.";
          _useDefaultLocation();
          return;
        }
      }

      // --- PERBAIKAN UTAMA: Tambahkan timeLimit ---
      // Jika 10 detik tidak dapat lokasi, batalkan dan pakai default
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10), 
      );

      _updatePosition(position.latitude, position.longitude);

    } catch (e) {
      // Jika Timeout atau Error lain
      print("Error Location: $e");
      address.value = "Sinyal lemah/Timeout. Menggunakan lokasi default.";
      Get.snackbar("Info", "Gagal mendapat lokasi akurat, menggunakan lokasi default.");
      _useDefaultLocation();
    }
  }

  void _useDefaultLocation() {
    _updatePosition(defaultLocation.latitude, defaultLocation.longitude);
  }

  void _updatePosition(double lat, double long) {
    currentPosition.value = LatLng(lat, long);
    address.value = "Lat: $lat, Lng: $long";

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
}