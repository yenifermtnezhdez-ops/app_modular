import 'package:flutter/material.dart';

import '../../../app/section_app_bar.dart';
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

  static const Color _purple = Color(0xFF8964D8);
  static const Color _lavender = Color(0xFFE9DFFC);

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _openSection(String section) {
    Widget destination;

    switch (section) {
      case 'Notas':
        destination = const NotesScreen();
        break;
      case 'Eventos':
        destination = const EventsScreen();
        break;
      case 'Recordatorios':
        destination = const ReminderScreen();
        break;
      default:
        destination = DetailScreen(section: section);
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
  }

  void _greet() {
    final name = _nameController.text.trim();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Text(
            name.isEmpty
                ? '¡Hola! Bienvenido a tu espacio.'
                : '¡Hola, $name! Qué gusto tenerte aquí.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const SectionAppBar(
        title: 'Mi App Lab',
        subtitle: 'Tu espacio personal',
        icon: Icons.dashboard_rounded,
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text(
                    'ORGANIZA TU DÍA',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colors.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Todo lo que necesitas,\nen un solo lugar.',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                      letterSpacing: -0.8,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    'Organiza tus ideas, administra tus actividades '
                    'y mantén todo bajo control.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 25),

                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? const [Color(0xFF493273), Color(0xFF29213B)]
                            : const [Color(0xFF8964D8), Color(0xFF6844B7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: _purple.withValues(
                            alpha: isDark ? 0.12 : 0.25,
                          ),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -32,
                          top: -45,
                          child: Container(
                            width: 145,
                            height: 145,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.07),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 28,
                          bottom: -65,
                          child: Container(
                            width: 115,
                            height: 115,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.06),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 11,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.waving_hand_rounded,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'BIENVENIDO',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 19),
                            const Text(
                              '¡Hola! ¿Cómo\nte llamas?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.w900,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 9),
                            Text(
                              'Personaliza tu experiencia.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.78),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _nameController,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _greet(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Escribe tu nombre',
                                hintStyle: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.65),
                                ),
                                prefixIcon: const Icon(
                                  Icons.person_outline_rounded,
                                  color: Colors.white,
                                ),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.13),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: Colors.white,
                                    width: 1.4,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 13),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: _greet,
                                icon: const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 19,
                                ),
                                label: const Text(
                                  'Comenzar',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: _purple,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 34),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tu espacio de trabajo',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.4,
                                color: colors.onSurface,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Elige dónde quieres comenzar.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.grid_view_rounded,
                        color: colors.primary,
                        size: 23,
                      ),
                    ],
                  ),

                  const SizedBox(height: 19),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _ModuleCard(
                          title: 'Notas',
                          subtitle: 'Tus ideas y apuntes',
                          icon: Icons.sticky_note_2_rounded,
                          accent: const Color(0xFF8964D8),
                          background: _lavender,
                          onTap: () => _openSection('Notas'),
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: _ModuleCard(
                          title: 'Eventos',
                          subtitle: 'Fechas importantes',
                          icon: Icons.calendar_month_rounded,
                          accent: const Color(0xFF598FAD),
                          background: const Color(0xFFDCEEF5),
                          onTap: () => _openSection('Eventos'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 13),

                  _ReminderCard(
                    onTap: () => _openSection('Recordatorios'),
                    isDark: isDark,
                    primary: colors.primary,
                    surface: colors.surface,
                    textColor: colors.onSurface,
                    secondaryText: colors.onSurfaceVariant,
                  ),

                  const SizedBox(height: 28),

                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          color: colors.primary.withValues(alpha: 0.7),
                          size: 20,
                        ),
                        const SizedBox(height: 7),
                        Text(
                          'TU DÍA, TU ESPACIO, TU ORGANIZACIÓN.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            letterSpacing: 1.1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
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
  final String subtitle;
  final IconData icon;
  final Color accent;
  final Color background;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? colors.surfaceContainerHighest : colors.surface,
      borderRadius: BorderRadius.circular(23),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(23),
        child: Container(
          constraints: const BoxConstraints(minHeight: 175),
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(23),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.45),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.035),
                blurRadius: 15,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? accent.withValues(alpha: 0.19) : background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: accent, size: 25),
              ),
              const SizedBox(height: 19),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                maxLines: 2,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: colors.onSurfaceVariant, height: 1.35),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: accent,
                  size: 21,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReminderCard extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDark;
  final Color primary;
  final Color surface;
  final Color textColor;
  final Color secondaryText;

  const _ReminderCard({
    required this.onTap,
    required this.isDark,
    required this.primary,
    required this.surface,
    required this.textColor,
    required this.secondaryText,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark
          ? Theme.of(context).colorScheme.surfaceContainerHighest
          : surface,
      borderRadius: BorderRadius.circular(23),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(23),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(23),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant
                  .withValues(alpha: 0.45),
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  Icons.notifications_active_rounded,
                  color: primary,
                  size: 27,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Recordatorios',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'No dejes pasar nada importante.',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: secondaryText),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: primary, size: 19),
            ],
          ),
        ),
      ),
    );
  }
}
