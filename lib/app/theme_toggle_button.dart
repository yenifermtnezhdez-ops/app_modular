import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../modules/news/providers/app_provider.dart' as app_theme;

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<app_theme.AppProvider>();
    final isDarkMode = themeProvider.isDarkMode;

    return IconButton(
      tooltip: isDarkMode ? 'Cambiar a modo claro' : 'Cambiar a modo oscuro',
      onPressed: themeProvider.toggleTheme,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, animation) {
          return RotationTransition(
            turns: animation,
            child: FadeTransition(opacity: animation, child: child),
          );
        },
        child: Icon(
          isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          key: ValueKey(isDarkMode),
        ),
      ),
    );
  }
}
