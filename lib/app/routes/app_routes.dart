import 'package:go_router/go_router.dart';
import 'package:demo3bismillah/app/modules/laundry_home/laundry_home_binding.dart';
import 'package:demo3bismillah/app/modules/laundry_home/laundry_home_screen.dart';
import 'package:demo3bismillah/app/modules/modul3/modul3_binding.dart';
import 'package:demo3bismillah/app/modules/modul3/modul3_screen.dart';
import 'package:demo3bismillah/app/modules/new_order/new_order_binding.dart';
import 'package:demo3bismillah/app/modules/new_order/new_order_screen.dart';

class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: '/', // Mulai dari Halaman Utama Laundry
    routes: [
      // Rute Halaman Utama
      GoRoute(
        path: '/',
        builder: (context, state) {
          // Mengikat controller ke view menggunakan GetX Binding
          LaundryHomeBinding().dependencies();
          return LaundryHomeScreen();
        },
      ),
      // Rute Halaman Modul 3
      GoRoute(
        path: '/modul3',
        builder: (context, state) {
          // Mengikat controller ke view menggunakan GetX Binding
          HomeBinding().dependencies();
          return HomeScreen();
        },
      ),
      GoRoute(
        path: '/new-order',
        builder: (context, state) {
          NewOrderBinding().dependencies();
          return NewOrderScreen();
        },
      ),
    ],
  );
}