import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../app/providers/auth_provider.dart' as app_auth;

class AuthProvider extends ChangeNotifier {
  final app_auth.AuthProvider _appAuthProvider;

  User? _user;
  bool _isLoading = true;
  String? _errorMessage;

  AuthProvider({required this._appAuthProvider}) {
    _syncWithAppAuth();
    _appAuthProvider.addListener(_syncWithAppAuth);
  }

  User? get user => _user;
  String get displayName => _user?.displayName ?? '';
  String get email => _user?.email ?? '';
  String? get userId => _user?.uid;

  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _syncWithAppAuth() {
    _user = _appAuthProvider.currentUser;
    _isLoading = _appAuthProvider.isLoading;

    notifyListeners();
  }

  Future<bool> signIn({required String email, required String password}) async {
    _errorMessage = null;
    notifyListeners();

    try {
      await _appAuthProvider.login(email: email, password: password);

      _user = _appAuthProvider.currentUser;
      _errorMessage = null;

      notifyListeners();
      return _user != null;
    } catch (error) {
      _errorMessage = _getErrorMessage(error);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDisplayName({required String name}) async {
    if (name.trim().isEmpty) {
      _errorMessage = 'El nombre no puede estar vacío.';
      notifyListeners();
      return false;
    }

    _errorMessage = null;
    notifyListeners();

    try {
      await _appAuthProvider.updateDisplayName(name: name);

      _user = _appAuthProvider.currentUser;
      _errorMessage = null;

      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = _getErrorMessage(error);
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAccount({required String password}) async {
    if (password.isEmpty) {
      _errorMessage = 'Ingresa tu contraseña.';
      notifyListeners();
      return false;
    }

    _errorMessage = null;
    notifyListeners();

    try {
      await _appAuthProvider.deleteAccount(password: password);

      _user = _appAuthProvider.currentUser;
      _errorMessage = null;

      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = _getErrorMessage(error);
      notifyListeners();
      return false;
    }
  }

  Future<bool> signOut() async {
    _errorMessage = null;
    notifyListeners();

    try {
      await _appAuthProvider.signOut();

      _user = _appAuthProvider.currentUser;
      _errorMessage = null;

      notifyListeners();
      return _user == null;
    } catch (error) {
      _errorMessage = _getErrorMessage(error);
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _getErrorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No encontramos una cuenta con ese correo.';

        case 'wrong-password':
        case 'invalid-credential':
        case 'invalid-login-credentials':
          return 'El correo o la contraseña son incorrectos.';

        case 'email-already-in-use':
          return 'Este correo ya tiene una cuenta.';

        case 'invalid-email':
          return 'Ingresa un correo electrónico válido.';

        case 'user-disabled':
          return 'Esta cuenta ha sido deshabilitada.';

        case 'too-many-requests':
          return 'Demasiados intentos. Inténtalo más tarde.';

        case 'network-request-failed':
          return 'No hay conexión. Comprueba tu internet.';

        case 'operation-not-allowed':
          return 'Esta operación no está habilitada.';

        case 'requires-recent-login':
          return 'Debes volver a iniciar sesión para realizar esta acción.';

        case 'weak-password':
          return 'La contraseña no cumple los requisitos.';

        case 'no-current-user':
          return 'No existe un usuario autenticado.';

        case 'missing-email':
          return 'No se encontró el correo de la cuenta.';
      }
    }

    return 'No fue posible completar la operación.';
  }

  @override
  void dispose() {
    _appAuthProvider.removeListener(_syncWithAppAuth);
    super.dispose();
  }
}
