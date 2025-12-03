import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject controller
    Get.put(ProfileController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER PROFILE (Foto & Nama)
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue.shade50,
                        image: const DecorationImage(
                          image: AssetImage('assets/profile_placeholder.png'),
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(color: Colors.blue.withOpacity(0.2), blurRadius: 15, spreadRadius: 5)
                        ]
                      ),
                      // Fallback icon jika gambar tidak ada
                      child: const Icon(Icons.person, size: 60, color: Colors.blueAccent),
                    ),
                    const SizedBox(height: 16),
                    
                    // NAMA USER (DINAMIS DARI DATABASE)
                    Obx(() => Text(
                      controller.nama.value, // <--- Menggunakan variabel dari Controller
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        height: 1.2,
                      ),
                    )),
                    
                    const SizedBox(height: 4),
                    
                    // TOMBOL EDIT PROFILE
                    GestureDetector(
                      onTap: () => controller.showEditDialog(), // <--- Panggil Dialog Edit
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20)
                        ),
                        child: Text(
                          "Edit Profile",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF1E64D8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 35),

              // 2. BAGIAN EMAIL (READ ONLY)
              Text("Email", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              // Email biasanya tidak bisa diedit sembarangan, jadi kita tampilkan saja
              Obx(() => _buildInfoCard(Icons.email_outlined, controller.email.value)),

              const SizedBox(height: 20),

              // 3. BAGIAN ALAMAT (DINAMIS)
              Text("Alamat", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              Obx(() => _buildInfoCard(
                Icons.map_outlined, 
                controller.alamat.value, // <--- Menggunakan variabel dari Controller
                isMultiLine: true
              )),

              const SizedBox(height: 25),

              // 4. BAGIAN PESANAN SAYA (TETAP SAMA)
              Text("Pesanan saya", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
              const Divider(thickness: 1, height: 20),
              _buildOrderStatusCard(),

              const SizedBox(height: 40),
              
              // TOMBOL LOGOUT (TETAP SAMA)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: controller.logout,
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: Text("Log Out", style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET PENDUKUNG ---

  Widget _buildInfoCard(IconData icon, String text, {bool isMultiLine = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.black, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black),
              maxLines: isMultiLine ? 3 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildOrderStatusCard() {
    // Gunakan Obx agar update otomatis
    return Obx(() => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60, height: 60,
                child: CircularProgressIndicator(
                  value: controller.progressValue.value, // <--- Value Dinamis
                  backgroundColor: Colors.grey.shade200,
                  color: const Color(0xFF1E64D8),
                  strokeWidth: 6,
                ),
              ),
              // Tampilkan persentase
              Text("${(controller.progressValue.value * 100).toInt()}%", 
                  style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF1E64D8))),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tampilkan Status Text Dinamis
                Text(controller.lastOrderStatus.value, 
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 4),
                // Tampilkan Tanggal
                Text(controller.lastOrderDate.value, 
                    style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF648DDB))),
              ],
            ),
          )
        ],
      ),
    ));
  }
}