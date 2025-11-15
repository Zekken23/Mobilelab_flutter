import 'package:get/get.dart';
import 'package:demo3bismillah/app/modules/laundry_home/laundry_home_controller.dart';

class LaundryHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LaundryHomeController(), fenix: true);
  }
}