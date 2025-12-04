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
      extendBodyBehindAppBar: true, // Agar background menyatu sampai atas
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Pemesanan Laundry",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
        ),
        centerTitle: true,
        // Gradient Header Biru (Dipertahankan)
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2E3192), Color(0xFF1BFFFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      
      // --- MODIFIKASI DIMULAI DARI SINI (STACK) ---
      body: Stack(
        children: [
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/pemesback.png"), 
                fit: BoxFit.cover,
              ),
            ),
            // Tambahan: Lapisan putih transparan agar teks tetap mudah dibaca
            child: Container(
              color: Colors.white.withOpacity(0.15), 
            ),
          ),

          // 2. KONTEN ASLI (SingleChildScrollView)
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. FORM INPUT
                  _buildTextField("Nama", controller.namaC),
                  const SizedBox(height: 12),
                  _buildTextField("No Telp", controller.noTelpC, isNumber: true),
                  const SizedBox(height: 12),
                  _buildTextField("Alamat Lengkap", controller.alamatC),

                  const SizedBox(height: 20),

                  // 2. PETA
                  Container(
                    height: 150, 
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
                              onTap: (tapPosition, point) {
                                controller.onMapTap(tapPosition, point);
                              },
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.yusron.rajacuci',
                              ),
                              MarkerLayer(markers: controller.markers.toList()),
                            ],
                          )),
                          // Tombol Refresh Kecil
                          Positioned(
                            bottom: 8, right: 8,
                            child: InkWell(
                              onTap: controller.getCurrentLocation,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: const Icon(Icons.my_location, size: 20, color: Colors.blue),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 3. PILIH SERVICE 
                  _buildSectionTitle("Pilih Service", suffix: "Lainnya"),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildServiceCard("Cuci Basah", 'assets/cucibasah.png'),
                      _buildServiceCard("Cuci Kering", 'assets/cucikering.png'),
                      _buildServiceCard("Setrika Wangi", 'assets/setrika.png'),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // 4. NOTE PAKAIAN
                  _buildSectionTitle("Note pakaian"),
                  const SizedBox(height: 12),
                  Container(
                    height: 120, 
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue), 
                    ),
                    child: TextField(
                      controller: controller.noteC,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: "putih dipisah, yang hitam gampang luntur",
                        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 13),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 5. PILIH HARI DIAMBIL (PICKUP)
                  _buildSectionTitle("Pilih Hari Diambil"),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildChip("Today", "Hari Ini", isPickup: true),
                        _buildChip("Tomorrow", "Besok", isPickup: true),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 6. PILIH TANGGAL DIANTAR (DELIVERY)
                  _buildSectionTitle("Pilih Tanggal Diantar"),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildChip("Ambil sendiri", "Ambil Sendiri", isPickup: false),
                        _buildChip("hari ini", "Hari Ini", isPickup: false),
                        _buildChip("Besok", "Besok", isPickup: false),
                        _buildChip("lusa", "Lusa", isPickup: false),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 7. PILIH WAKTU
                  _buildSectionTitle("Pilih Waktu"),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTimeChip("9:00 AM"),
                        _buildTimeChip("10:00 AM"),
                        _buildTimeChip("11:00 AM"),
                        _buildTimeChip("12:00 PM"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 8. TOMBOL BUAT PESANAN
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value ? null : controller.submitOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E64D8), 
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                      child: controller.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "Buat Pesanan",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    )),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER (TETAP DIPERTAHANKAN) ---

  Widget _buildTextField(String hint, TextEditingController c, {bool isNumber = false}) {
    return TextField(
      controller: c,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Colors.white, // Agar inputan jelas diatas background
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue), 
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue), 
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {String? suffix}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
        ),
        if (suffix != null)
          Text(
            suffix,
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
          )
      ],
    );
  }

  Widget _buildServiceCard(String title, String assetPath) {
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
            border: Border.all(
              color: isSelected ? Colors.transparent : Colors.grey.shade200,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.grey.shade100, 
                blurRadius: 10,
                spreadRadius: isSelected ? 2 : 1
              )
            ],
          ),
          child: Column(
            children: [
              Image.asset(assetPath, width: 40, height: 40, errorBuilder: (c,e,s) => const Icon(Icons.broken_image)),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildChip(String label, String value, {required bool isPickup}) {
    return Obx(() {
      String selected = isPickup 
          ? controller.selectedPickupDate.value 
          : controller.selectedDeliveryDate.value;
      bool isSelected = selected == value;
      
      return Padding(
        padding: const EdgeInsets.only(right: 10),
        child: InkWell(
          onTap: () {
            if (isPickup) controller.selectedPickupDate.value = value;
            else controller.selectedDeliveryDate.value = value;
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTimeChip(String time) {
    return Obx(() {
      bool isSelected = controller.selectedTime.value == time;
      return Padding(
        padding: const EdgeInsets.only(right: 10),
        child: InkWell(
          onTap: () => controller.selectedTime.value = time,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              time,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      );
    });
  }
}