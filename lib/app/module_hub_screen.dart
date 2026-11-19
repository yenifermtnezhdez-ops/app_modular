
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../modules/app/screens/home_screen.dart' as app_module;
import '../modules/app/screens/user_screen.dart';
import '../modules/radio/screens/home_screen.dart' as radio_module;
import '../modules/news/screens/home_screen.dart' as news_module;

class ModuleHubScreen extends StatelessWidget {
  const ModuleHubScreen({super.key});

  void _openModule(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => screen,
      ),
    );
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo cerrar la sesión.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final displayName = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!
        : 'Bienvenido';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'App Modular',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Mi perfil',
            onPressed: () {
              _openModule(
                context,
                const UserScreen(),
              );
            },
            icon: const Icon(Icons.account_circle_outlined),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.logout),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppTheme.primary,
                    AppTheme.secondary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(
                  AppTheme.radiusLarge,
                ),
                boxShadow: AppTheme.softShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.dashboard_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '¡Hola, $displayName!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tu espacio digital. Selecciona el módulo '
                    'que deseas utilizar.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              'Mis módulos',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),

            const SizedBox(height: 16),

            _ModuleCard(
              title: 'Mi App Lab',
              description:
                  'Organiza tus notas, eventos y recordatorios.',
              icon: Icons.calendar_month_rounded,
              onTap: () {
                _openModule(
                  context,
                  const app_module.HomeScreen(),
                );
              },
            ),

            const SizedBox(height: 14),

            _ModuleCard(
              title: 'Radio',
              description:
                  'Escucha tus estaciones favoritas y disfruta '
                  'de la música.',
              icon: Icons.radio_rounded,
              onTap: () {
                _openModule(
                  context,
                  radio_module.HomeScreen(),
                );
              },
            ),

            const SizedBox(height: 14),

            _ModuleCard(
              title: 'Noticias',
              description:
                  'Consulta noticias, explora categorías y guarda '
                  'tus artículos favoritos.',
              icon: Icons.newspaper_rounded,
              onTap: () {
                _openModule(
                  context,
                  news_module.HomeScreen(),
                );
              },
            ),

            const SizedBox(height: 24),

            const Center(
              child: Text(
                'App Modular · Fase 4',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(
        AppTheme.radiusLarge,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          AppTheme.radiusLarge,
        ),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              AppTheme.radiusLarge,
            ),
            border: Border.all(
              color: AppTheme.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceElevated,
                  borderRadius: BorderRadius.circular(
                    AppTheme.radiusMedium,
                  ),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primary,
                  size: 29,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 17,
                color: AppTheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
