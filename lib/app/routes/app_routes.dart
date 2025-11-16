import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX
import 'package:go_router/go_router.dart';
import 'package:demo3bismillah/app/data/providers/auth_provider.dart'; 
import 'dart:async'; 
import 'package:demo3bismillah/app/modules/laundry_home/laundry_home_binding.dart';
import 'package:demo3bismillah/app/modules/laundry_home/laundry_home_screen.dart';
// --- IMPORT YANG HILANG (PERBAIKAN) ---
import 'package:demo3bismillah/app/modules/modul3/modul3_binding.dart';
import 'package:demo3bismillah/app/modules/modul3/modul3_screen.dart';
// -------------------------------------
import 'package:demo3bismillah/app/modules/new_order/new_order_binding.dart';
import 'package:demo3bismillah/app/modules/new_order/new_order_screen.dart';
// Import halaman Auth BARU
import 'package:demo3bismillah/app/modules/auth/auth_binding.dart';
import 'package:demo3bismillah/app/modules/auth/login_screen.dart';
import 'package:demo3bismillah/app/modules/auth/register_screen.dart';

class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: '/login', // Mulai di login untuk pengecekan awal
    
    // Ini akan auto-refresh GoRouter saat status auth berubah
    refreshListenable:
        GoRouterRefreshStream(Get.find<AuthProvider>().authStateChanges),

    routes: [
      // Rute Halaman Utama (Dashboard)
      GoRoute(
        path: '/',
        builder: (context, state) {
          LaundryHomeBinding().dependencies();
          return LaundryHomeScreen(); // <-- HAPUS CONST
        },
      ),
      
      // Rute Halaman Modul 3
      GoRoute(
        path: '/modul3',
        builder: (context, state) {
          HomeBinding().dependencies();
          return HomeScreen();
        },
      ),

      // Rute Halaman Pesanan Baru
      GoRoute(
        path: '/new-order',
        builder: (context, state) {
          NewOrderBinding().dependencies();
          return NewOrderScreen(); // <-- HAPUS CONST
        },
      ),

      // --- RUTE AUTH BARU ---
      GoRoute(
        path: '/login',
        builder: (context, state) {
          AuthBinding().dependencies();
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) {
          AuthBinding().dependencies();
          return const RegisterScreen();
        },
      ),
    ],

    // --- LOGIKA REDIRECT PENTING ---
    redirect: (BuildContext context, GoRouterState state) {
      final authProvider = Get.find<AuthProvider>();
      final bool loggedIn = authProvider.isAuthenticated;
      
      final bool loggingIn = state.matchedLocation == '/login' ||
                             state.matchedLocation == '/register';

      if (!loggedIn) {
        return loggingIn ? null : '/login';
      }

      if (loggingIn) {
        return '/';
      }

      return null;
    },
  );
}

// Helper class untuk membuat GoRouter mendengarkan Stream
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription =
        stream.asBroadcastStream().listen((dynamic _) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _subscription;
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}