import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../app/animated_page_route.dart';
import '../../../app_theme.dart';
import '../constants/radio_constants.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _splashTimer;

  @override
  void initState() {
    super.initState();

    _splashTimer = Timer(
      const Duration(seconds: AppConstants.splashDuration),
      _navigateToOnboarding,
    );
  }

  void _navigateToOnboarding() {
    if (!mounted) return;

    Navigator.of(context)
        .pushReplacement(animatedPageRoute(const OnboardingScreen()));
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.radio_rounded, color: AppTheme.primary, size: 100)
                .animate()
                .fadeIn(duration: 480.ms)
                .scale(
                  begin: const Offset(0.75, 0.75),
                  duration: 560.ms,
                  curve: Curves.easeOutBack,
                ),
            const SizedBox(height: 25),
            const Text(
                  AppConstants.appName,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                )
                .animate(delay: 120.ms)
                .fadeIn(duration: 360.ms)
                .slideY(begin: 0.12, duration: 360.ms),
            const SizedBox(height: 12),
            const Text(
              AppConstants.appDescription,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
            ).animate(delay: 200.ms).fadeIn(duration: 360.ms),
            const SizedBox(height: 40),
            SizedBox(
              height: 30,
              width: 30,
              child: const CircularProgressIndicator(
                color: AppTheme.primary,
                strokeWidth: 3,
              ).animate(delay: 280.ms).fadeIn(duration: 300.ms),
            ),
          ],
        ),
      ),
    );
  }
}
