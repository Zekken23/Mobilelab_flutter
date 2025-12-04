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
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: Text("Riwayat Pesanan", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        automaticallyImplyLeading: false, // Hilangkan back button karena di navbar
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black), 
            onPressed: controller.fetchMyOrders
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.myOrders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 10),
                Text("Belum ada riwayat pesanan", style: GoogleFonts.poppins(color: Colors.grey)),
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
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> order) {
    String status = order['status'] ?? "Sedang Dicuci";
    String layanan = order['layanan'] ?? "-";
    // Ambil tanggal saja (YYYY-MM-DD)
    String tanggal = order['created_at'].toString().split('T')[0]; 
    
    // Tentukan Progress Value (0.0 - 1.0)
    double progress = 0.1;
    if (status == "Sedang Dicuci") progress = 0.25;
    else if (status == "Sedang Dijemur") progress = 0.50;
    else if (status == "Sedang Disetrika") progress = 0.75;
    else if (status == "Siap Diambil" || status == "Diantar Kurir") progress = 0.90;
    else if (status == "Selesai" || status == "Sampai Tujuan") progress = 1.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
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
                  color: const Color(0xFF1E64D8), // Biru Utama
                  strokeWidth: 6,
                ),
              ),
              Text(
                "${(progress * 100).toInt()}%",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E64D8),
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
                Text(
                  status,
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  "Dibuat: $tanggal",
                  style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF648DDB)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}