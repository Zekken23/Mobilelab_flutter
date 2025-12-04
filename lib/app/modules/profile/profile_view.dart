import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Controller agar siap digunakan saat halaman dibuka
    Get.put(ProfileController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. HEADER PROFILE (FOTO & NAMA) ---
              Center(
                child: Column(
                  children: [
                    // AVATAR DENGAN FUNGSI UPLOAD
                    GestureDetector(
                      onTap: () => controller.uploadAvatar(),
                      child: Obx(() {
                        bool hasImage = controller.avatarUrl.value.isNotEmpty;
                        return Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue.shade50,
                            image: DecorationImage(
                              image: hasImage
                                  ? NetworkImage(controller.avatarUrl.value) as ImageProvider
                                  : const AssetImage('assets/profile1.jpg'),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(color: Colors.blue.withOpacity(0.2), blurRadius: 15, spreadRadius: 5)
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Icon Kamera kecil di pojok kanan bawah
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: const Icon(Icons.camera_alt, size: 18, color: Colors.blueAccent),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // NAMA USER (DINAMIS DARI CONTROLLER)
                    Obx(() => Text(
                      controller.nama.value,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        height: 1.2,
                      ),
                    )),
                    
                    const SizedBox(height: 8),
                    
                    // TOMBOL EDIT PROFILE
                    GestureDetector(
                      onTap: () => controller.showEditDialog(),
                      child: Text(
                        "Edit Profile",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF1E64D8),
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 35),

              // --- 2. BAGIAN EMAIL (READ ONLY) ---
              Text("Email", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              Obx(() => _buildInfoCard(Icons.email_outlined, controller.email.value)),

              const SizedBox(height: 20),

              // --- 3. BAGIAN ALAMAT (DINAMIS) ---
              Text("Alamat", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 8),
              Obx(() => _buildInfoCard(
                Icons.map_outlined, 
                controller.alamat.value, 
                isMultiLine: true
              )),

              const SizedBox(height: 25),

              // --- 4. STATUS PESANAN (PROGRESS BAR) ---
              Text("Pesanan saya", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
              const Divider(thickness: 1, height: 20),
              _buildOrderStatusCard(),

              const SizedBox(height: 40),
              
              // --- 5. TOMBOL LOGOUT ---
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

  // --- WIDGET HELPER: KOTAK INFO ---
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
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              maxLines: isMultiLine ? 3 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER: KARTU STATUS ORDER ---
  Widget _buildOrderStatusCard() {
    return Obx(() {
      // Jika tidak ada pesanan, tampilkan info kosong
      if (controller.lastOrderStatus.value == "Belum ada pesanan") {
        return Container(
          padding: const EdgeInsets.all(20),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Center(
            child: Text(
              "Belum ada pesanan aktif",
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
        );
      }

      // Jika ada pesanan, tampilkan progress
      return Container(
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
            // Circular Indicator
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: controller.progressValue.value, 
                    backgroundColor: Colors.grey.shade200,
                    color: const Color(0xFF1E64D8),
                    strokeWidth: 6,
                  ),
                ),
                Text(
                  "${(controller.progressValue.value * 100).toInt()}%",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E64D8),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            // Teks Status & Tanggal
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.lastOrderStatus.value,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.lastOrderDate.value,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF648DDB),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      );
    });
  }
}