import 'package:demo3bismillah/app/data/models/customer_model.dart';

class MockCustomerService {
  // Simulasi pengambilan data pelanggan dari database/API internal
  Future<Customer> getCustomer(String name) async {
    // Simulasi network delay
    await Future.delayed(const Duration(milliseconds: 150));
    
    if (name == 'Muhammad Yusron') {
      return Customer(
          name: 'Muhammad Yusron (333)',
          address: 'Jl. Raya Tlogomas 246');
    }
    return Customer(name: name, address: 'Alamat tidak diketahui');
  }
}