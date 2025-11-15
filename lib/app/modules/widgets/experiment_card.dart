import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExperimentCard extends StatelessWidget {
  final String title;
  final String description;
  final String button1Label;
  final RxBool isLoading1;
  final RxString result1;
  final VoidCallback onButton1Pressed;
  final String button2Label;
  final RxBool isLoading2;
  final RxString result2;
  final VoidCallback onButton2Pressed;

  const ExperimentCard({
    super.key,
    required this.title,
    required this.description,
    required this.button1Label,
    required this.isLoading1,
    required this.result1,
    required this.onButton1Pressed,
    required this.button2Label,
    required this.isLoading2,
    required this.result2,
    required this.onButton2Pressed,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(description, style: textTheme.bodyMedium),
            const SizedBox(height: 16),
            // Baris Eksperimen 1
            _buildResultRow(
              label: button1Label,
              isLoading: isLoading1,
              result: result1,
              onPressed: onButton1Pressed,
              color: Colors.blue,
            ),
            const Divider(height: 24),
            // Baris Eksperimen 2
            _buildResultRow(
              label: button2Label,
              isLoading: isLoading2,
              result: result2,
              onPressed: onButton2Pressed,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow({
    required String label,
    required RxBool isLoading,
    required RxString result,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
            ),
            onPressed: onPressed,
            child: Obx(
              () => isLoading.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(label),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Obx(
            () => Text(
              result.value,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: result.value.startsWith('❌') ? Colors.red : Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }
}