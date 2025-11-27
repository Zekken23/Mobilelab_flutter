import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'order_controller.dart';

class OrderView extends GetView<OrderController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pemesanan Laundry")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Form Input
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(decoration: InputDecoration(labelText: "Nama", border: OutlineInputBorder())),
                  SizedBox(height: 10),
                  TextField(decoration: InputDecoration(labelText: "No Telp", border: OutlineInputBorder())),
                ],
              ),
            ),

            // --- AREA PETA DENGAN TOMBOL ---
            Container(
              height: 300, // Sedikit lebih tinggi biar enak
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack( // Gunakan Stack untuk menumpuk tombol di atas peta
                  children: [
                    // 1. PETA UTAMA
                    Obx(() => FlutterMap(
                      mapController: controller.mapController,
                      options: MapOptions(
                        initialCenter: controller.currentPosition.value,
                        initialZoom: controller.currentZoom.value,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.yusron.rajacuci',
                        ),
                        MarkerLayer(markers: controller.markers.toList()),
                      ],
                    )),

                    // 2. TOMBOL ZOOM (Pojok Kanan Bawah)
                    Positioned(
                      bottom: 20,
                      right: 10,
                      child: Column(
                        children: [
                          FloatingActionButton.small(
                            heroTag: "zoomIn", // heroTag unik biar gak error
                            onPressed: controller.zoomIn,
                            backgroundColor: Colors.white,
                            child: const Icon(Icons.add, color: Colors.blue),
                          ),
                          const SizedBox(height: 10),
                          FloatingActionButton.small(
                            heroTag: "zoomOut",
                            onPressed: controller.zoomOut,
                            backgroundColor: Colors.white,
                            child: const Icon(Icons.remove, color: Colors.blue),
                          ),
                        ],
                      ),
                    ),

                    // 3. TOMBOL REFRESH LOKASI (Pojok Kanan Atas)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: FloatingActionButton.small(
                        heroTag: "refreshLoc",
                        onPressed: controller.getCurrentLocation,
                        backgroundColor: Colors.blueAccent,
                        child: const Icon(Icons.my_location, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Koordinat Text
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Obx(() => Text(
                controller.address.value,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              )),
            ),

            // Tombol Submit
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.blue
                ),
                onPressed: () {}, 
                child: const Text("Buat Pesanan", style: TextStyle(color: Colors.white))
              ),
            )
          ],
        ),
      ),
    );
  }
}