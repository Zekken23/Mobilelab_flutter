import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:demo5/app/routes/app_pages.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Load Environment Variables
  await dotenv.load(fileName: ".env");

  // 2. Inisialisasi Supabase
  // Pastikan key sudah ada di file .env agar aman
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // 3. Jalankan App
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Raja Cuci Laundry",
      debugShowCheckedModeBanner: false,
      
      // KONFIGURASI ROUTING GETX
      initialRoute: AppPages.INITIAL, // Biasanya mengarah ke Routes.SPLASH
      getPages: AppPages.routes,      // Mengambil daftar halaman dari app_pages.dart
      
      // KONFIGURASI TEMA
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        // Warna background global (sesuai request desain biru muda)
        scaffoldBackgroundColor: const Color(0xFFEDF9FD),
        fontFamily: 'Poppins', // Opsional: Jika ingin font seperti di desain
      ),
    );
  }
}