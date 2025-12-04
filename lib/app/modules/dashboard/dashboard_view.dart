import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard_controller.dart';
import '../order/order_view.dart';
import '../history/history_view.dart'; 
import '../chat/chat_view.dart';
import '../profile/profile_view.dart'; 
import '../profile/profile_controller.dart'; 
import 'views/all_services_view.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      
      // --- BODY DENGAN 6 HALAMAN ---
      body: Obx(() => IndexedStack(
        index: controller.tabIndex.value,
        children: [
          _buildHomeView(),         // Index 0: Home
          const OrderView(),        // Index 1: Booking
          const HistoryView(),      // Index 2: History (SUDAH KEMBALI)
          ChatView(),               // Index 3: Chat
          const ProfileView(),      // Index 4: Profile
        ],
      )),
      
      // --- NAVBAR BAWAH (6 ITEM) ---
      bottomNavigationBar: Obx(() => Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]
        ),
        child: BottomNavigationBar(
          currentIndex: controller.tabIndex.value,
          onTap: controller.changeTabIndex,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed, // Wajib fixed jika item > 3
          backgroundColor: Colors.white,
          elevation: 0,
          selectedLabelStyle: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 10),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Booking'),
            BottomNavigationBarItem(icon: Icon(Icons.history), activeIcon: Icon(Icons.history_edu), label: 'History'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'Chat'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Account'),
          ],
        ),
      )),
    );
  }

  // --- TAMPILAN UTAMA (HOME) ---
  Widget _buildHomeView() {
    final profileC = Get.put(ProfileController()); 

    return Stack(
      children: [
        // 1. BACKGROUND IMAGE (PALING BELAKANG)
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/dashboardbackground.png'), 
              fit: BoxFit.cover,
            ),
          ),
        ),

        // 2. KONTEN DASHBOARD (DI DEPAN BACKGROUND)
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HEADER PROFILE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Obx(() {
                          bool hasImage = profileC.avatarUrl.value.isNotEmpty;
                          return Container(
                            width: 50, height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue.shade50,
                              image: DecorationImage(
                                image: hasImage
                                    ? NetworkImage(profileC.avatarUrl.value) as ImageProvider
                                    : const AssetImage('assets/profile1.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        }),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(() => Text(
                              profileC.nama.value, 
                              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                            )),
                            Text("Welcome Back", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5)]),
                      child: const Icon(Icons.notifications_active, color: Colors.orange, size: 24),
                    )
                  ],
                ),

                const SizedBox(height: 20),

                // 2. LOCATION BAR
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF2E3192), Color(0xFF1BFFFF)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                        child: const Icon(Icons.location_on, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Your Location", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                            Text("Tegalgondo, Malang", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14), overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 3. SEARCH BAR
                TextField(
                  decoration: InputDecoration(
                    hintText: "Search for service...",
                    hintStyle: GoogleFonts.poppins(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                  ),
                ),

                const SizedBox(height: 24),

                // 4. SERVICES SECTION
                _buildSectionHeader("Services"),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildServiceItem("Cuci Basah", 'assets/cucibasah.png'),
                    _buildServiceItem("Cuci Kering", 'assets/cucikering.png'),
                    _buildServiceItem("Setrika Wangi", 'assets/setrika.png'),
                  ],
                ),

                const SizedBox(height: 24),

                // 5. BANNER PROMO
                Container(
                  width: double.infinity,
                  height: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00A8E8),
                    borderRadius: BorderRadius.circular(20),
                    image: const DecorationImage(
                       image: AssetImage('assets/superwash.png'), 
                       fit: BoxFit.cover,
                    )
                  ),
                ),

                const SizedBox(height: 24),

                // 6. PRICE LIST SECTION
                _buildSectionHeader("Price List"),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.2,
                  children: [
                    _buildPriceCard(
                      "Cuci Basah", 
                      "Mulai Rp 7.000", 
                      'assets/cucibasah.png', 
                      Colors.blue.shade50
                    ),
                    _buildPriceCard(
                      "Cuci Wangi", 
                      "Mulai Rp 9.000", 
                      'assets/setrika.png', 
                      Colors.purple.shade50
                    ),
                    _buildPriceCard(
                      "Cuci Kering", 
                      "Mulai Rp 8.000", 
                      'assets/cucikering.png', 
                      Colors.orange.shade50
                    ),
                    _buildPriceCard(
                      "Cuci Sepatu", 
                      "Mulai Rp 25.000", 
                      'assets/sepatu.png', 
                      Colors.yellow.shade50
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        GestureDetector(
          onTap: () {
            Get.to(() => const AllServicesView()); 
          },
          child: Text("See all", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, decoration: TextDecoration.underline)),
        ),
      ],
    );
  }

  // Helper untuk Gambar Asset Service
  Widget _buildServiceItem(String title, String assetPath) {
    return Column(
      children: [
        Container(
          width: 70, height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, spreadRadius: 1)],
          ),
          child: Center(
            child: Image.asset(
              assetPath, 
              width: 35, height: 35,
              errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.grey), 
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(title, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildPriceCard(String title, String price, String assetPath, Color bgColor) {
      return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // Opacity 0.4 membuat warna background jadi transparan
        color: bgColor.withOpacity(0.4), 
        borderRadius: BorderRadius.circular(16),
        // Optional: Tambahkan border tipis agar lebih rapi di background gelap/terang
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7), 
              shape: BoxShape.circle
            ),
            // Menggunakan Image.asset sesuai permintaan
            child: Image.asset(
              assetPath, 
              width: 20, height: 20,
              errorBuilder: (c, e, s) => Icon(Icons.local_offer, size: 20, color: Colors.grey[700]),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(price, style: GoogleFonts.poppins(color: Colors.black54, fontSize: 11)),
              ],
            ),
          )
        ],
      ),
    );
  }
}