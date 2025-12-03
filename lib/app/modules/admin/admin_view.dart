import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_controller.dart';

class AdminView extends StatelessWidget {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminController());

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: Text("Admin Dashboard", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: controller.fetchAllOrders),
          IconButton(icon: const Icon(Icons.logout, color: Colors.red), onPressed: controller.logout),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
        if (controller.orders.isEmpty) return const Center(child: Text("Belum ada pesanan masuk"));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.orders.length,
          itemBuilder: (context, index) {
            final item = controller.orders[index];
            return _buildOrderCard(context, item, controller);
          },
        );
      }),
    );
  }

  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> item, AdminController controller) {
    Color statusColor = Colors.orange;
    if (item['status'] == 'Siap Diambil') statusColor = Colors.green;
    if (item['status'] == 'Sedang Disetrika') statusColor = Colors.purple;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item['nama'] ?? "No Name", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(item['status'] ?? "-", style: GoogleFonts.poppins(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const Divider(),
            Text("Layanan: ${item['layanan']}"),
            Text("Items: ${item['berat_items']}"),
            Text("Alamat: ${item['alamat_lengkap']}", maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: () => _showStatusBottomSheet(context, item['id'], controller),
                child: const Text("Update Status", style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showStatusBottomSheet(BuildContext context, int id, AdminController controller) {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Pilih Status Baru", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 20),
            _statusButton("Sedang Dicuci", Colors.blue, id, controller),
            _statusButton("Sedang Dijemur", Colors.orange, id, controller),
            _statusButton("Sedang Disetrika", Colors.purple, id, controller),
            _statusButton("Siap Diambil", Colors.green, id, controller),
          ],
        ),
      ),
    );
  }

  Widget _statusButton(String status, Color color, int id, AdminController controller) {
    return ListTile(
      leading: Icon(Icons.circle, color: color, size: 15),
      title: Text(status),
      onTap: () => controller.updateStatus(id, status),
    );
  }
}