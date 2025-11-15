import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:demo3bismillah/app/modules/modul3/modul3_controller.dart';
import 'package:demo3bismillah/app/modules/widgets/experiment_card.dart'; // Widget ini tetap dipakai

class HomeScreen extends GetView<Modul3Controller> {
  HomeScreen({super.key});

  final coolGradient = LinearGradient(
    colors: [Colors.blue.shade600, Colors.teal.shade400],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: coolGradient),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), 
          onPressed: () => context.pop(),
        ),
        title: const Text('Modul 3 - Laundry Logistics'), 
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExperimentCard(
              title: "Eksperimen 1: Proses Pemesanan",
              description:
                  "Membandingkan 'http' vs 'dio' untuk mengambil data Pelanggan (Mock) dan Lokasi (API) secara bersamaan. Cek console untuk log Dio.", // Deskripsi diubah
              button1Label: "Run HTTP Order",
              onButton1Pressed: controller.runHttpExperiment,
              isLoading1: controller.isHttpLoading,
              result1: controller.httpResult,
              button2Label: "Run Dio Order",
              onButton2Pressed: controller.runDioExperiment,
              isLoading2: controller.isDioLoading,
              result2: controller.dioResult,
            ),
            
            // --- EKSPERIMEN 3 ---
            ExperimentCard(
              title: "Eksperimen 2: Rute Pengiriman", 
              description:
                  "Membandingkan 'async/await' vs 'callback' untuk skenario chained request (Mencari rute pengiriman dari Jerman ke negara tetangga).", 
              button1Label: "Run Async/Await Route",
              onButton1Pressed: controller.runAsyncAwaitChained,
              isLoading1: controller.isAsyncAwaitLoading,
              result1: controller.asyncAwaitResult,
              button2Label: "Run Callback Route",
              onButton2Pressed: controller.runCallbackChained,
              isLoading2: controller.isCallbackLoading,
              result2: controller.callbackResult,
            ),
          ],
        ),
      ),
    );
  }
}