import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderSuccessView extends StatelessWidget {
  const OrderSuccessView({super.key});

  // Fungsi untuk membuka WhatsApp
  Future<void> launchWhatsApp(Map<String, dynamic> data) async {
    // Ganti dengan nomor Admin Laundry kamu (Format: 628xxx)
    const String phoneNumber = "6285704732289"; 
    
    // Pesan template
    String message = "Halo Admin Raja Cuci, saya mau konfirmasi pesanan:\n\n"
        "Nama: ${data['nama']}\n"
        "No Telp: ${data['no_telp']}\n"
        "Layanan: ${data['layanan']}\n"
        "Alamat: ${data['alamat']}\n"
        "Catatan: ${data['note']}\n"
        "Waktu Jemput: ${data['waktu']}\n\n"
        "Mohon diproses ya, terima kasih!";

    final Uri url = Uri.parse(
        "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}");

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      Get.snackbar("Error", "Tidak dapat membuka WhatsApp");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil data yang dikirim dari Controller
    final data = Get.arguments ?? {};

    return Scaffold(
      // Kita gunakan Stack untuk menumpuk Background di belakang Konten
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/chatbackground.jpg"), 
                fit: BoxFit.cover, 
              ),
            ),
          ),

          // --- LAPISAN 2: KONTEN UTAMA ---
          Center(
            child: SingleChildScrollView( // Agar aman di layar kecil
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // --- 1. ICON CENTANG ---
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50), // Warna Hijau
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 120,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // --- 2. TEXT JUDUL ---
                    Text(
                      "PESANAN DI KONFIRMASI",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // --- 3. TEXT SUBJUDUL ---
                    Text(
                      "silakan hubungi admin WA untuk\nmelakukan pembayaran",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[700], // Sedikit digelapkan agar terbaca di bg
                      ),
                    ),

                    const SizedBox(height: 60),

                    // --- 4. TOMBOL LANJUT WA ---
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () => launchWhatsApp(data),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFF4CAF50), width: 2.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Lanjut WA",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF4CAF50),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.chat, color: Color(0xFF4CAF50)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // --- 5. TOMBOL KEMBALI KE BERANDA ---
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.offAllNamed('/dashboard'); 
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Colors.black, width: 2.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                          shadowColor: Colors.black.withOpacity(0.3),
                        ),
                        child: Text(
                          "Kembali Ke beranda",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}