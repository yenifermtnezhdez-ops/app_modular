import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AppLoadingState extends StatelessWidget {
  final String message;
  final IconData icon;

  const AppLoadingState({
    super.key,
    required this.message,
    this.icon = Icons.auto_awesome_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: colors.primary)
              .animate()
              .fadeIn(duration: 260.ms)
              .scale(
                begin: const Offset(0.82, 0.82),
                duration: 360.ms,
                curve: Curves.easeOutBack,
              ),
          const SizedBox(height: 18),
          SizedBox(
            height: 30,
            width: 30,
            child: CircularProgressIndicator(
              color: colors.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ).animate(delay: 90.ms).fadeIn(duration: 260.ms).slideY(begin: 0.12),
        ],
      ),
    );
  }
}
