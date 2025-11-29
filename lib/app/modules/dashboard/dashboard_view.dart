import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard_controller.dart';
import '../order/order_view.dart'; 
import '../chat/chat_view.dart';
import '../profile/profile_view.dart';
import 'views/all_services_view.dart'; 
import 'views/test_location_view.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      body: Obx(() => IndexedStack(
        index: controller.tabIndex.value,
        children: [
          _buildHomeView(),    
          OrderView(),         
          ChatView(),          
          const ProfileView(), 
          const TestLocationView(),
        ],
      )),
      
      // Bottom Navigation Bar
        bottomNavigationBar: Obx(() => Container(
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]
          ),
          child: BottomNavigationBar(
            currentIndex: controller.tabIndex.value,
            onTap: controller.changeTabIndex,
            selectedItemColor: Colors.purple,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Booking'),
              BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
              BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Account'),
              BottomNavigationBarItem(icon: Icon(Icons.science_outlined), activeIcon: Icon(Icons.science), label: 'Uji M5'),
            ],
         ),
       )),
     );
  }

  // --- TAMPILAN UTAMA (HOME) ---
  Widget _buildHomeView() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Foto Profile
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: AssetImage('assets/logorajalaundry.png'), 
                          fit: BoxFit.cover,
                        ),
                        color: Colors.blueAccent, // Fallback color
                      ),
                      child: const Icon(Icons.person, color: Colors.white), // hapus aja jika ndak diperlukan
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Enno Penas", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text("ennopenas@gmail.com", style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
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

            // 2. LOCATION BAR (Kotak Biru)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF2E3192), Color(0xFF1BFFFF)]), // Gradasi Biru
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
                        Text("Tegalgondo, Malang, Jawa Timur", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14), overflow: TextOverflow.ellipsis),
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
                _buildServiceItem("Cuci Basah", Icons.local_laundry_service, Colors.blue.shade100, Colors.blue),
                _buildServiceItem("Cuci Kering", Icons.dry_cleaning, Colors.orange.shade100, Colors.orange),
                _buildServiceItem("Setrika Wangi", Icons.iron, Colors.purple.shade100, Colors.purple),
              ],
            ),

            const SizedBox(height: 24),

            // 5. BANNER PROMO
            Container(
              width: double.infinity,
              height: 140,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF00A8E8), // Warna Biru Banner
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
              childAspectRatio: 2.2, // Mengatur bentuk kotak agar melebar
              children: [
                _buildPriceCard("Cuci Basah", "Rp. 10.000", Icons.local_laundry_service, Colors.blue.shade50),
                _buildPriceCard("Cuci Wangi", "Rp. 15.000", Icons.local_offer, Colors.purple.shade50),
                _buildPriceCard("Cuci Kering", "Rp. 13.000", Icons.dry_cleaning, Colors.orange.shade50),
                _buildPriceCard("Cuci Sepatu", "Rp. 13.000", Icons.roller_skating, Colors.yellow.shade50),
              ],
            ),
          ],
        ),
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
          child: Text(
            "See all", 
            style: GoogleFonts.poppins(
              fontSize: 12, 
              color: Colors.grey, 
              decoration: TextDecoration.underline
            )
          ),
        ),
        // -----------------------------
      ],
    );
  }

  Widget _buildServiceItem(String title, IconData icon, Color bgColor, Color iconColor) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, spreadRadius: 1)],
          ),
          child: Center(
            child: Icon(icon, size: 32, color: iconColor), // Icon pengganti gambar
          ),
        ),
        const SizedBox(height: 8),
        Text(title, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildPriceCard(String title, String price, IconData icon, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor, // Warna background tipis
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(icon, size: 20, color: Colors.black54),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Text(price, style: GoogleFonts.poppins(color: Colors.grey, fontSize: 11)),
              ],
            ),
          )
        ],
      ),
    );
  }
}