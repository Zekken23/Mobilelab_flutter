import 'package:get/get.dart';
import 'package:demo3bismillah/app/data/profiders/dio_service.dart';
import 'package:demo3bismillah/app/data/profiders/http_service.dart';
import 'package:demo3bismillah/app/data/profiders/mock_customer_service.dart'; 
import 'package:demo3bismillah/app/data/services/api_service_interface.dart';
import 'package:demo3bismillah/app/modules/modul3/modul3_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Mendaftarkan service dengan tag, agar bisa dipanggil spesifik
    Get.lazyPut<ApiServiceInterface>(() => HttpService(), tag: 'http');
    Get.lazyPut<ApiServiceInterface>(() => DioService(), tag: 'dio');

    // Mendaftarkan service customer (mock)
    Get.lazyPut(() => MockCustomerService()); // DI TAMBAHKAN

    // Mendaftarkan controller dan meng-inject semua service
    Get.lazyPut(() => Modul3Controller(
          httpService: Get.find(tag: 'http'),
          dioService: Get.find(tag: 'dio'),
          customerService: Get.find(), // DI TAMBAHKAN
        ));
  }
}