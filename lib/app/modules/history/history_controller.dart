import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HistoryController extends GetxController {
  // Observable list untuk menampung data pesanan
  var myOrders = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyOrders();
  }

  // --- AMBIL DATA PESANAN MILIK USER ---
  Future<void> fetchMyOrders() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    isLoading.value = true;
    try {
      // Query ke tabel 'orders'
      final response = await Supabase.instance.client
          .from('orders')
          .select()
          .eq('user_id', user.id) // Filter berdasarkan User ID
          .order('created_at', ascending: false); // Urutkan dari terbaru
      
      myOrders.value = List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print("Error fetch history: $e");
    } finally {
      isLoading.value = false;
    }
  }
}