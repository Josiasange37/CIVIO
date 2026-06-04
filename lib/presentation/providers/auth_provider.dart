import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../data/repositories/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  final AuthRepository _repository;
  StreamSubscription<User?>? _authSub;

  AuthProvider({AuthRepository? repository})
      : _repository = repository ?? AuthRepository() {
    _authSub = _repository.authStateChanges.listen((user) {
      _status = user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
      _currentUser = user;
      notifyListeners();
    });
  }

  AuthStatus _status = AuthStatus.unknown;
  User? _currentUser;
  bool _isLoading = false;
  String? _lastError;

  AuthStatus get status => _status;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    final result = await _repository.signInWithEmail(
      email: email,
      password: password,
    );
    _setLoading(false);
    if (result.isFailure) {
      _lastError = result.error;
      notifyListeners();
      return false;
    }
    _lastError = null;
    return true;
  }

  Future<bool> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    String? cityId,
    String? regionId,
    String phoneNumber = '',
  }) async {
    _setLoading(true);
    final result = await _repository.registerWithEmail(
      email: email,
      password: password,
      displayName: displayName,
      cityId: cityId,
      regionId: regionId,
      phoneNumber: phoneNumber,
    );
    _setLoading(false);
    if (result.isFailure) {
      _lastError = result.error;
      notifyListeners();
      return false;
    }
    _lastError = null;
    return true;
  }

  Future<void> signOut() async {
    await _repository.signOut();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
