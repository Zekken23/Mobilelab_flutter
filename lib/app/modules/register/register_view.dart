import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'register_controller.dart';

class RegisterView extends StatelessWidget {
  // Inject Controller
  final RegisterController controller = Get.put(RegisterController());

  RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE0F7FA), 
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER LOGO ---
            const SizedBox(height: 20),
            Center(
              child: Image.asset(
                'assets/logorajalaundry.png', 
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20),

            // --- FORM CARD (Putih Rounded) ---
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul
                      Text(
                        "Welcome",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 1. INPUT NAMA
                      _buildLabel("Nama"),
                      _buildTextField(
                        controller: controller.namaC,
                        hint: "Muhammad Yusron...",
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 15),

                      // 2. INPUT NO HP
                      _buildLabel("No Hp / (Whats app)"),
                      _buildTextField(
                        controller: controller.noHpC,
                        hint: "08123456789",
                        icon: Icons.phone_outlined,
                        inputType: TextInputType.phone,
                      ),
                      const SizedBox(height: 15),

                      // 3. INPUT ALAMAT
                      _buildLabel("Alamat"),
                      _buildTextField(
                        controller: controller.alamatC,
                        hint: "tuliskan alamat mu disini",
                        icon: Icons.receipt_long_outlined, // Icon mirip struk/tiket di gambar
                        maxLines: 2,
                      ),
                      const SizedBox(height: 15),

                      // 4. INPUT EMAIL
                      _buildLabel("Email"),
                      _buildTextField(
                        controller: controller.emailC,
                        hint: "Enter your mail",
                        icon: Icons.mail_outline,
                        inputType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 15),

                      // 5. INPUT PASSWORD
                      _buildLabel("Password"),
                      Obx(() => TextField(
                        controller: controller.passC,
                        obscureText: controller.isObscure.value,
                        decoration: InputDecoration(
                          hintText: "Enter your password",
                          hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
                          prefixIcon: const Icon(Icons.lock_outline, color: Colors.black),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isObscure.value ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () => controller.isObscure.toggle(),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      )),
                      
                      const SizedBox(height: 30),

                      // 6. TOMBOL SIGN UP
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: Obx(() => ElevatedButton(
                          onPressed: controller.isLoading.value ? null : controller.register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E64D8), // Warna Biru tombol
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: controller.isLoading.value
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  "Create Account", // Saya ganti "Log In" jadi Create Account agar logis
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        )),
                      ),

                      // 7. FOOTER LOGIN
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Expanded(child: Divider(thickness: 1.5)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text("Or", style: GoogleFonts.poppins()),
                          ),
                          const Expanded(child: Divider(thickness: 1.5)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Have an account? ", style: GoogleFonts.poppins()),
                          GestureDetector(
                            onTap: () => Get.back(), // Kembali ke Login
                            child: Text(
                              "Log In",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPER UNTUK TEXTFIELD ---
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: inputType,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
        prefixIcon: Icon(icon, color: Colors.black),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black87),
        ),
      ),
    );
  }
}