import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'order_controller.dart';

class OrderView extends GetView<OrderController> {
  const OrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Pemesanan Laundry",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.cyanAccent.shade400,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. INPUT FIELDS
            _buildTextField("Nama", controller.namaC),
            const SizedBox(height: 12),
            _buildTextField("No Telp", controller.noTelpC, isNumber: true),
            const SizedBox(height: 12),
            _buildTextField("Alamat Lengkap", controller.alamatC),

            const SizedBox(height: 20),

            // 2. PETA (MAP)
            Container(
              height: 220, // Agak tinggi biar tombol muat
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  children: [
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
                    
                    // TOMBOL KONTROL (Kanan Bawah)
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Column(
                        children: [
                          // Tombol Toggle GPS/Network
                          Obx(() => _mapButton(
                            controller.useHighAccuracy.value ? Icons.gps_fixed : Icons.wifi, 
                            controller.toggleLocationMode,
                            color: controller.useHighAccuracy.value ? Colors.blue : Colors.orange,
                          )),
                          const SizedBox(height: 8),
                          // Tombol Zoom In
                          _mapButton(Icons.add, controller.zoomIn),
                          const SizedBox(height: 8),
                          // Tombol Zoom Out
                          _mapButton(Icons.remove, controller.zoomOut),
                          const SizedBox(height: 8),
                          // Tombol Refresh Lokasi
                          _mapButton(Icons.my_location, controller.getCurrentLocation),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // KOORDINAT DI BAWAH PETA
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 4),
              child: Obx(() => Text(
                "Koordinat: ${controller.addressMap.value}",
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
              )),
            ),

            const SizedBox(height: 25),

            // 3. PILIH SERVICE, DATE, DLL (Kode UI lainnya tetap sama)
            _buildSectionTitle("Pilih Service"),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildServiceCard("Cuci Basah", Icons.local_laundry_service),
                _buildServiceCard("Cuci Kering", Icons.dry_cleaning),
                _buildServiceCard("Setrika Wangi", Icons.iron),
              ],
            ),
            
            // ... (Lanjutkan sisa kode UI seperti TextField items, Chips Tanggal, Tombol Submit)
             const SizedBox(height: 25),
            _buildSectionTitle("Berat Perkiraan"),
            const SizedBox(height: 12),
            TextField(
              controller: controller.itemsC,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "List pakaian...",
                hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 13),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blue)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blue.shade200)),
              ),
            ),
            const SizedBox(height: 20),
            
            // TOMBOL SUBMIT
            SizedBox(
              width: double.infinity,
              height: 55,
              child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.submitOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E64D8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("Buat Pesanan", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              )),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _mapButton(IconData icon, VoidCallback onTap, {Color color = Colors.blueAccent}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }

  // Helper lainnya ( _buildTextField, _buildSectionTitle, _buildServiceCard, dll) 
  // Gunakan kode yang sama dari jawaban sebelumnya agar tidak terlalu panjang
  Widget _buildTextField(String hint, TextEditingController c, {bool isNumber = false}) {
    return TextField(
      controller: c,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blue)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blue.shade200)),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black));
  }

  Widget _buildServiceCard(String title, IconData icon) {
    return Obx(() {
      bool isSelected = controller.selectedService.value == title;
      return GestureDetector(
        onTap: () => controller.selectedService.value = title,
        child: Container(
          width: 100,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade200, width: isSelected ? 2 : 1),
          ),
          child: Column(
            children: [
              Icon(icon, size: 35, color: isSelected ? Colors.blue : Colors.blue.shade300),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.blue : Colors.black)),
            ],
          ),
        ),
      );
    });
  }
}