import 'package:demo5/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. BAGIAN ATAS (HEADER + LOGO)
          Container(
            height: MediaQuery.of(context).size.height * 0.45, // Setengah layar ke atas
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE0F7FA), Color(0xFF80DEEA)], // Gradient Biru Muda
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LOGO RAJA CUCI
                Image.asset(
                  'assets/logorajalaundry.png', // Pastikan asset logo sudah ada
                  width: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (c,e,s) => const Text("Logo Raja Cuci", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blue)),
                ),
              ],
            ),
          ),

          // 2. BAGIAN BAWAH (FORM LOGIN)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6, 
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  )
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    // --- HEADER TEXT ---
                    Text(
                      "Welcome back",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Continue your journey with Raja Cuci", 
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // --- EMAIL INPUT ---
                    Text(
                      "Email",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controller.emailC,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.email_outlined, color: Colors.black54),
                        hintText: "Masukan Email anda disini.",
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.blueAccent),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- PASSWORD INPUT ---
                    Text(
                      "Password",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Obx(() => TextField(
                      controller: controller.passC,
                      obscureText: controller.isObscure.value, 
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.black54),
                        suffixIcon: IconButton(
                          icon: Icon(
                            controller.isObscure.value ? Icons.visibility_off : Icons.visibility,
                            color: Colors.black54,
                          ),
                          onPressed: () => controller.isObscure.toggle(),
                        ),
                        hintText: "****************",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.blueAccent),
                        ),
                      ),
                    )),

                    // --- REMEMBER ME & FORGOT PASSWORD ---
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: false, 
                                onChanged: (val) {}, 
                                activeColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Remember me",
                              style: GoogleFonts.poppins(fontSize: 13),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            "Forgot your password?",
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- LOGIN BUTTON ---
                    Obx(() => SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value ? null : () => controller.login(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0), // Warna biru tua tombol
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? const SizedBox(
                                width: 20, height: 20, 
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                              )
                            : Text(
                                "Log In",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    )),

                    // --- DIVIDER OR ---
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Expanded(child: Divider(color: Colors.black, thickness: 1.5)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "Or",
                            style: GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.w500),
                          ),
                        ),
                        const Expanded(child: Divider(color: Colors.black, thickness: 1.5)),
                      ],
                    ),

                    // --- FOOTER CREATE ACCOUNT ---
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Dont have an account? ",
                          style: GoogleFonts.poppins(color: Colors.black87),
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.toNamed(Routes.REGISTER);
                          },
                          child: Text(
                            "Create Account",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20), // Jarak aman bawah
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}