import 'package:flutter/material.dart';

import 'detail_screen.dart';
import 'notes_screen.dart';
import 'events_screen.dart';
import 'reminder_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _openSection(String section) {
    if (section == 'Notas') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NotesScreen()),
      );
      return;
    }

    if (section == 'Eventos') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EventsScreen()),
      );
      return;
    }

    if (section == 'Recordatorios') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ReminderScreen()),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailScreen(section: section)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi App Lab'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.calendar_month,
              size: 100,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 16),
            const Text(
              '¡Bienvenido a mi aplicación!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Explora las secciones de mi primera app.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Escribe tu nombre',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                final name = _nameController.text.trim();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      name.isEmpty
                          ? '¡Hola! Bienvenido a mi app.'
                          : '¡Hola, $name! Bienvenido a mi app.',
                    ),
                  ),
                );
              },
              child: const Text('Saludar'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Explora nuestras secciones',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openSection('Notas'),
                    icon: const Icon(Icons.note),
                    label: const Text('Notas'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openSection('Eventos'),
                    icon: const Icon(Icons.event),
                    label: const Text('Eventos'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _openSection('Recordatorios'),
              icon: const Icon(Icons.notifications),
              label: const Text('Recordatorios'),
            ),
          ],
        ),
      ),
    );
  }
}
