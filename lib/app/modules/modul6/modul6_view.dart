import 'package:demo5/app/modules/modul6/modul6_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Modul6View extends StatelessWidget {
  const Modul6View({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(Modul6Controller());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modul 6 - Notification Test'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.notifications),
              label: const Text('Trigger Test Notification'),
              onPressed: controller.triggerCustomSoundNotification,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.volume_up),
              label: const Text('Trigger Custom Sound Notification'),
              onPressed: controller.playCustomSoundNotification,
            ),
          ],
        ),
      ),
    );
  }
}
