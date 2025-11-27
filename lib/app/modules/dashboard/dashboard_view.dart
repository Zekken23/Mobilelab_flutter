import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard_controller.dart';
import '../order/order_view.dart'; // Import view order/booking

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body akan berubah sesuai tab yang dipilih
      body: Obx(() => IndexedStack(
        index: controller.tabIndex.value,
        children: [
          _buildHomeView(),   // Index 0: Home Dashboard
          OrderView(),        // Index 1: Booking/Order (Peta)
          _buildProfileView(),// Index 2: Account/Profile (Logout disini)
        ],
      )),
      
      // Bottom Navigation Bar
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: controller.tabIndex.value,
        onTap: controller.changeTabIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Booking'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      )),
    );
  }

  // --- TAMPILAN HOME (KODE SEBELUMNYA) ---
  Widget _buildHomeView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Profile Kecil
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Hi, Enno Penas", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text("ennopenas@gmail.com", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                ],
              ),
              const CircleAvatar(
                backgroundImage: AssetImage('assets/profile_placeholder.png'), // Pastikan ada aset ini atau hapus
                backgroundColor: Colors.blueAccent,
              )
            ],
          ),
          const SizedBox(height: 20),
          
          // Banner Biru
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2D9CDB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("SUPER WASH", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                      Text("Quality Laundry Service", style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const Icon(Icons.local_laundry_service, color: Colors.white, size: 50),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Services Grid
          Text("Services", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _serviceCard("Cuci Basah", Icons.water_drop_outlined),
              _serviceCard("Cuci Kering", Icons.dry_cleaning),
              _serviceCard("Setrika", Icons.iron),
            ],
          ),
        ],
      ),
    );
  }

  Widget _serviceCard(String title, IconData icon) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, spreadRadius: 1)]
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.blueAccent),
          const SizedBox(height: 8),
          Text(title, style: GoogleFonts.poppins(fontSize: 12), textAlign: TextAlign.center)
        ],
      ),
    );
  }

  // --- TAMPILAN PROFILE (BARU) ---
  Widget _buildProfileView() {
    return Padding(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
      child: Column(
        children: [
          // Foto Profile Besar
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.blueAccent,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text("Enno Penas", style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)),
          Text("ennopenas@gmail.com", style: GoogleFonts.poppins(color: Colors.grey)),
          
          const SizedBox(height: 40),

          // Menu Options
          _profileMenuOption(Icons.person_outline, "Edit Profile"),
          _profileMenuOption(Icons.settings_outlined, "Settings"),
          _profileMenuOption(Icons.help_outline, "Help & Support"),
          
          const Divider(),
          
          // TOMBOL LOGOUT
          ListTile(
            onTap: () => controller.logout(), // Memanggil fungsi di Controller
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.logout, color: Colors.red),
            ),
            title: Text("Log Out", style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.w600)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _profileMenuOption(IconData icon, String title) {
    return ListTile(
      onTap: () {},
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: Colors.blueAccent),
      ),
      title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }
}