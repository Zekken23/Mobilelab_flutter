import 'dart:async';
import 'package:get/get.dart';
import 'package:demo3bismillah/app/data/models/order_model.dart'; 
import 'package:demo3bismillah/app/data/profiders/mock_customer_service.dart'; 
import 'package:demo3bismillah/app/data/services/api_service_interface.dart';

class Modul3Controller extends GetxController {
  final ApiServiceInterface httpService;
  final ApiServiceInterface dioService;
  final MockCustomerService customerService; 

  // GANTI NAMA CONSTRUCTOR
  Modul3Controller({
    required this.httpService,
    required this.dioService,
    required this.customerService, 
  });

  // State untuk hasil eksperimen (tetap RxString untuk ditampilkan di UI)
  final RxString httpResult = "Tekan tombol untuk memulai...".obs;
  final RxString dioResult = "Tekan tombol untuk memulai...".obs;
  final RxString asyncAwaitResult = "Tekan tombol untuk memulai...".obs;
  final RxString callbackResult = "Tekan tombol untuk memulai...".obs;

  // State untuk loading
  final RxBool isHttpLoading = false.obs;
  final RxBool isDioLoading = false.obs;
  final RxBool isAsyncAwaitLoading = false.obs;
  final RxBool isCallbackLoading = false.obs;

  final Stopwatch _stopwatch = Stopwatch();

  // --- EKSPERIMEN 1: Performa "Pemesanan" (http vs Dio) ---
  // Skenario: Ambil data Pelanggan (mock) + data Lokasi (API)

  Future<void> runHttpExperiment() async {
    isHttpLoading(true);
    _stopwatch.reset();
    _stopwatch.start();
    try {
      // Menjalankan 2 panggilan async secara bersamaan
      final customerFuture = customerService.getCustomer('Muhammad Yusron');
      final countryFuture = httpService.fetchCountryByName('indonesia');

      // Menunggu keduanya selesai
      final customer = await customerFuture;
      final country = await countryFuture;

      final order = Order(customer: customer, location: country);
      _stopwatch.stop();

      // Memformat hasil untuk UI
      httpResult.value =
          "✅ [${_stopwatch.elapsedMilliseconds} ms] HTTP\n"
          "Pelanggan: ${order.customer.name}\n"
          "Lokasi: ${order.location.capital}, ${order.location.name}";
    } catch (e) {
      _stopwatch.stop();
      httpResult.value = "❌ [${_stopwatch.elapsedMilliseconds} ms] HTTP Error: $e";
    }
    isHttpLoading(false);
  }

  Future<void> runDioExperiment() async {
    isDioLoading(true);
    _stopwatch.reset();
    _stopwatch.start();
    try {
      // Menjalankan 2 panggilan async secara bersamaan
      final customerFuture = customerService.getCustomer('Muhammad Yusron');
      final countryFuture = dioService.fetchCountryByName('indonesia');

      // Menunggu keduanya selesai
      final customer = await customerFuture;
      final country = await countryFuture;

      final order = Order(customer: customer, location: country);
      _stopwatch.stop();

      // Memformat hasil untuk UI
      dioResult.value =
          "✅ [${_stopwatch.elapsedMilliseconds} ms] Dio\n"
          "Pelanggan: ${order.customer.name}\n"
          "Lokasi: ${order.location.capital}, ${order.location.name}";
    } catch (e) {
      _stopwatch.stop();
      dioResult.value = "❌ [${_stopwatch.elapsedMilliseconds} ms] Dio Error: $e";
    }
    isDioLoading(false);
  }

  // --- EKSPERIMEN 3: "Pengiriman" (Async/Await vs Callback) ---
  // Skenario: Ambil data lokasi 'Germany', lalu kirim ke negara tetangganya.

  // Versi 1: Async-Await (Linear & Readable)
  Future<void> runAsyncAwaitChained() async {
    isAsyncAwaitLoading(true);
    _stopwatch.reset();
    _stopwatch.start();
    try {
      // Panggilan pertama (Lokasi Asal)
      final country1 = await dioService.fetchCountryByName('germany');
      final borderCode = country1.border;

      if (borderCode == null) throw Exception("Tidak punya negara tetangga");

      // Panggilan kedua (Lokasi Tujuan Pengiriman)
      final country2 = await dioService.fetchCountryByCode(borderCode);
      _stopwatch.stop();

      asyncAwaitResult.value =
          "✅ [${_stopwatch.elapsedMilliseconds} ms] Rute Pengiriman (Async/Await):\n"
          "Dari: ${country1.name} (${country1.capital})\n"
          "Ke: ${country2.name} (${country2.capital})";
    } catch (e) {
      _stopwatch.stop();
      asyncAwaitResult.value =
          "❌ [${_stopwatch.elapsedMilliseconds} ms] Async/Await Error: $e";
    }
    isAsyncAwaitLoading(false);
  }

  // Versi 2: Callback Chaining (Nested & Hard to Read)
  void runCallbackChained() {
    isCallbackLoading(true);
    _stopwatch.reset();
    _stopwatch.start();

    // Panggilan pertama (Lokasi Asal)
    dioService.fetchCountryByNameCallback(
      'germany',
      (country1) {
        // Callback success pertama
        final borderCode = country1.border;
        if (borderCode == null) {
          _handleCallbackError("Tidak punya negara tetangga");
          return;
        }

        // Panggilan kedua (di dalam callback pertama)
        dioService.fetchCountryByCodeCallback(
          borderCode,
          (country2) {
            // Callback success kedua
            _stopwatch.stop();
            callbackResult.value =
                "✅ [${_stopwatch.elapsedMilliseconds} ms] Rute Pengiriman (Callback):\n"
                "Dari: ${country1.name} (${country1.capital})\n"
                "Ke: ${country2.name} (${country2.capital})";
            isCallbackLoading(false);
          },
          (error2) {
            _handleCallbackError(error2); // Error panggilan kedua
          },
        );
      },
      (error1) {
        _handleCallbackError(error1); // Error panggilan pertama
      },
    );
  }

  void _handleCallbackError(String error) {
    _stopwatch.stop();
    callbackResult.value =
        "❌ [${_stopwatch.elapsedMilliseconds} ms] Callback Error: $error";
    isCallbackLoading(false);
  }
}