import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../app_theme.dart';
import 'animated_page_route.dart';
import 'theme_toggle_button.dart';
import '../modules/app/providers/auth_provider.dart' as app_auth;
import '../modules/app/screens/home_screen.dart' as app_module;
import '../modules/app/screens/user_screen.dart';
import '../modules/radio/screens/home_screen.dart' as radio_module;
import '../modules/news/screens/home_screen.dart' as news_module;

class ModuleHubScreen extends StatelessWidget {
  const ModuleHubScreen({super.key});

  void _openModule(BuildContext context, Widget screen) {
    Navigator.push(context, animatedPageRoute(screen));
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      await context.read<app_auth.AuthProvider>().signOut();
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo cerrar la sesión.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final authProvider = context.watch<app_auth.AuthProvider>();
    final user = authProvider.currentUser;

    final displayName = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!
        : 'Bienvenido';
    final firstName = displayName.split(' ').first;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.widgets_rounded,
                color: Colors.white,
                size: 21,
              ),
            ),
            const SizedBox(width: 11),
            const Text(
              'App Modular',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        actions: [
          const ThemeToggleButton(),
          IconButton(
            tooltip: 'Mi perfil',
            style: IconButton.styleFrom(
              backgroundColor: colors.surfaceContainerHighest,
            ),
            onPressed: () {
              _openModule(context, const UserScreen());
            },
            icon: const Icon(Icons.account_circle_outlined),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            style: IconButton.styleFrom(
              backgroundColor: colors.surfaceContainerHighest,
            ),
            onPressed: authProvider.isLoading ? null : () => _signOut(context),
            icon: const Icon(Icons.logout),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6844B7), Color(0xFF9A75E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -42,
                          top: -55,
                          child: Container(
                            width: 180,
                            height: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.08),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 68,
                          bottom: -92,
                          child: Container(
                            width: 155,
                            height: 155,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.06),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.16),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.auto_awesome_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    SizedBox(width: 7),
                                    Text(
                                      'TU ESPACIO DIGITAL',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 23),
                              Text(
                                '¡Hola, $firstName!',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  height: 1.15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 9),
                              Text(
                                'Todo lo que necesitas para organizarte, '
                                'escuchar y mantenerte al día.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.84),
                                  fontSize: 13,
                                  height: 1.55,
                                ),
                              ),
                              const SizedBox(height: 22),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.touch_app_rounded,
                                    color: Colors.white,
                                    size: 17,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Elige un espacio para comenzar',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.95,
                                      ),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .animate()
                .fadeIn(duration: 420.ms)
                .slideY(
                  begin: 0.06,
                  duration: 420.ms,
                  curve: Curves.easeOutCubic,
                ),
            const SizedBox(height: 30),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EXPLORA',
                        style: TextStyle(
                          color: colors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.8,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Tus espacios',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                          color: colors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '03 MÓDULOS',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ModuleCard(
                  title: 'Mi App Lab',
                  description: 'Organiza tus notas, eventos y recordatorios.',
                  eyebrow: 'PRODUCTIVIDAD',
                  icon: Icons.dashboard_customize_rounded,
                  accent: const Color(0xFF8056D9),
                  onTap: () {
                    _openModule(context, const app_module.HomeScreen());
                  },
                )
                .animate(delay: 100.ms)
                .fadeIn(duration: 360.ms)
                .slideY(
                  begin: 0.08,
                  duration: 360.ms,
                  curve: Curves.easeOutCubic,
                ),
            const SizedBox(height: 13),
            _ModuleCard(
                  title: 'Radio',
                  description:
                      'Descubre estaciones y disfruta tu música favorita.',
                  eyebrow: 'MÚSICA Y AUDIO',
                  icon: Icons.graphic_eq_rounded,
                  accent: const Color(0xFF168A83),
                  onTap: () {
                    _openModule(context, radio_module.HomeScreen());
                  },
                )
                .animate(delay: 180.ms)
                .fadeIn(duration: 360.ms)
                .slideY(
                  begin: 0.08,
                  duration: 360.ms,
                  curve: Curves.easeOutCubic,
                ),
            const SizedBox(height: 13),
            _ModuleCard(
                  title: 'Noticias',
                  description:
                      'Explora la actualidad y guarda lo que te interesa.',
                  eyebrow: 'ACTUALIDAD',
                  icon: Icons.newspaper_rounded,
                  accent: const Color(0xFFD27A36),
                  onTap: () {
                    _openModule(context, news_module.HomeScreen());
                  },
                )
                .animate(delay: 260.ms)
                .fadeIn(duration: 360.ms)
                .slideY(
                  begin: 0.08,
                  duration: 360.ms,
                  curve: Curves.easeOutCubic,
                ),
            const SizedBox(height: 25),
            Center(
              child: Text(
                'APP MODULAR  ·  TODO EN UN SOLO LUGAR',
                style: TextStyle(
                  color: colors.onSurfaceVariant.withValues(alpha: 0.8),
                  fontSize: 9,
                  letterSpacing: 1.05,
                  fontWeight: FontWeight.w700,
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
  final String eyebrow;
  final IconData icon;
  final Color accent;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.title,
    required this.description,
    required this.eyebrow,
    required this.icon,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colors.outline.withValues(alpha: 0.45)),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: isDark ? 0.05 : 0.035),
                blurRadius: 18,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      accent.withValues(alpha: isDark ? 0.22 : 0.13),
                      accent.withValues(alpha: isDark ? 0.12 : 0.07),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(19),
                ),
                child: Icon(icon, color: accent, size: 28),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eyebrow,
                      style: TextStyle(
                        color: accent,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: colors.onSurface,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: isDark ? 0.2 : 0.09),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
