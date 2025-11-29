import 'dart:ui'; // Diperlukan untuk ImageFilter (Blur)
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AllServicesView extends StatelessWidget {
  const AllServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    // Daftar Layanan (Label & Icon)
    // Nanti Anda bisa ganti IconData dengan Image.asset jika punya gambar PNG-nya
    final List<Map<String, dynamic>> services = [
      {"name": "Cuci Basah", "icon": Icons.local_laundry_service, "color": Colors.blue.shade100},
      {"name": "Cuci Kering", "icon": Icons.dry_cleaning, "color": Colors.orange.shade100},
      {"name": "Setrika Wangi", "icon": Icons.iron, "color": Colors.purple.shade100},
      {"name": "Cuci Sepatu", "icon": Icons.roller_skating, "color": Colors.yellow.shade100}, // Ganti aset sepatu
      {"name": "Cuci Tas", "icon": Icons.shopping_bag, "color": Colors.brown.shade100},       // Ganti aset tas
      {"name": "Cuci Helm", "icon": Icons.two_wheeler, "color": Colors.grey.shade300},        // Ganti aset helm
      {"name": "Cuci Spray", "icon": Icons.bed, "color": Colors.pink.shade100},               // Ganti aset kasur/spray
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          // 1. BACKGROUND IMAGE (Menggunakan background yang sudah ada)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/pemesananbackground.png'), // Gunakan background yang ada
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. EFEK BLUR (FROSTED GLASS)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Kekuatan blur
            child: Container(
              color: Colors.white.withOpacity(0.6), // Lapisan putih transparan
            ),
          ),

          // 3. KONTEN UTAMA
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SEARCH BAR
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search for service...",
                        hintStyle: GoogleFonts.poppins(color: Colors.grey),
                        prefixIcon: const Icon(Icons.search, color: Colors.black54),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // JUDUL
                  Text(
                    "Services",
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  // GRID LAYANAN
                  Expanded(
                    child: GridView.builder(
                      itemCount: services.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // 3 Kolom ke samping
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.8, // Mengatur tinggi kotak agar pas
                      ),
                      itemBuilder: (context, index) {
                        return _buildServiceItem(
                          services[index]['name'],
                          services[index]['icon'],
                          services[index]['color'],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(String title, IconData icon, Color bgColor) {
    return Column(
      children: [
        // Kotak Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Center(
            // Ganti Icon ini dengan Image.asset jika ingin pakai gambar ilustrasi
            child: Icon(icon, size: 40, color: Colors.black87), 
            // Contoh pakai gambar:
            // child: Image.asset('assets/icon_$title.png', width: 40),
          ),
        ),
        const SizedBox(height: 10),
        // Teks Label
        Text(
          title,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600, // Semi Bold
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}