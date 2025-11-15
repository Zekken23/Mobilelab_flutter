import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';

class LaundryHomeController extends GetxController {
  // Koordinat UMM sebagai pusat peta
  final LatLng ummLocation = const LatLng(-7.9239, 112.5997);

  // Daftar penanda (marker) di peta
  final RxList<Marker> markers = <Marker>[].obs;

  final processingOrders = 3.obs;
  
  void incrementProcessingOrders() {
    processingOrders.value++;
  }

  @override
  void onInit() {
    super.onInit();
    // Tambahkan marker saat controller diinisialisasi
    loadMarkers();
  }

  void loadMarkers() {
    markers.add(
      Marker(
        point: ummLocation,
        width: 80,
        height: 80,
        child: const Tooltip(
          message: "Raja Laundry",
          child: Icon(Icons.location_pin, color: Colors.blue, size: 40),
        ),
      ),
    );
    markers.add(
      Marker(
        point: const LatLng(-7.9250, 112.6020), // Lokasi dummy order
        width: 80,
        height: 80,
        child: const Tooltip(
          message: "Pesanan #1023",
          child: Icon(Icons.local_laundry_service, color: Colors.green, size: 30),
        ),
      ),
    );
  }
}