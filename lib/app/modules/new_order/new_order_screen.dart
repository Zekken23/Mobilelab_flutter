import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
// Import controller HANYA SATU KALI
import 'package:demo3bismillah/app/modules/new_order/new_order_controller.dart';
// import 'new_order_controller.dart'; // <-- Ini duplikat, dihapus

class NewOrderScreen extends GetView<NewOrderController> {
  NewOrderScreen({super.key});

  final coolGradient = LinearGradient(
    colors: [Colors.blue.shade600, Colors.teal.shade400],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Pesanan Baru', style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: coolGradient),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: controller.formKey, // Hubungkan form dengan formKey di controller
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // --- Field Nama ---
            TextFormField(
              controller: controller.nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Pelanggan',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // --- Field Alamat ---
            TextFormField(
              controller: controller.addressController,
              decoration: const InputDecoration(
                labelText: 'Alamat Penjemputan',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Alamat tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // --- Field No Telepon ---
            TextFormField(
              controller: controller.phoneController,
              decoration: const InputDecoration(
                labelText: 'No. Telepon',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'No. Telepon tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // --- [DITAMBAHKAN] Pilihan Jenis Layanan ---
            Text(
              'Jenis Layanan',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Obx(() => DropdownButtonFormField<String>(
                  value: controller.selectedLaundryType.value,
                  items: controller.laundryTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: controller.setLaundryType,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.local_laundry_service),
                  ),
                )),
            // ------------------------------------

            const SizedBox(height: 24),

            // --- Pilihan Pembayaran ---
            Text(
              'Metode Pembayaran',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            // Gunakan Obx untuk listen perubahan di controller
            Obx(() => Column(
                  children: [
                    RadioListTile<PaymentMethod>(
                      title: const Text('QRIS'),
                      subtitle: const Text('Pembayaran instan pakai QR'),
                      value: PaymentMethod.qris,
                      groupValue: controller.paymentMethod.value,
                      onChanged: controller.setPaymentMethod,
                    ),
                    RadioListTile<PaymentMethod>(
                      title: const Text('Transfer Bank'),
                      subtitle: const Text('Transfer manual ke rekening VA'),
                      value: PaymentMethod.transfer,
                      groupValue: controller.paymentMethod.value,
                      onChanged: controller.setPaymentMethod,
                      // Anda bisa ganti ini jadi 'Tunai (COD)' jika mau
                    ),
                  ],
                )),
            const SizedBox(height: 32),

            // --- [DIPERBARUI] Tombol Submit dengan Loading ---
            Container(
              decoration: BoxDecoration(
                gradient: coolGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Obx(() => ElevatedButton( // Dibungkus Obx
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      // Nonaktifkan tombol jika isLoading == true
                      disabledBackgroundColor: Colors.grey.withOpacity(0.5),
                    ),
                    // Set onPressed ke null jika loading,
                    // atau panggil controller.submitOrder jika tidak
                    onPressed: controller.isLoading.value ? null : controller.submitOrder,
                    child: controller.isLoading.value
                        ? const SizedBox( // Tampilkan Indikator Loading
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                          )
                        : const Text( // Teks tombol
                            'Buat Pesanan',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  )),
            ),
            // ------------------------------------------
          ],
        ),
      ),
    );
  }
}