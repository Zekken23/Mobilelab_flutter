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
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Pemesanan Laundry",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
        backgroundColor: Colors.cyanAccent.shade100.withOpacity(0.5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          // BACKGROUND IMAGE
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/pemesananbackground.png"), 
                fit: BoxFit.cover,
              ),
            ),
            child: Container(color: Colors.white.withOpacity(0.3)),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. INPUT FORM
                  _buildTextField("Nama", controller.namaC),
                  const SizedBox(height: 10),
                  _buildTextField("No Telp", controller.noTelpC, isNumber: true),
                  const SizedBox(height: 10),
                  _buildTextField("Alamat Lengkap", controller.alamatC),

                  const SizedBox(height: 20),

                  // 2. PETA (MAP) DENGAN ZOOM & MODE TOGGLE
                  Container(
                    height: 250, 
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey.shade300),
                      color: Colors.white, 
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
                                // Toggle Mode GPS/Network
                                Obx(() => _mapButton(
                                  controller.useHighAccuracy.value ? Icons.gps_fixed : Icons.wifi, 
                                  controller.toggleLocationMode,
                                  color: controller.useHighAccuracy.value ? Colors.blue : Colors.orange,
                                )),
                                const SizedBox(height: 8),
                                // Zoom In
                                _mapButton(Icons.add, controller.zoomIn),
                                const SizedBox(height: 8),
                                // Zoom Out
                                _mapButton(Icons.remove, controller.zoomOut),
                                const SizedBox(height: 8),
                                // Refresh Lokasi
                                _mapButton(Icons.my_location, controller.getCurrentLocation),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  
                  // KOORDINAT TEXT
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 4),
                    child: Obx(() => Text(
                      "Koordinat: ${controller.addressMap.value}",
                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700),
                    )),
                  ),

                  const SizedBox(height: 25),

                  // 3. PILIH SERVICE
                  _buildSectionTitle("Pilih Service"),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildServiceCard("Cuci Basah", Icons.local_laundry_service),
                      _buildServiceCard("Cuci Kering", Icons.dry_cleaning),
                      _buildServiceCard("Setrika Wangi", Icons.iron),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 4. LIST PAKAIAN
                  _buildSectionTitle("Note pakaian yang akan di laundry"),
                  const SizedBox(height: 10),
                  TextField(
                    controller: controller.itemsC,
                    maxLines: 3,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      hintText: "Contoh:\n- 2 Kemeja putih",
                      hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blue)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blue.shade200)),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 5. TANGGAL PICKUP
                  _buildSectionTitle("Pilih Hari Diambil (Pickup)"),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildDateChip("Today", "Hari Ini", isPickup: true),
                        _buildDateChip("Tomorrow", "Besok", isPickup: true),
                        _buildDateChip("Lusa", "Lusa", isPickup: true),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // 6. TANGGAL DELIVERY
                  _buildSectionTitle("Pilih Tanggal Diantar (Delivery)"),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildDateChip("Tomorrow", "Besok", isPickup: false),
                        _buildDateChip("Lusa", "Lusa", isPickup: false),
                        _buildDateChip("Nanti", "3 Hari Lagi", isPickup: false),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // 7. WAKTU
                  _buildSectionTitle("Pilih Waktu"),
                  const SizedBox(height: 10),
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

                  // 8. TOMBOL SUBMIT (BUAT PESANAN)
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value ? null : controller.submitOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E64D8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                      ),
                      child: controller.isLoading.value 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text("Buat Pesanan", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    )),
                  ),
                  
                  // Spacer bawah agar tidak mepet layar
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER UI (Tetap Sama) ---

  Widget _buildTextField(String label, TextEditingController c, {bool isNumber = false}) {
    return TextField(
      controller: c,
      keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.8),
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey.shade700),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blue)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.blue.shade200)),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87));
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
            color: isSelected ? Colors.blue.shade50 : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade300, width: isSelected ? 2 : 1),
            boxShadow: [if (!isSelected) BoxShadow(color: Colors.grey.shade100, blurRadius: 5)],
          ),
          child: Column(
            children: [
              Icon(icon, size: 35, color: isSelected ? Colors.blue : Colors.grey.shade600),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDateChip(String id, String label, {required bool isPickup}) {
    return Obx(() {
      String selected = isPickup ? controller.selectedPickupDate.value : controller.selectedDeliveryDate.value;
      bool isSelected = selected == label;
      return Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: ChoiceChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (val) {
            if (isPickup) controller.selectedPickupDate.value = label;
            else controller.selectedDeliveryDate.value = label;
          },
          selectedColor: Colors.white,
          backgroundColor: Colors.white.withOpacity(0.9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: isSelected ? Colors.blue : Colors.grey.shade300, width: isSelected ? 2 : 1)),
          labelStyle: GoogleFonts.poppins(color: isSelected ? Colors.blue : Colors.black, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
          showCheckmark: false,
        ),
      );
    });
  }

  Widget _buildTimeChip(String time) {
    return Obx(() {
      bool isSelected = controller.selectedTime.value == time;
      return Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: ChoiceChip(
          label: Text(time),
          selected: isSelected,
          onSelected: (val) => controller.selectedTime.value = time,
          selectedColor: Colors.white,
          backgroundColor: Colors.white.withOpacity(0.9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: isSelected ? Colors.blue : Colors.grey.shade300, width: isSelected ? 2 : 1)),
          labelStyle: GoogleFonts.poppins(color: isSelected ? Colors.blue : Colors.black, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
          showCheckmark: false,
        ),
      );
    });
  }

  Widget _mapButton(IconData icon, VoidCallback onTap, {Color color = Colors.blueAccent}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}