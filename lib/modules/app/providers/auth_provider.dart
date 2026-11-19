import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/firebase_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseService _service;

  User? _currentUser;

  bool _isLoading = true;

  String? _errorMessage;

  StreamSubscription<User?>? _authSubscription;

  AuthProvider({FirebaseService? service})
    : _service = service ?? FirebaseService() {
    _currentUser = _service.currentUser;

    _authSubscription = _service.authStateChanges.listen(
      (User? user) {
        _currentUser = user;
        _isLoading = false;
        _errorMessage = null;

        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = 'No fue posible comprobar la sesión.';

        debugPrint('Error de autenticación: $error');

        notifyListeners();
      },
    );
  }

  User? get currentUser => _currentUser;

  String? get userId => _currentUser?.uid;

  String get email => _currentUser?.email ?? '';

  String get displayName => _currentUser?.displayName ?? '';

  bool get isAuthenticated => _currentUser != null;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Future<UserCredential> register({
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    try {
      final credential = await _service.register(
        email: email,
        password: password,
      );

      _currentUser = credential.user;
      _errorMessage = null;

      return credential;
    } catch (error) {
      _errorMessage = _getErrorMessage(error);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    try {
      final credential = await _service.login(email: email, password: password);

      _currentUser = credential.user;
      _errorMessage = null;

      return credential;
    } catch (error) {
      _errorMessage = _getErrorMessage(error);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);

    try {
      await _service.signOut();

      _currentUser = null;
      _errorMessage = null;
    } catch (error) {
      _errorMessage = _getErrorMessage(error);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateDisplayName({required String name}) async {
    if (name.trim().isEmpty) {
      throw ArgumentError('El nombre no puede estar vacío.');
    }

    _setLoading(true);

    try {
      await _service.updateDisplayName(name: name);

      await _refreshCurrentUser();
      _errorMessage = null;
    } catch (error) {
      _errorMessage = _getErrorMessage(error);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteAccount({required String password}) async {
    if (password.isEmpty) {
      throw ArgumentError('Ingresa tu contraseña.');
    }

    _setLoading(true);

    try {
      await _service.deleteAccount(password: password);

      _currentUser = null;
      _errorMessage = null;
    } catch (error) {
      _errorMessage = _getErrorMessage(error);
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _refreshCurrentUser() async {
    final user = _service.currentUser;

    if (user == null) {
      _currentUser = null;
      return;
    }

    await user.reload();

    _currentUser = _service.currentUser;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String _getErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'Este correo ya tiene una cuenta.';

        case 'invalid-email':
          return 'Ingresa un correo electrónico válido.';

        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
        case 'invalid-login-credentials':
          return 'El correo o la contraseña son incorrectos.';

        case 'weak-password':
          return 'La contraseña es demasiado débil.';

        case 'user-disabled':
          return 'Esta cuenta ha sido deshabilitada.';

        case 'too-many-requests':
          return 'Demasiados intentos. Inténtalo más tarde.';

        case 'network-request-failed':
          return 'Comprueba tu conexión a internet.';

        case 'operation-not-allowed':
          return 'Esta operación no está habilitada en Firebase.';

        case 'requires-recent-login':
          return 'Debes iniciar sesión nuevamente para realizar esta acción.';

        case 'no-current-user':
          return 'No existe un usuario autenticado.';

        case 'missing-email':
          return 'No se encontró el correo de la cuenta.';
      }
    }

    return 'Ocurrió un problema. Intenta nuevamente.';
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
