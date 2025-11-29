import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class TestLocationController extends GetxController {
  final mapController = MapController();

  // --- DATA MODUL 5 ---
  var latitudeDisplay = "-".obs;
  var longitudeDisplay = "-".obs;
  var accuracyDisplay = "-".obs;
  var speedDisplay = "-".obs;
  var timestampDisplay = "-".obs;
  
  var currentPosition = LatLng(-7.9213, 112.5996).obs;
  var currentZoom = 15.0.obs; 
  var markers = <Marker>[].obs;
  
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

  void _updateData(Position position) {
    currentPosition.value = LatLng(position.latitude, position.longitude);
    
    latitudeDisplay.value = position.latitude.toStringAsFixed(6);
    longitudeDisplay.value = position.longitude.toStringAsFixed(6);
    accuracyDisplay.value = "${position.accuracy.toStringAsFixed(1)} m";
    speedDisplay.value = "${position.speed.toStringAsFixed(2)} m/s";
    timestampDisplay.value = DateTime.now().toString().split('.').first;

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

  Future<void> getSingleLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    LocationAccuracy accuracy = useHighAccuracy.value 
        ? LocationAccuracy.bestForNavigation 
        : LocationAccuracy.medium;

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: accuracy);
    _updateData(position);
    
    Get.snackbar("Lokasi Diupdate", "Posisi terkini berhasil diambil.", 
      snackPosition: SnackPosition.TOP, duration: Duration(seconds: 1), backgroundColor: Colors.white);
  }
  
  void toggleLiveTracking() {
    if (isLiveTracking.value) {
      stopLiveTracking();
    } else {
      startLiveTracking();
    }
  }

  void startLiveTracking() {
    isLiveTracking.value = true;
    final LocationSettings locationSettings = LocationSettings(
      accuracy: useHighAccuracy.value ? LocationAccuracy.bestForNavigation : LocationAccuracy.medium,
      distanceFilter: 2,
    );

    positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      _updateData(position);
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
    Get.snackbar("Mode", useHighAccuracy.value ? "GPS (High)" : "Network (Medium)", snackPosition: SnackPosition.TOP, duration: Duration(seconds: 1));
  }
}