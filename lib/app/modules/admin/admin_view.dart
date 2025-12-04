import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'admin_controller.dart';

class AdminView extends StatelessWidget {
  const AdminView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject Controller
    final controller = Get.put(AdminController());

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        // Judul berubah dinamis sesuai Tab yang dipilih
        title: Obx(() {
          if (controller.tabIndex.value == 0) return Text("Pesanan Aktif", style: GoogleFonts.poppins(fontWeight: FontWeight.bold));
          if (controller.tabIndex.value == 1) return Text("Riwayat Pesanan", style: GoogleFonts.poppins(fontWeight: FontWeight.bold));
          return Text("Pengaturan Admin", style: GoogleFonts.poppins(fontWeight: FontWeight.bold));
        }),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          // Tombol Refresh hanya muncul di tab Pesanan
          Obx(() => controller.tabIndex.value != 2 
            ? IconButton(icon: const Icon(Icons.refresh), onPressed: controller.fetchAllOrders)
            : const SizedBox.shrink()
          ),
        ],
      ),
      
      // --- BODY DENGAN 3 HALAMAN (AKTIF, RIWAYAT, PENGATURAN) ---
      body: Obx(() => IndexedStack(
        index: controller.tabIndex.value,
        children: [
          // HALAMAN 1: DASHBOARD (Pesanan Aktif)
          _buildOrderList(controller.activeOrders, controller, 
            isEmptyMessage: "Tidak ada pesanan aktif saat ini"),
          
          // HALAMAN 2: HISTORY (Pesanan Selesai/Diantar)
          _buildOrderList(controller.historyOrders, controller, 
            isEmptyMessage: "Belum ada riwayat pesanan"),
          
          // HALAMAN 3: SETTINGS (Profile Admin)
          _buildSettingsPage(context, controller),
        ],
      )),

      // --- BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: controller.tabIndex.value,
        onTap: controller.changeTabIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: "Aktif"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Riwayat"),
          BottomNavigationBarItem(icon: Icon(Icons.manage_accounts_outlined), activeIcon: Icon(Icons.manage_accounts), label: "Akun"),
        ],
      )),
    );
  }

  // --- WIDGET: LIST PESANAN (Dipakai untuk Aktif & Riwayat) ---
  Widget _buildOrderList(List<Map<String, dynamic>> orders, AdminController controller, {required String isEmptyMessage}) {
    if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
    
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text(isEmptyMessage, style: GoogleFonts.poppins(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(context, orders[index], controller);
      },
    );
  }

  // --- WIDGET: KARTU PESANAN ---
  Widget _buildOrderCard(BuildContext context, Map<String, dynamic> item, AdminController controller) {
    String status = item['status'] ?? "-";
    
    // Logika Warna Status
    Color statusColor = Colors.orange;
    if (status == 'Siap Diambil') statusColor = Colors.green;
    if (status == 'Sedang Disetrika') statusColor = Colors.purple;
    if (status == 'Diantar Kurir') statusColor = Colors.blue;
    if (status == 'Sampai Tujuan' || status == 'Selesai') statusColor = Colors.grey;

    String tglMasuk = item['tgl_ambil'] ?? "-";
    String tglSelesai = item['tgl_antar'] ?? "-";
    bool isDelivery = tglSelesai.toLowerCase() != "ambil sendiri"; 
    String namaKurir = item['nama_kurir'] ?? "-"; 

    // Cek apakah pesanan sudah selesai (untuk menyembunyikan tombol update)
    bool isCompleted = status == 'Selesai' || status == 'Sampai Tujuan';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Nama & Status Chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item['nama'] ?? "No Name", 
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                    overflow: TextOverflow.ellipsis, maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(status, style: GoogleFonts.poppins(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11)),
                ),
              ],
            ),
            const Divider(height: 25),
            
            // Detail Pesanan
            _rowDetail(Icons.local_laundry_service, "Layanan", item['layanan'] ?? "-"),
            _rowDetail(Icons.note, "Items", item['berat_items'] ?? "-"),
            _rowDetail(Icons.location_on, "Alamat", item['alamat_lengkap'] ?? "-"),
            
            const SizedBox(height: 12),
            
            // Info Tanggal
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _columnDate("Masuk", tglMasuk, Colors.blue),
                  Container(width: 1, height: 30, color: Colors.grey.shade300),
                  _columnDate("Estimasi", tglSelesai, Colors.red),
                ],
              ),
            ),

            const SizedBox(height: 10),
            
            // Info Pengantaran (Jika ada delivery)
            if (isDelivery) 
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.motorcycle, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text("Kurir: $namaKurir", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue.shade800)),
                  ],
                ),
              ),

            // Tombol Update (Disembunyikan jika sudah selesai)
            if (!isCompleted)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => _showStatusBottomSheet(context, item['id'], controller),
                  child: const Text("Update Status", style: TextStyle(color: Colors.white)),
                ),
              )
          ],
        ),
      ),
    );
  }

  // --- HALAMAN PENGATURAN (TAB 3) ---
  Widget _buildSettingsPage(BuildContext context, AdminController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 50, backgroundColor: Colors.blueAccent, child: Icon(Icons.admin_panel_settings, size: 50, color: Colors.white)),
            const SizedBox(height: 20),
            Text("Admin Panel", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("admin@rajacuci.com", style: GoogleFonts.poppins(color: Colors.grey)),
            const SizedBox(height: 40),
            
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.email, color: Colors.blue),
                    title: const Text("Ganti Email Login"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showChangeEmailDialog(controller),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.lock, color: Colors.orange),
                    title: const Text("Ganti Password"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showChangePasswordDialog(controller),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: controller.logout,
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text("Logout", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              ),
            )
          ],
        ),
      ),
    );
  }

  // --- HELPER UI ---
  Widget _rowDetail(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          SizedBox(width: 60, child: Text(label, style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600))),
          Expanded(child: Text(": $value", style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _columnDate(String label, String date, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)),
        Text(date, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  // --- BOTTOM SHEET UPDATE STATUS ---
  void _showStatusBottomSheet(BuildContext context, int id, AdminController controller) {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 20),
              Text("Update Progress Laundry", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 15),
              
              _statusButton("Sedang Dicuci", Colors.blue, id, controller),
              _statusButton("Sedang Dijemur", Colors.orange, id, controller),
              _statusButton("Sedang Disetrika", Colors.purple, id, controller),
              _statusButton("Siap Diambil", Colors.green, id, controller),
              
              const Divider(height: 30),
              Text("Pengiriman / Selesai", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 15),
              
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.motorcycle, color: Colors.blue)),
                title: Text("Diantar Kurir", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showCourierInputDialog(context, id, controller),
              ),
              
              _statusButton("Sampai Tujuan", Colors.teal, id, controller, icon: Icons.home),
              _statusButton("Selesai (Sudah Diambil)", Colors.grey, id, controller, value: "Selesai", icon: Icons.check_circle),
            ],
          ),
        ),
      ),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20)))
    );
  }

  Widget _statusButton(String label, Color color, int id, AdminController controller, {String? value, IconData? icon}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon ?? Icons.circle, color: color, size: 20),
      ),
      title: Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
      onTap: () => controller.updateStatus(id, value ?? label),
    );
  }

  void _showCourierInputDialog(BuildContext context, int id, AdminController controller) {
    controller.courierC.clear();
    Get.defaultDialog(
      title: "Nama Kurir",
      content: Padding(padding: const EdgeInsets.all(10), child: TextField(controller: controller.courierC, decoration: const InputDecoration(hintText: "Contoh: Budi", border: OutlineInputBorder()))),
      textConfirm: "Simpan", confirmTextColor: Colors.white, buttonColor: Colors.blue,
      onConfirm: () {
        if(controller.courierC.text.isNotEmpty) controller.updateStatus(id, "Diantar Kurir", namaKurir: controller.courierC.text);
      },
      textCancel: "Batal"
    );
  }

  void _showChangeEmailDialog(AdminController controller) {
    controller.emailC.clear();
    Get.defaultDialog(
      title: "Ganti Email", content: Padding(padding: const EdgeInsets.all(10), child: TextField(controller: controller.emailC, decoration: const InputDecoration(labelText: "Email Baru"))),
      textConfirm: "Simpan", confirmTextColor: Colors.white, onConfirm: controller.updateEmail, textCancel: "Batal"
    );
  }

  void _showChangePasswordDialog(AdminController controller) {
    controller.passC.clear();
    Get.defaultDialog(
      title: "Ganti Password", content: Padding(padding: const EdgeInsets.all(10), child: TextField(controller: controller.passC, obscureText: true, decoration: const InputDecoration(labelText: "Password Baru"))),
      textConfirm: "Simpan", confirmTextColor: Colors.white, onConfirm: controller.updatePassword, textCancel: "Batal"
    );
  }
}