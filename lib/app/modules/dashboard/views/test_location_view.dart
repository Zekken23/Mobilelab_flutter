import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/test_location_controller.dart';

class TestLocationView extends StatelessWidget {
  const TestLocationView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TestLocationController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Uji Modul 5 (Eksperimen)", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.purpleAccent,
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false, 
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. PETA FULL WIDTH
            Container(
              height: 350, // Sedikit diperbesar agar muat banyak tombol
              decoration: BoxDecoration(
                border: Border.all(color: Colors.purple.shade200, width: 2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Stack(
                  children: [
                    Obx(() => FlutterMap(
                      mapController: controller.mapController,
                      options: MapOptions(
                        initialCenter: controller.currentPosition.value,
                        initialZoom: 15.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.demo.modul5',
                        ),
                        MarkerLayer(markers: controller.markers.toList()),
                      ],
                    )),
                    
                    // PANEL KONTROL (Kanan Bawah)
                    Positioned(
                      bottom: 10, right: 10,
                      child: Column(
                        children: [
                          // Tombol Mode (GPS/Wifi)
                          Obx(() => _controlBtn(
                            controller.useHighAccuracy.value ? Icons.gps_fixed : Icons.wifi, 
                            controller.toggleMode, 
                            controller.useHighAccuracy.value ? Colors.orange : Colors.grey
                          )),
                          const SizedBox(height: 8),
                          
                          // Tombol Live Tracking (Play/Stop)
                          Obx(() => _controlBtn(
                            controller.isLiveTracking.value ? Icons.stop : Icons.play_arrow, 
                            controller.toggleLiveTracking, 
                            controller.isLiveTracking.value ? Colors.red : Colors.green
                          )),
                          const SizedBox(height: 8),
                          
                          // --- TOMBOL BARU ---
                          // Zoom In
                          _controlBtn(Icons.add, controller.zoomIn, Colors.blueAccent),
                          const SizedBox(height: 8),
                          
                          // Zoom Out
                          _controlBtn(Icons.remove, controller.zoomOut, Colors.blueAccent),
                          const SizedBox(height: 8),
                          
                          // Update Lokasi Sekarang
                          _controlBtn(Icons.my_location, controller.getSingleLocation, Colors.purple),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 2. TABEL DATA
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.purple.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Data Sensor Lokasi", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.purple)),
                  const Divider(),
                  _dataRow("Latitude", controller.latitudeDisplay),
                  _dataRow("Longitude", controller.longitudeDisplay),
                  _dataRow("Accuracy", controller.accuracyDisplay),
                  _dataRow("Speed", controller.speedDisplay),
                  _dataRow("Timestamp", controller.timestampDisplay),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dataRow(String label, RxString value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.poppins(color: Colors.black87)),
          Obx(() => Text(value.value, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black))),
        ],
      ),
    );
  }

  Widget _controlBtn(IconData icon, VoidCallback onTap, Color color) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)]),
        child: Icon(icon, color: color),
      ),
    );
  }
}