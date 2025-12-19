import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'history_controller.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HistoryController());

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: Text(
          "Riwayat Pesanan",
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white.withOpacity(0.25),
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black),
              onPressed: controller.fetchMyOrders)
        ],
      ),
      body: Stack(
        children: [
          // Background
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/pemesback.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // List Data
          SafeArea(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.myOrders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history,
                          size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 10),
                      Text("Belum ada riwayat pesanan",
                          style:
                              GoogleFonts.poppins(color: Colors.grey.shade600)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.myOrders.length,
                itemBuilder: (context, index) {
                  final order = controller.myOrders[index];
                  return _buildHistoryCard(context, order, controller);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // --- WIDGET CARD ---
  Widget _buildHistoryCard(
      BuildContext context, Map<String, dynamic> order, HistoryController controller) {
    
    // Ambil Data
    String status = order['status'] ?? "Sedang Dicuci";
    String layanan = order['layanan'] ?? "-";
    String tanggal = order['created_at'].toString().split('T')[0];
    
    // Tentukan Warna & Progress
    double progress = 0.1;
    Color statusColor = const Color(0xFF1E64D8);

    if (status == "Sedang Dicuci") {
      progress = 0.25;
    } else if (status == "Sedang Dijemur") {
      progress = 0.50;
      statusColor = Colors.orange;
    } else if (status == "Sedang Disetrika") {
      progress = 0.75;
      statusColor = Colors.purple;
    } else if (status == "Siap Diambil" || status == "Diantar Kurir") {
      progress = 0.90;
      statusColor = Colors.blue;
    } else if (status == "Selesai" || status == "Sampai Tujuan") {
      progress = 1.0;
      statusColor = Colors.green;
    }

    // --- LOGIKA UTAMA: INKWELL UNTUK KLIK CARD ---
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            // SAAT DIKLIK: MUNCULKAN BOTTOM SHEET DETAIL
            _showOrderDetail(context, order, controller, statusColor, isCompleted: (progress == 1.0));
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Circular Progress
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.grey.shade100,
                        color: statusColor,
                        strokeWidth: 6,
                      ),
                    ),
                    Text(
                      "${(progress * 100).toInt()}%",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                
                // Text Info Singkat
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        layanan,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4)),
                        child: Text(
                          status,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                              fontSize: 12),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Tap untuk detail", // Petunjuk user
                        style: GoogleFonts.poppins(
                            fontSize: 10, color: Colors.grey.shade400, fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                ),
                
                // Icon Arrow kecil penanda bisa diklik
                Icon(Icons.chevron_right, color: Colors.grey.shade300),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- FUNGSI MENAMPILKAN DETAIL (BOTTOM SHEET) ---
  void _showOrderDetail(BuildContext context, Map<String, dynamic> order, 
      HistoryController controller, Color statusColor, {required bool isCompleted}) {
    
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min, // Agar tinggi menyesuaikan konten
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Garis handle di tengah atas
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Judul Layanan
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    order['layanan'] ?? "Layanan",
                    style: GoogleFonts.poppins(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(20)
                    ),
                    child: Text(
                      order['status'] ?? "-",
                      style: GoogleFonts.poppins(
                          color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              
              // Detail Data
              _detailRow(Icons.person, "Nama Pemesan", order['nama'] ?? "-"),
              _detailRow(Icons.phone, "No. Telepon", order['no_telp'] ?? "-"),
              _detailRow(Icons.location_on, "Alamat", order['alamat_lengkap'] ?? "-"),
              _detailRow(Icons.note, "Catatan / Berat", order['berat_items'] ?? "-"),
              _detailRow(Icons.calendar_today, "Waktu Jemput", order['waktu_jemput'] ?? "-"),
              
              const SizedBox(height: 10),
              
              // Logic Tombol Hapus: Hanya muncul jika selesai
              if (isCompleted) ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.back(); // Tutup BottomSheet dulu
                      
                      // Konfirmasi Hapus
                      Get.defaultDialog(
                        title: "Hapus Riwayat",
                        middleText: "Yakin ingin menghapus riwayat ini selamanya?",
                        textConfirm: "Hapus",
                        textCancel: "Batal",
                        confirmTextColor: Colors.white,
                        buttonColor: Colors.red,
                        onConfirm: () {
                          Get.back(); // Tutup Dialog
                          controller.deleteOrder(order['id']);
                        },
                      );
                    },
                    icon: const Icon(Icons.delete_forever, color: Colors.white),
                    label: Text("Hapus Riwayat", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 10),
              // Tombol Tutup
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text("Tutup", style: GoogleFonts.poppins(color: Colors.grey)),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true, // Agar sheet bisa tinggi kalau kontennya banyak
    );
  }

  // Helper Widget untuk Baris Detail
  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey)),
                Text(value, style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}