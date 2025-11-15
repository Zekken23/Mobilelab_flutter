import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:demo3bismillah/app/modules/laundry_home/laundry_home_controller.dart';

class LaundryHomeScreen extends GetView<LaundryHomeController> {
  LaundryHomeScreen ({super.key});

  final coolGradient = LinearGradient(
    colors: [Colors.blue.shade600, Colors.teal.shade400],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laundry Logistics Dashboard', style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: coolGradient),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white), // Ubah warna ikon
            onPressed: () {},
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Selamat Datang, Yusron!',
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            'Lihat status pesanan dan pengiriman Anda.',
            style: textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // --- Bagian Peta OpenStreetMap ---
          _buildMapSection(textTheme),
          
          const SizedBox(height: 24),
          
          // --- Bagian Navigasi Modul 3 ---
          _buildModuleCard(context, textTheme),

          const SizedBox(height: 24),

          // --- Bagian Statistik ---
          Text(
            'Statistik Laundry',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildStatsGrid(),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: coolGradient,
          borderRadius: BorderRadius.circular(50), // Sesuaikan dengan bentuk FAB
        ),
        child: FloatingActionButton.extended(
          // Buat FAB transparan agar gradient di container terlihat
          backgroundColor: Colors.transparent,
          elevation: 0,
          onPressed: () {
            context.push('/new-order');
          },
          label: const Text('Pesanan Baru', style: TextStyle(color: Colors.white)),
          icon: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  // Widget untuk Peta
  Widget _buildMapSection(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lokasi Pesanan Aktif',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 250,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Obx(
              () => FlutterMap(
                options: MapOptions(
                  initialCenter: controller.ummLocation,
                  initialZoom: 15.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.demo3bismillah',
                  ),
                  MarkerLayer(
                    markers: controller.markers.toList(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget untuk Navigasi ke Modul 3
  Widget _buildModuleCard(BuildContext context, TextTheme textTheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Navigasi ke Halaman Modul 3 menggunakan GoRouter
          context.push('/modul3');
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.science_outlined, color: Theme.of(context).primaryColor, size: 40),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halaman Eksperimen Modul 3',
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tes performa API (http vs dio) & Async.',
                      style: textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk Grid Statistik
  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Selesai', '12', Icons.check_circle_outline, Colors.green),
        Obx(() => _buildStatCard(
              'Diproses',
              controller.processingOrders.value.toString(), 
              Icons.pending_actions_outlined,
              Colors.orange,
            )),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}