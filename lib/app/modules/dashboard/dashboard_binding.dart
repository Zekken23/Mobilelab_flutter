import 'package:get/get.dart';
import 'dashboard_controller.dart';
import '../order/order_controller.dart'; 

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(
      () => DashboardController(),
    );
    Get.lazyPut<OrderController>(
      () => OrderController(),
    );
  }
}