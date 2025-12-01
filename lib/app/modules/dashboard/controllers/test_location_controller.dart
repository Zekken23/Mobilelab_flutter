import 'dart:async';
import 'dart:convert'; // Tambahan untuk parsing JSON
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http; // Tambahan untuk request IP

class TestLocationController extends GetxController {
  final mapController = MapController();

  // --- DATA MODUL 5 ---
  var latitudeDisplay = "-".obs;
  var longitudeDisplay = "-".obs;
  var accuracyDisplay = "-".obs;
  var speedDisplay = "-".obs;
  var timestampDisplay = "-".obs;
  var providerType = "-".obs; 
  
  // --- STATE MAP ---
  var currentPosition = LatLng(-7.9213, 112.5996).obs;
  var currentZoom = 15.0.obs;
  var markers = <Marker>[].obs;
  
  // --- CONFIG ---
  var useHighAccuracy = true.obs;
  var isLiveTracking = false.obs;
  StreamSubscription<Position>? positionStream;

  @override
  void onInit() {
    super.onInit();
    getSingleLocation();
  }

  @override
  void onClose() {
    stopLiveTracking();
    super.onClose();
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

  // --- UPDATE UI DATA ---
  void _updateData(Position position) {
    currentPosition.value = LatLng(position.latitude, position.longitude);
    
    latitudeDisplay.value = position.latitude.toStringAsFixed(6);
    longitudeDisplay.value = position.longitude.toStringAsFixed(6);
    accuracyDisplay.value = "${position.accuracy.toStringAsFixed(1)} m";
    speedDisplay.value = "${position.speed.toStringAsFixed(2)} m/s";
    timestampDisplay.value = DateTime.now().toString().split('.').first;
    
    // Prediksi Provider
    // Jika akurasi sangat besar (misal 5000m), kemungkinan dari IP Address
    if (position.accuracy > 4000) {
      providerType.value = "Internet (IP Address)";
    } else if (position.accuracy < 20) {
      providerType.value = "GPS (Satelit)";
    } else {
      providerType.value = "Network (Wi-Fi/Seluler)";
    }

    markers.clear();
    markers.add(
      Marker(
        point: currentPosition.value,
        width: 80,
        height: 80,
        child: const Icon(Icons.accessibility_new, color: Colors.purple, size: 50),
      ),
    );

    mapController.move(currentPosition.value, currentZoom.value);
  }

  // --- FUNGSI BARU: AMBIL LOKASI DARI IP (JIKA GPS MATI) ---
  Future<void> _getLocationFromIP() async {
    try {
      Get.snackbar("GPS Mati", "Mencoba mengambil lokasi via Internet (IP Address)...", 
        backgroundColor: Colors.orange, colorText: Colors.black);

      // Gunakan API publik gratis (ip-api.com)
      final response = await http.get(Uri.parse('http://ip-api.com/json'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'fail') {
          throw Exception("Gagal deteksi IP");
        }

        // Buat 'Fake' Position object dari data API
        Position ipPosition = Position(
          longitude: (data['lon'] as num).toDouble(),
          latitude: (data['lat'] as num).toDouble(),
          timestamp: DateTime.now(),
          accuracy: 5000.0, // Akurasi IP dianggap rendah (5km)
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );

        _updateData(ipPosition);
        
        Get.snackbar("Berhasil (Mode IP)", "Lokasi didapat dari ISP: ${data['isp']}", 
          backgroundColor: Colors.blue, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar("Gagal Total", "GPS Mati & Internet Gagal. Pastikan ada koneksi internet.", 
        backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // 1. STATIS (Update Lokasi Sekarang - DIMODIFIKASI)
  Future<void> getSingleLocation() async {
    // Cek apakah Master Location di HP nyala?
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    
    // MODIFIKASI: Jika GPS Mati, Panggil Fungsi IP
    if (!serviceEnabled) {
      await _getLocationFromIP(); 
      return; 
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    // Setting Akurasi
    LocationAccuracy accuracy = useHighAccuracy.value 
        ? LocationAccuracy.best 
        : LocationAccuracy.low; 

    try {
      // Coba Last Known dulu biar cepat
      Position? lastPosition = await Geolocator.getLastKnownPosition();
      
      if (lastPosition != null && !useHighAccuracy.value) {
        _updateData(lastPosition);
        Get.snackbar("Sukses (Cache)", "Lokasi didapat dari Cache Network", backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        // Ambil posisi fresh
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: accuracy,
          timeLimit: const Duration(seconds: 10), 
        );
        _updateData(position);
        
        Get.snackbar(
          "Sukses", 
          "Lokasi didapat via: ${useHighAccuracy.value ? 'GPS' : 'Network'}",
          backgroundColor: Colors.green, colorText: Colors.white,
          duration: const Duration(seconds: 1)
        );
      }
    } catch (e) {
      Get.snackbar("Gagal", "Tidak bisa mendapat lokasi: $e", backgroundColor: Colors.red);
    }
  }

  // 2. DINAMIS (Live Stream)
  void toggleLiveTracking() {
    if (isLiveTracking.value) {
      stopLiveTracking();
    } else {
      startLiveTracking();
    }
  }

  void startLiveTracking() async {
    // Cek dulu service
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
       Get.snackbar("Error", "Live Tracking butuh GPS/Lokasi HP menyala.", backgroundColor: Colors.red, colorText: Colors.white);
       return;
    }

    isLiveTracking.value = true;
    
    final LocationSettings locationSettings = LocationSettings(
      accuracy: useHighAccuracy.value ? LocationAccuracy.bestForNavigation : LocationAccuracy.low,
      distanceFilter: 2, 
    );

    positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      _updateData(position);
    }, onError: (e) {
      print("Stream Error: $e");
    });
  }

  void stopLiveTracking() {
    positionStream?.cancel();
    positionStream = null;
    isLiveTracking.value = false;
  }

  void toggleMode() {
    useHighAccuracy.toggle();
    if (isLiveTracking.value) {
      stopLiveTracking();
      startLiveTracking();
    } else {
      getSingleLocation();
    }
    
    Get.snackbar(
      "Mode Ganti", 
      useHighAccuracy.value ? "Mode GPS (High Accuracy)" : "Mode Network (Low Accuracy)",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.black54,
      colorText: Colors.white
    );
  }
}