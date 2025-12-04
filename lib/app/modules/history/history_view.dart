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
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black)
        ),
        centerTitle: true,
        backgroundColor: Colors.white.withOpacity(0.25), 
        elevation: 0,
        automaticallyImplyLeading: false, 
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black), 
            onPressed: controller.fetchMyOrders
          )
        ],
      ),

      body: Stack(
        children: [
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

          // 2. KONTEN LIST RIWAYAT
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
                      Icon(Icons.history, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 10),
                      Text(
                        "Belum ada riwayat pesanan", 
                        style: GoogleFonts.poppins(color: Colors.grey.shade600)
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.myOrders.length,
                itemBuilder: (context, index) {
                  final order = controller.myOrders[index];
                  return _buildHistoryCard(order);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> order) {
    String status = order['status'] ?? "Sedang Dicuci";
    String layanan = order['layanan'] ?? "-";
    // Ambil tanggal saja (YYYY-MM-DD)
    String tanggal = order['created_at'].toString().split('T')[0]; 
    
    // Tentukan Progress Value (0.0 - 1.0) & Warna Status
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
      statusColor = Colors.grey; // Abu-abu kalau sudah selesai
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))
        ],
        border: Border.all(color: Colors.white.withOpacity(0.5)), // Border tipis
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Circular Progress Indicator
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
          
          // Detail Pesanan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  layanan,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4)
                  ),
                  child: Text(
                    status,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, 
                      color: statusColor,
                      fontSize: 12
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Dibuat: $tanggal",
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}