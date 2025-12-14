import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../routes/app_pages.dart';

// 1. HANDLER BACKGROUND (Wajib Top-Level Function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Notifikasi masuk saat background: ${message.messageId}');
}

class NotificationHandler {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // 2. INISIALISASI UTAMA
  Future<void> initPushNotification() async {
    // Izin Notifikasi
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('Izin user: ${settings.authorizationStatus}');

    // Ambil Token
    _firebaseMessaging.getToken().then((token) {
      print('FCM TOKEN: $token');
    });

    // Init Local Notification
    await _initLocalNotification();

    // Listener Background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Listener Foreground (Saat aplikasi dibuka)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Pesan masuk saat foreground: ${message.notification?.title}');
      if (message.notification != null) {
        // Panggil fungsi yang sudah didefinisikan di bawah
        showLocalNotification(message);
      }
    });

    // Listener Saat Notifikasi Diklik
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notifikasi diklik!');
    });
  }

  Future<void> _initLocalNotification() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("Notifikasi Lokal diklik: ${response.payload}");
        if (response.payload == 'order_success') {
           Get.toNamed(Routes.DASHBOARD, arguments: 2); 
        }
      },
    );
  }

  void showLocalNotification(RemoteMessage message) {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'raja_cuci_channel',       
      'Raja Cuci Notifications', 
      channelDescription: 'Notifikasi update status cucian',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notif_laundry'), 
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformDetails,
      payload: jsonEncode(message.data),
    );
  }

  void showSimpleNotification(String title, String body) {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'raja_cuci_channel',       
      'Raja Cuci Notifications', 
      channelDescription: 'Notifikasi aplikasi',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notif_laundry'), 
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    _localNotifications.show(
      DateTime.now().millisecond,
      title,
      body,
      platformDetails,
      payload: 'order_success', 
    );
  }
}