import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatMessage {
  final String text;
  final bool isSender;
  final String time;

  ChatMessage({required this.text, required this.isSender, required this.time});
}

class ChatController extends GetxController {
  final messageC = TextEditingController();
  final scrollC = ScrollController();
  
  var messages = <ChatMessage>[
    ChatMessage(text: "ada yang bisa saya bantu?", isSender: false, time: "09:41"),
  ].obs;

  @override
  void onClose() {
    messageC.dispose();
    scrollC.dispose();
    super.onClose();
  }

  void sendMessage() {
    if (messageC.text.isEmpty) return;

    messages.add(
      ChatMessage(
        text: messageC.text, 
        isSender: true, 
        time: "${DateTime.now().hour}:${DateTime.now().minute}"
      )
    );
    
    String userMessage = messageC.text; // Simpan teks untuk logika balasan
    messageC.clear();
    
    // Scroll ke paling bawah
    Future.delayed(Duration(milliseconds: 100), () {
      if (scrollC.hasClients) {
        scrollC.animateTo(scrollC.position.maxScrollExtent, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });

    // 2. Simulasi Balasan Admin (Mock Reply)
    Future.delayed(const Duration(seconds: 1), () {
      String reply = "Terima kasih sudah menghubungi Raja Laundry.";
      
      // Logika balasan sederhana
      if (userMessage.toLowerCase().contains("buka")) {
        reply = "Hari ini laundry buka kak, jam 08.00 - 21.00 WIB.";
      } else if (userMessage.toLowerCase().contains("pesanan")) {
        reply = "Untuk pesanan kakak masih diproses untuk disetrika kak.";
      }

      messages.add(
        ChatMessage(
          text: reply, 
          isSender: false, 
          time: "${DateTime.now().hour}:${DateTime.now().minute}"
        )
      );
      
      // Scroll lagi setelah admin membalas
      if (scrollC.hasClients) {
        scrollC.animateTo(scrollC.position.maxScrollExtent, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }
}