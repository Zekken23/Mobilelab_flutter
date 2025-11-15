import 'package:flutter/material.dart';
import 'package:demo3bismillah/app/routes/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Laundry Logistics',
      theme: ThemeData(
        primaryColor: Colors.blue.shade600, 
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade600), 
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF0F2F5),
        cardTheme: CardThemeData(
          elevation: 1,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      routerConfig: AppRoutes.router,
    );
  }
}