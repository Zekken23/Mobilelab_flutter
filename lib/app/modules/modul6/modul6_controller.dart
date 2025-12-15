import 'package:demo5/app/utils/notification_handler.dart';
import 'package:get/get.dart';

class Modul6Controller extends GetxController {
  final NotificationHandler _notificationHandler = Get.find();

  void triggerCustomSoundNotification() {
    _notificationHandler.showTestNotification(
        title: 'Test', body: 'Ini Notifikasi Test');
  }

  void playCustomSoundNotification() {
    _notificationHandler.showCustomSoundNotification(
        title: 'Testing Sound', body: 'Ini Notifikasi Sound Testing');
  }
}
