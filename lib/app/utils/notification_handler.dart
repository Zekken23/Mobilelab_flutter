import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import '../routes/app_pages.dart';

// 1. HANDLER BACKGROUND (Wajib Top-Level Function)

class NotificationHandler {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initPushNotification() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final token = await _firebaseMessaging.getToken();
    print('FCM TOKEN: $token');

    await _initLocalNotification();
    await _createAndroidChannel();

    // Foreground Notification
    FirebaseMessaging.onMessage.listen(showLocalNotification);

    // Background Notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageClick);

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessageClick(initialMessage);
    }
  }

  Future<void> _initLocalNotification() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings),
      onDidReceiveNotificationResponse: _onLocalNotificationClick,
    );
  }

  Future<void> _createAndroidChannel() async {
    const channel = AndroidNotificationChannel(
      'raja_cuci_channel',
      'Raja Cuci Notifications',
      description: 'Notifikasi update status cucian',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('notif_laundry'),
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void showLocalNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'raja_cuci_channel',
      'Raja Cuci Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(android: androidDetails),
      payload: jsonEncode(message.data),
    );
  }

  void _onLocalNotificationClick(NotificationResponse response) {
    if (response.payload == null) return;

    final data = jsonDecode(response.payload!);

    if (data['type'] == 'order_success') {
      Get.toNamed(Routes.DASHBOARD, arguments: 2);
    }
  }

  void _handleMessageClick(RemoteMessage message) {
    final data = message.data;

    if (data['type'] == 'order_success') {
      Get.toNamed(Routes.DASHBOARD, arguments: 2);
    }
  }
}
