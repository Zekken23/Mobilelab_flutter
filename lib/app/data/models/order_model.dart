import 'package:demo3bismillah/app/data/models/country_model.dart';
import 'package:demo3bismillah/app/data/models/customer_model.dart';

// Model untuk "Pemesanan"
// Menggabungkan data pelanggan (mock) dan data lokasi (API)
class Order {
  final Customer customer;
  final Country location;

  Order({required this.customer, required this.location});
}

class OrderModel {
  final int? id;
  final String customerName;
  final String phone;
  final String address;
  final String laundryType; 
  final String paymentMethod;
  final String status;
  final DateTime? createdAt;

  OrderModel({
    this.id,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.laundryType,
    required this.paymentMethod,
    this.status = 'Diproses',
    this.createdAt,
  });

  // Konversi dari JSON (Supabase) ke Object Dart
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'],
      customerName: json['customer_name'],
      phone: json['phone'],
      address: json['address'],
      laundryType: json['laundry_type'],
      paymentMethod: json['payment_method'],
      status: json['status'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  // Konversi dari Object Dart ke JSON (untuk dikirim ke Supabase)
  Map<String, dynamic> toJson() {
    return {
      'customer_name': customerName,
      'phone': phone,
      'address': address,
      'laundry_type': laundryType,
      'payment_method': paymentMethod,
      'status': status,
    };
  }
}