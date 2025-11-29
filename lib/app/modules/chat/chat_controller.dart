import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart'; 

class ChatMessage {
  final String text;
  final bool isSender;
  final String time;

  ChatMessage({required this.text, required this.isSender, required this.time});
}

class ChatController extends GetxController {
  final messageC = TextEditingController();
  final scrollC = ScrollController();
  
  var isLoading = false.obs;

  var messages = <ChatMessage>[
    ChatMessage(
      text: "Halo! Selamat datang di Raja Laundry 👋\n\nAda yang bisa saya bantu?\n\nKetik:\n• 'harga' untuk info harga\n• 'jam buka' untuk jam operasional\n• 'layanan' untuk jenis layanan\n• 'admin' untuk hubungi admin", 
      isSender: false, 
      time: "09:41"
    ),
  ].obs;

  @override
  void onClose() {
    messageC.dispose();
    scrollC.dispose();
    super.onClose();
  }

  // ✅ KIRIM PESAN (KEYWORD BASED)
  Future<void> sendMessage() async {
    final text = messageC.text;
    if (text.trim().isEmpty) return;

    final now = DateTime.now();
    final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    
    // Tampilkan pesan user
    messages.add(ChatMessage(text: text, isSender: true, time: timeStr));
    messageC.clear();
    _scrollToBottom();

    // Simulasi typing delay
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 600));

    // Dapatkan response berdasarkan keyword
    final response = _getSmartResponse(text);
    
    messages.add(ChatMessage(text: response, isSender: false, time: timeStr));
    isLoading.value = false;
    _scrollToBottom();

    // Jika minta admin, muncul dialog
    if (_isAskingForAdmin(text)) {
      _showAdminDialog();
    }
  }

  // ✅ SMART KEYWORD MATCHING (Lebih Pintar)
  String _getSmartResponse(String text) {
    final msg = text.toLowerCase().trim();

    // === ADMIN / WHATSAPP ===
    if (_isAskingForAdmin(msg)) {
      return "Baik Kak! 😊\n\nUntuk bantuan lebih lanjut, silakan chat Admin kami langsung via WhatsApp ya.\n\nTombol WhatsApp akan muncul sebentar lagi.";
    }

    // === HARGA ===
    if (_containsAny(msg, ['harga', 'berapa', 'biaya', 'tarif', 'ongkos', 'price'])) {
      if (_containsAny(msg, ['kilat', 'cepat', 'express', 'instan'])) {
        return "💰 Harga Layanan Express:\n\n• Express (1 hari): Rp 8.000/kg\n• Super Express (6 jam): Rp 12.000/kg\n\nLayanan reguler tetap Rp 6.000/kg ya Kak.\n\nMau pesan yang mana? 😊";
      }
      if (_containsAny(msg, ['sepatu', 'shoes'])) {
        return "👟 Harga Cuci Sepatu:\n\n• Sepatu Sneakers: Rp 25.000/pasang\n• Sepatu Kulit: Rp 30.000/pasang\n• Sepatu Boots: Rp 35.000/pasang\n\nSudah termasuk deep cleaning ya Kak! ✨";
      }
      if (_containsAny(msg, ['karpet', 'carpet'])) {
        return "🏠 Harga Cuci Karpet:\n\nRp 15.000/m²\n\nGratis jemput & antar untuk minimal 3m² ya Kak!";
      }
      return "💰 Harga Layanan Raja Laundry:\n\n• Cuci Komplit: Rp 6.000/kg\n  (Cuci + Setrika + Wangi + Lipat)\n• Cuci Kering Only: Rp 4.000/kg\n• Setrika Only: Rp 3.000/kg\n\nMinimal 3kg ya Kak! 😊\n\nMau tanya layanan lain?";
    }

    // === JAM BUKA ===
    if (_containsAny(msg, ['jam', 'buka', 'tutup', 'kapan', 'operasional', 'senin', 'selasa', 'rabu', 'kamis', 'jumat', 'sabtu', 'minggu'])) {
      return "⏰ Jam Operasional Raja Laundry:\n\n📅 Setiap Hari (Senin - Minggu)\n🕐 08.00 - 21.00 WIB\n\nKami buka 7 hari seminggu tanpa libur ya Kak! 💪";
    }

    // === LAYANAN ===
    if (_containsAny(msg, ['layanan', 'jenis', 'service', 'apa saja', 'menu', 'paket'])) {
      return "📋 Layanan Raja Laundry:\n\n✅ Cuci Komplit (Cuci + Setrika)\n✅ Cuci Kering Only\n✅ Setrika Only\n✅ Cuci Sepatu\n✅ Cuci Karpet\n✅ Cuci Boneka\n✅ Cuci Tas\n\nAda juga layanan Express & Super Express! ⚡\n\nMau tanya detail yang mana Kak?";
    }

    // === CARA PESAN ===
    if (_containsAny(msg, ['pesan', 'order', 'cara', 'gimana', 'bagaimana', 'proses', 'booking'])) {
      return "📱 Cara Pesan Laundry:\n\n1️⃣ Hubungi Admin via WA (ketik 'admin')\n2️⃣ Sampaikan jenis layanan & alamat\n3️⃣ Driver kami jemput cucian Anda\n4️⃣ Proses laundry dimulai\n5️⃣ Selesai, kami antar kembali!\n\nGampang kan Kak? 😊";
    }

    // === LOKASI / ALAMAT ===
    if (_containsAny(msg, ['lokasi', 'alamat', 'dimana', 'tempat', 'address', 'map', 'maps'])) {
      return "📍 Lokasi Raja Laundry:\n\nJl. Veteran No. 45, Malang\n(Dekat Alun-Alun Kota)\n\n🚗 Kami juga melayani jemput antar!\nArea: Malang Kota & Sekitarnya\n\nMau dijemput? Hubungi Admin ya Kak (ketik 'admin') 😊";
    }

    // === LAMA PENGERJAAN ===
    if (_containsAny(msg, ['lama', 'selesai', 'berapa hari', 'proses', 'estimasi', 'durasi', 'waktu'])) {
      return "⏱️ Estimasi Pengerjaan:\n\n⭐ Reguler: 2-3 hari\n⚡ Express: 1 hari (+Rp 2.000/kg)\n🚀 Super Express: 6 jam (+Rp 6.000/kg)\n\nPilih yang sesuai kebutuhan Kak! 😊\n\nMau pesan? Ketik 'admin'";
    }

    // === STATUS PESANAN ===
    if (_containsAny(msg, ['status', 'track', 'pesanan', 'dimana cucian', 'cek', 'sudah', 'jadi'])) {
      return "📦 Cek Status Pesanan:\n\nUntuk cek status cucian Anda, silakan hubungi Admin kami via WhatsApp ya Kak.\n\nSertakan nama & no HP saat pesan agar lebih cepat dicek! 😊\n\nKetik 'admin' untuk lanjut.";
    }

    // === PEMBAYARAN ===
    if (_containsAny(msg, ['bayar', 'payment', 'transfer', 'cash', 'cod', 'dp'])) {
      return "💳 Metode Pembayaran:\n\n✅ Cash saat ambil\n✅ Transfer Bank (BCA, Mandiri)\n✅ E-Wallet (GoPay, OVO, DANA)\n✅ QRIS\n\nBayar setelah cucian selesai ya Kak! 😊\n\nAda yang mau ditanyakan lagi?";
    }

    // === PROMO / DISKON ===
    if (_containsAny(msg, ['promo', 'diskon', 'disc', 'murah', 'hemat', 'voucher'])) {
      return "🎉 Promo Bulan Ini:\n\n🔥 Cuci 10kg = GRATIS 1kg\n🎁 Member baru diskon 15%\n💯 Cuci 5x = 1x GRATIS!\n\nPromo berlaku sampai akhir bulan! 🚀\n\nMau daftar jadi member? Ketik 'admin'";
    }

    // === KELUHAN / KOMPLAIN ===
    if (_containsAny(msg, ['komplain', 'keluhan', 'rusak', 'hilang', 'salah', 'tidak puas', 'kecewa'])) {
      return "🙏 Mohon Maaf Kak,\n\nKami sangat menyesal jika ada ketidaknyamanan.\n\nUntuk keluhan atau komplain, silakan langsung hubungi Admin kami via WhatsApp ya agar bisa kami tangani dengan cepat.\n\nKetik 'admin' untuk lanjut.";
    }

    // === CUCI KHUSUS ===
    if (_containsAny(msg, ['boneka', 'doll', 'mainan'])) {
      return "🧸 Cuci Boneka:\n\nRp 15.000 - Rp 30.000/pcs\n(Tergantung ukuran)\n\nAman untuk semua jenis boneka! ✨\n\nMau cuci boneka? Ketik 'admin'";
    }
    if (_containsAny(msg, ['tas', 'bag', 'ransel', 'backpack'])) {
      return "👜 Cuci Tas:\n\n• Tas Kecil: Rp 15.000\n• Tas Sedang: Rp 25.000\n• Tas Besar/Ransel: Rp 35.000\n\nSudah termasuk pembersihan dalam & luar! 💼";
    }
    if (_containsAny(msg, ['selimut', 'blanket', 'bed cover', 'sprei'])) {
      return "🛏️ Cuci Selimut/Bed Cover:\n\n• Single: Rp 25.000\n• Double: Rp 35.000\n• King Size: Rp 45.000\n\nPakai pewangi premium ya Kak! ✨";
    }

    // === SALAM / GREETING ===
    if (_containsAny(msg, ['halo', 'hai', 'hello', 'hi', 'assalamualaikum', 'pagi', 'siang', 'sore', 'malam'])) {
      final greetings = [
        "Halo Kak! 😊 Senang bisa bantu. Ada yang ingin ditanyakan?",
        "Hai Kak! 👋 Ada yang bisa dibantu hari ini?",
        "Hello! Selamat datang kembali di Raja Laundry 😊",
      ];
      return greetings[DateTime.now().second % 3];
    }

    // === TERIMA KASIH ===
    if (_containsAny(msg, ['terima kasih', 'thanks', 'makasih', 'thx', 'thank you'])) {
      return "Sama-sama Kak! 😊\n\nSenang bisa membantu. Jangan ragu untuk tanya lagi ya!\n\nSampai jumpa! 👋";
    }

    // === BISA/TIDAK ===
    if (_containsAny(msg, ['bisa', 'boleh', 'menerima'])) {
      if (_containsAny(msg, ['antar', 'kirim', 'delivery'])) {
        return "🚚 Jemput & Antar:\n\nYES! Kami melayani jemput & antar GRATIS untuk area Malang Kota (minimal 3kg).\n\nLuar kota ada biaya antar ya Kak.\n\nMau dijemput? Ketik 'admin' 😊";
      }
      return "Tentu bisa Kak! 😊 Coba sampaikan detail kebutuhannya atau langsung hubungi Admin untuk info lebih lanjut ya.\n\nKetik 'admin' untuk lanjut.";
    }

    // === DEFAULT - TIDAK PAHAM ===
    return "Maaf Kak, saya kurang paham pertanyaannya 🙏\n\nCoba ketik:\n• 'harga' → Info harga\n• 'jam buka' → Jam operasional\n• 'layanan' → Jenis layanan\n• 'cara pesan' → Cara order\n• 'admin' → Hubungi admin\n\nAtau langsung chat Admin kami ya! 😊";
  }

  // ✅ HELPER: Cek apakah string mengandung salah satu keyword
  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }

  // ✅ CEK ADMIN KEYWORD
  bool _isAskingForAdmin(String text) {
    return _containsAny(text, ['admin', 'manusia', 'wa', 'whatsapp', 'telepon', 'hubungi', 'kontak', 'customer service', 'cs']);
  }

  // ✅ DIALOG WHATSAPP
  void _showAdminDialog() {
    Future.delayed(const Duration(milliseconds: 400), () {
      Get.defaultDialog(
        title: "💬 Hubungi Admin",
        titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        middleText: "Buka WhatsApp sekarang untuk chat dengan Admin?",
        middleTextStyle: const TextStyle(fontSize: 14),
        textConfirm: "Ya, Buka WA",
        textCancel: "Nanti Saja",
        confirmTextColor: Colors.white,
        buttonColor: const Color(0xFF25D366), // Warna hijau WA
        cancelTextColor: Colors.grey[600],
        onConfirm: () {
          Get.back();
          _bukaWhatsApp();
        },
      );
    });
  }

  // ✅ BUKA WHATSAPP
  void _bukaWhatsApp() async {
    const String phoneNumber = "6285704732289"; 
    const String message = "Halo Admin Raja Laundry, saya mau tanya...";
    
    final Uri url = Uri.parse(
      "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}"
    );

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          "❌ Gagal", 
          "WhatsApp tidak terinstall di perangkat ini",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[400],
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      print("❌ ERROR WHATSAPP: $e");
      Get.snackbar(
        "❌ Error", 
        "Gagal membuka WhatsApp: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[400],
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // ✅ AUTO SCROLL KE BAWAH
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollC.hasClients) {
        scrollC.animateTo(
          scrollC.position.maxScrollExtent, 
          duration: const Duration(milliseconds: 300), 
          curve: Curves.easeOut
        );
      }
    });
  }
}