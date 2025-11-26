import 'package:get/get.dart';
import '../modules/splash/splash_view.dart';
import '../modules/splash/splash_binding.dart';
import '../modules/login/login_view.dart';
import '../modules/login/login_binding.dart';
import '../modules/dashboard/dashboard_view.dart';
import '../modules/dashboard/dashboard_binding.dart';
import '../modules/order/order_view.dart';
import '../modules/order/order_binding.dart';

part 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(name: _Paths.SPLASH, page: () => SplashView(), binding: SplashBinding()),
    GetPage(name: _Paths.LOGIN, page: () => LoginView(), binding: LoginBinding()),
    GetPage(name: _Paths.DASHBOARD, page: () => DashboardView(), binding: DashboardBinding()),
    GetPage(name: _Paths.ORDER, page: () => OrderView(), binding: OrderBinding()),
  ];
}