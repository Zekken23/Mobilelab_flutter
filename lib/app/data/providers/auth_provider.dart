import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:demo3bismillah/app/data/services/supabase_service.dart';

class AuthProvider extends GetxService {
  final SupabaseClient _client = Get.find<SupabaseService>().client;

  // Cek apakah pengguna sedang login
  bool get isAuthenticated => _client.auth.currentUser != null;

  // Stream untuk mendengarkan perubahan status auth (login/logout)
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Fungsi Login
  Future<AuthResponse> login(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Fungsi Register
  Future<AuthResponse> register(String email, String password) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      // Supabase akan mengirim email konfirmasi
    );
  }

  // Fungsi Logout
  Future<void> logout() async {
    await _client.auth.signOut();
  }
}