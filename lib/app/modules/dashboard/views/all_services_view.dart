import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AllServicesView extends StatelessWidget {
  const AllServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    // DAFTAR LAYANAN LENGKAP (Pastikan nama file di folder assets/ sesuai)
    final List<Map<String, String>> services = [
      {"name": "Cuci Basah", "image": "assets/cucibasah.png"},
      {"name": "Cuci Kering", "image": "assets/cucikering.png"},
      {"name": "Setrika Wangi", "image": "assets/setrika.png"},
      {"name": "Cuci Sepatu", "image": "assets/sepatu.png"},
      {"name": "Cuci Tas", "image": "assets/tas.png"},
      {"name": "Cuci Helm", "image": "assets/helm.png"},
      {"name": "Cuci Spray", "image": "assets/spray.png"},
      {"name": "Cuci Boneka", "image": "assets/boneka.png"},
      {"name": "Cuci Jas/Gaun", "image": "assets/dress.png"},
      {"name": "Cuci Kiloan", "image": "assets/cucibasah.png"},
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
          // 1. BACKGROUND IMAGE
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/seeallbackground.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. EFEK BLUR (Opsional, agar text lebih terbaca)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
            child: Container(
              color: Colors.white.withOpacity(0.5), // Putih transparan
            ),
          ),

          // 3. KONTEN GRID
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

                  Text(
                    "Services",
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  // GRID MENU
                  Expanded(
                    child: GridView.builder(
                      itemCount: services.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // 3 Kolom
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.85,
                      ),
                      itemBuilder: (context, index) {
                        return _buildServiceItem(
                          services[index]['name']!,
                          services[index]['image']!,
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

  Widget _buildServiceItem(String title, String assetPath) {
    return Column(
      children: [
        // KOTAK ICON PUTIH
        Container(
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(18), // Padding agar icon tidak terlalu besar
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
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 30, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 10),
        // TEXT TITLE
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