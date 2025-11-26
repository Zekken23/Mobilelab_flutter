
// order_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'order_controller.dart';

class OrderView extends GetView<OrderController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Pemesanan Laundry")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Form Nama, Telp, Alamat (Sesuai gambar 4)
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

            // PETA (Sesuai Modul: OpenStreetMap) 
            Container(
              height: 200,
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey)
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Obx(() => FlutterMap(
                  mapController: controller.mapController,
                  options: MapOptions(
                    initialCenter: controller.currentPosition.value,
                    initialZoom: 15.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    MarkerLayer(markers: controller.markers.toList()),
                  ],
                )),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Obx(() => Text(controller.address.value)), // Tampilkan koordinat
            ),

            // Sisa Form (Service, Berat, Tanggal)
            Padding(
              padding: EdgeInsets.all(16),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                  backgroundColor: Colors.blue
                ),
                onPressed: () {}, 
                child: Text("Buat Pesanan", style: TextStyle(color: Colors.white))
              ),
            )
          ],
        ),
      ),
    );
  }
}