import 'package:firebase_auth/firebase_auth.dart';

import '../services/firebase_service.dart';

class AuthProvider {
  final FirebaseService _service = FirebaseService();

  Future<UserCredential> register({
    required String email,
    required String password,
  }) {
    return _service.register(email: email, password: password);
  }

  Future<UserCredential> login({
    required String email,
    required String password,
  }) {
    return _service.login(email: email, password: password);
  }

  User? get currentUser => _service.currentUser;
}
