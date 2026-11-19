import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/animated_page_route.dart';
import '../../../app_theme.dart';
import '../constants/radio_constants.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            children: [
              const Spacer(),

              Container(
                    height: 180,
                    width: 180,
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.25),
                          blurRadius: 35,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.radio_rounded,
                      size: 100,
                      color: AppTheme.primary,
                    ),
                  )
                  .animate()
                  .fadeIn(duration: 420.ms)
                  .scale(
                    begin: const Offset(0.86, 0.86),
                    duration: 520.ms,
                    curve: Curves.easeOutBack,
                  ),

              const SizedBox(height: 30),

              const Text(
                AppConstants.appName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Tu música, tus estaciones, tu mundo.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.secondary,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Descubre nuevas estaciones, disfruta '
                'tus programas favoritos y lleva la radio '
                'contigo a donde quiera que vayas.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),
              _buildFeature(
                    Icons.library_music_rounded,
                    'Cuatro estaciones',
                    'Explora diferentes géneros musicales.',
                  )
                  .animate(delay: 100.ms)
                  .fadeIn(duration: 320.ms)
                  .slideX(begin: -0.05, duration: 320.ms),

              const SizedBox(height: 16),

              _buildFeature(
                    Icons.play_circle_fill_rounded,
                    'Reproducción de audio',
                    'Escucha, pausa y cambia de estación.',
                  )
                  .animate(delay: 180.ms)
                  .fadeIn(duration: 320.ms)
                  .slideX(begin: -0.05, duration: 320.ms),

              const SizedBox(height: 16),

              _buildFeature(
                    Icons.notifications_active_rounded,
                    'Controles multimedia',
                    'Controla la reproducción desde Android.',
                  )
                  .animate(delay: 260.ms)
                  .fadeIn(duration: 320.ms)
                  .slideX(begin: -0.05, duration: 320.ms),

              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 55,
                child:
                    ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              animatedPageRoute(const HomeScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Comenzar a escuchar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                        .animate(delay: 320.ms)
                        .fadeIn(duration: 360.ms)
                        .slideY(begin: 0.08, duration: 360.ms),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          height: 46,
          width: 46,
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppTheme.primary, size: 25),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
