import 'package:flutter/material.dart';

import '../../../app/theme_toggle_button.dart';

class DetailScreen extends StatelessWidget {
  final String section;

  const DetailScreen({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(section),
        actions: const [ThemeToggleButton(), SizedBox(width: 8)],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, size: 80),
            const SizedBox(height: 16),
            Text(
              'Bienvenido a $section',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    );
  }
}
