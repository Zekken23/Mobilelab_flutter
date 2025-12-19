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
      // GestureDetector untuk menutup keyboard saat tap layar luar
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Obx(() => IndexedStack(
          index: controller.tabIndex.value,
          children: [
            _buildHomeView(context), // <--- PERUBAHAN 1: Masukkan 'context' di sini
            const OrderView(),
            const HistoryView(),
            ChatView(),
            const ProfileView(),
          ],
        )),
      ),
      
      bottomNavigationBar: Obx(() => Container(
        decoration: const BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]
        ),
        child: BottomNavigationBar(
          currentIndex: controller.tabIndex.value,
          onTap: controller.changeTabIndex,
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedLabelStyle: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 10),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Booking'),
            BottomNavigationBarItem(icon: Icon(Icons.history), activeIcon: Icon(Icons.history_edu), label: 'Riwayat'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'Chat'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
          ],
        ),
      )),
    );
  }
  
  // <--- PERUBAHAN 2: Tambahkan 'BuildContext context' di dalam kurung
  Widget _buildHomeView(BuildContext context) { 
    final profileC = Get.put(ProfileController()); 

    return Stack(
      children: [
        // Background Image
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

        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. HEADER (FIXED) ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  children: [
                    // Profile Header
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
                                Text("Selamat datang kembali", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
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

                    // Search Bar
                    TextField(
                      controller: controller.searchC,
                      onChanged: (value) => controller.runFilter(value),
                      decoration: InputDecoration(
                        hintText: "cari layanan anda...",
                        hintStyle: GoogleFonts.poppins(color: Colors.grey),
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                        // Tombol clear jika ada text
                        suffixIcon: Obx(() => controller.isSearching.value 
                          ? IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () {
                              controller.searchC.clear();
                              controller.runFilter("");
                              // Sekarang 'context' sudah dikenali karena dioper dari parameter
                              FocusScope.of(context).unfocus(); 
                            })
                          : const SizedBox.shrink()
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --- 2. KONTEN (SCROLLABLE) ---
              Expanded(
                child: Obx(() {
                  if (controller.isSearching.value) {
                     return _buildSearchResults();
                  } else {
                     return _buildNormalDashboardContent();
                  }
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- VIEW SAAT MENCARI ---
  Widget _buildSearchResults() {
    return Container(
      color: const Color(0xFFF6F8FB).withOpacity(0.95), 
      child: controller.searchResults.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 60, color: Colors.grey),
                Text("Layanan tidak ditemukan", style: GoogleFonts.poppins(color: Colors.grey)),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: controller.searchResults.length,
            itemBuilder: (context, index) {
              final item = controller.searchResults[index];
              return Card(
                elevation: 0,
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  leading: Image.asset(item['image'], width: 40, height: 40, errorBuilder: (c,e,s) => const Icon(Icons.image)),
                  title: Text(item['name'], style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  subtitle: Text("Tap untuk pesan", style: GoogleFonts.poppins(fontSize: 10, color: Colors.blue)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  onTap: () {
                     controller.navigateToOrder(item['name']);
                  },
                ),
              );
            },
          ),
    );
  }

  // --- VIEW DASHBOARD NORMAL ---
  Widget _buildNormalDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
           // LOCATION BAR (UPDATE DI SINI)
           GestureDetector(
             onTap: () {
               // Tap untuk refresh lokasi manual
               controller.fetchLocation();
             },
             child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF2E3192), Color(0xFF1BFFFF)]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E3192).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5)
                    )
                  ]
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                      // Animasi loading icon kalau sedang mencari
                      child: Obx(() => controller.isLoadingLocation.value 
                        ? const SizedBox(
                            width: 24, height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          )
                        : const Icon(Icons.location_on, color: Colors.white)
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Lokasi Anda", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                          
                          // Tampilkan alamat dari Controller
                          Obx(() => Text(
                            controller.currentAddress.value, 
                            style: GoogleFonts.poppins(
                              color: Colors.white, 
                              fontWeight: FontWeight.w600, 
                              fontSize: 14
                            ), 
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          )),
                        ],
                      ),
                    ),
                    // Icon refresh kecil di ujung kanan (opsional, sebagai penanda bisa diklik)
                    const Icon(Icons.refresh, color: Colors.white70, size: 18),
                  ],
                ),
              ),
           ),

            const SizedBox(height: 24),

            // SERVICES SECTION
            _buildSectionHeader("Layanan kami"),
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

            // BANNER PROMO
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

            // PRICE LIST SECTION
            _buildSectionHeader("List harga"),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: [
                _buildPriceCard("Cuci Basah", "Mulai Rp 7.000", 'assets/cucibasah.png', Colors.blue.shade50),
                _buildPriceCard("Cuci Wangi", "Mulai Rp 9.000", 'assets/setrika.png', Colors.purple.shade50),
                _buildPriceCard("Cuci Kering", "Mulai Rp 8.000", 'assets/cucikering.png', Colors.orange.shade50),
                _buildPriceCard("Cuci Sepatu", "Mulai Rp 25.000", 'assets/sepatu.png', Colors.yellow.shade50),
              ],
            ),
            const SizedBox(height: 20), 
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
        GestureDetector(
          onTap: () {
            Get.to(() => const AllServicesView()); 
          },
          child: Text("Selengkapnya", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey, decoration: TextDecoration.underline)),
        ),
      ],
    );
  }

  Widget _buildServiceItem(String title, String assetPath) {
    return GestureDetector(
      onTap: () => controller.navigateToOrder(title),
      child: Column(
        children: [
          Container(
            width: 70, height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, spreadRadius: 1)],
            ),
            child: Center(
              child: Image.asset(assetPath, width: 35, height: 35, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.grey)),
            ),
          ),
          const SizedBox(height: 8),
          Text(title, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildPriceCard(String title, String price, String assetPath, Color bgColor) {
      return GestureDetector(
        onTap: () => controller.navigateToOrder(title),
        child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor.withOpacity(0.4), 
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.7), shape: BoxShape.circle),
              child: Image.asset(assetPath, width: 20, height: 20, errorBuilder: (c, e, s) => Icon(Icons.local_offer, size: 20, color: Colors.grey[700])),
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
      ),
    );
  }
}