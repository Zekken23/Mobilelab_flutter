import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class OrderController extends GetxController {
  final mapController = MapController();
  // Koordinat Default (Misal UMM)
  var currentPosition = LatLng(-7.9213, 112.5996).obs; 
  var address = "Mencari lokasi...".obs;
  var markers = <Marker>[].obs;

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Cek GPS nyala/tidak
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar("Error", "Location services are disabled.");
      return;
    }

    // Cek Izin Lokasi
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar("Error", "Location permissions are denied");
        return;
      }
    }

    // Ambil Lokasi (High Accuracy = GPS)
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );

    // Update data state
    currentPosition.value = LatLng(position.latitude, position.longitude);
    address.value = "Lat: ${position.latitude}, Lng: ${position.longitude}";

    // Tambah Marker
    markers.clear();
    markers.add(
      Marker(
        point: currentPosition.value,
        width: 80,
        height: 80,
        child: const Icon(Icons.location_on, color: Colors.red, size: 40),
      ),
    );
    
    // Pindahkan kamera map
    mapController.move(currentPosition.value, 15);
  }
}