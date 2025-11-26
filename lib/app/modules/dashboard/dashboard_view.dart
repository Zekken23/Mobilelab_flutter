// dashboard_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_pages.dart';
import 'dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hi, Enno Penas", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [IconButton(icon: Icon(Icons.notifications, color: Colors.orange), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(decoration: InputDecoration(hintText: "Search for service...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none), filled: true, fillColor: Colors.white)),
            SizedBox(height: 20),
            
            // Services Grid
            Text("Services", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildServiceItem("Cuci Basah", Icons.local_laundry_service),
                _buildServiceItem("Cuci Kering", Icons.dry_cleaning),
                _buildServiceItem("Setrika", Icons.iron),
              ],
            ),
            
            // Banner
            SizedBox(height: 20),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(15)),
              child: Center(child: Text("Promo Banner Here")),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Booking'), // Navigasi ke Order
        ],
        onTap: (index) {
          if (index == 1) Get.toNamed(Routes.ORDER);
        },
      ),
    );
  }

  Widget _buildServiceItem(String title, IconData icon) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
          child: Icon(icon, size: 40, color: Colors.blue),
        ),
        SizedBox(height: 5),
        Text(title)
      ],
    );
  }
}