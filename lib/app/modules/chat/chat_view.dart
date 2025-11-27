import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'chat_controller.dart';

class ChatView extends StatelessWidget {
  // Karena kita panggil manual di Dashboard, kita inject controller di sini jika belum ada
  final ChatController controller = Get.put(ChatController());

  ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false, // Hilangkan back button default
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF2E3192), Color(0xFF1BFFFF)]), // Gradasi Biru
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            "Customer Service",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // --- AREA CHAT ---
          Expanded(
            child: Obx(() => ListView.builder(
              controller: controller.scrollC,
              padding: const EdgeInsets.all(20),
              itemCount: controller.messages.length,
              itemBuilder: (context, index) {
                final msg = controller.messages[index];
                return _buildChatBubble(msg);
              },
            )),
          ),

          // --- AREA INPUT ---
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: msg.isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Logo Admin (Kiri)
          if (!msg.isSender)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Image.asset('assets/logorajalaundry.png', width: 30, height: 30), 
            ),

          // BUBBLE
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF8C9EFF).withOpacity(0.8), 
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: Radius.circular(msg.isSender ? 12 : 0), 
                  bottomRight: Radius.circular(msg.isSender ? 0 : 12),
                ),
              ),
              child: Text(
                msg.text,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
              ),
            ),
          ),

          // Avatar User (Kanan)
          if (msg.isSender)
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: const CircleAvatar(
                radius: 15,
                backgroundImage: AssetImage('assets/profile_placeholder.png'), // Ganti dengan aset profilmu
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: SafeArea(
        child: Row(
          children: [
            // Icon Gallery & Camera
            IconButton(icon: const Icon(Icons.image_outlined, color: Colors.black87), onPressed: () {}),
            IconButton(icon: const Icon(Icons.camera_alt_outlined, color: Colors.black87), onPressed: () {}),
            
            const SizedBox(width: 8),

            // Text Field
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: controller.messageC,
                  decoration: InputDecoration(
                    hintText: "Kirim Pesan",
                    hintStyle: GoogleFonts.poppins(color: Colors.grey),
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send, color: Colors.black87),
                      onPressed: () => controller.sendMessage(),
                    ),
                  ),
                  onSubmitted: (_) => controller.sendMessage(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}