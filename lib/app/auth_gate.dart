import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../modules/app/providers/auth_provider.dart' as app_auth;
import '../modules/app/screens/login_screen.dart';
import 'module_hub_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<app_auth.AuthProvider>();

    if (authProvider.isLoading && authProvider.currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (authProvider.errorMessage != null && authProvider.currentUser == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 52, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'No se pudo comprobar la sesión.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    authProvider.clearError();
                  },
                  child: const Text('Intentar nuevamente'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }

    return const ModuleHubScreen();
  }
}
