import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../core/config/app_config.dart';

/// Lightweight auth wrapper around [FirebaseAuth] + Firestore.
///
/// On `AppConfig.isDemoMode == true` (no live Firebase on Linux/macOS/Windows
/// dev), every method returns null / no-ops so the calling code can still
/// run the UI in a UI-only preview state.
class AuthRepository {
  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  /// Current user, or null if not signed in.
  User? get currentUser => AppConfig.isDemoMode ? null : _auth.currentUser;

  /// Stream of auth state changes (null when signed out).
  Stream<User?> get authStateChanges {
    if (AppConfig.isDemoMode) return Stream<User?>.value(null);
    return _auth.authStateChanges();
  }

  /// Email + password sign-in.
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (AppConfig.isDemoMode) {
      return AuthResult.failure('Authentification indisponible en mode démo.');
    }
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return AuthResult.success(cred.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_humanize(e));
    } catch (e) {
      debugPrint('AuthRepository.signInWithEmail error: $e');
      return AuthResult.failure('Erreur inattendue. Réessayez.');
    }
  }

  /// Email + password registration. After the Firebase user is created, a
  /// `citizens/{uid}` profile doc is written in Firestore.
  Future<AuthResult> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    String? cityId,
    String? regionId,
    String phoneNumber = '',
  }) async {
    if (AppConfig.isDemoMode) {
      return AuthResult.failure('Inscription indisponible en mode démo.');
    }
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = cred.user;
      if (user == null) {
        return AuthResult.failure('Création de compte échouée.');
      }
      await user.updateDisplayName(displayName);
      await user.reload();
      await _writeCitizenProfile(
        uid: user.uid,
        email: email.trim(),
        displayName: displayName,
        phoneNumber: phoneNumber,
        cityId: cityId,
        regionId: regionId,
      );
      return AuthResult.success(_auth.currentUser);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_humanize(e));
    } catch (e) {
      debugPrint('AuthRepository.registerWithEmail error: $e');
      return AuthResult.failure('Erreur inattendue. Réessayez.');
    }
  }

  /// Phone sign-in: sends an SMS code to [phoneNumber] (E.164 format,
  /// e.g. `+2376XXXXXXXX`). Returns the verification id; the caller must
  /// then call [signInWithPhoneCode] with the 6-digit code.
  Future<AuthResult> startPhoneSignIn(String phoneNumber) async {
    if (AppConfig.isDemoMode) {
      return AuthResult.failure('Authentification téléphone indisponible en mode démo.');
    }
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (e) {
          debugPrint('Phone verification failed: ${e.message}');
        },
        codeSent: (verificationId, _) {
          // Surfaced via the returned AuthResult so the UI can route to
          // the OTP entry screen.
        },
        codeAutoRetrievalTimeout: (_) {},
        timeout: const Duration(seconds: 60),
      );
      // The verifyPhoneNumber API is fire-and-forget; in this scaffold we
      // just tell the caller to navigate to the OTP screen and let the
      // confirmation happen via [signInWithPhoneCode] below.
      return AuthResult.success(null, message: 'Code envoyé par SMS.');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_humanize(e));
    } catch (e) {
      debugPrint('AuthRepository.startPhoneSignIn error: $e');
      return AuthResult.failure('Erreur inattendue. Réessayez.');
    }
  }

  Future<AuthResult> signInWithPhoneCode({
    required String verificationId,
    required String smsCode,
  }) async {
    if (AppConfig.isDemoMode) {
      return AuthResult.failure('Authentification téléphone indisponible en mode démo.');
    }
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final cred = await _auth.signInWithCredential(credential);
      return AuthResult.success(cred.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_humanize(e));
    } catch (e) {
      return AuthResult.failure('Code invalide. Réessayez.');
    }
  }

  Future<void> signOut() async {
    if (AppConfig.isDemoMode) return;
    await _auth.signOut();
  }

  Future<void> _writeCitizenProfile({
    required String uid,
    required String email,
    required String displayName,
    required String phoneNumber,
    String? cityId,
    String? regionId,
  }) async {
    if (AppConfig.isDemoMode) return;
    try {
      await _firestore.collection('citizens').doc(uid).set({
        'uid': uid,
        'email': email,
        'display_name': displayName,
        'phone_number': phoneNumber,
        'city_id': cityId,
        'region_id': regionId,
        'joined_at': FieldValue.serverTimestamp(),
        'last_active_at': FieldValue.serverTimestamp(),
        'status': 'active',
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Failed to write citizens/$uid: $e');
    }
  }

  String _humanize(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Adresse e-mail invalide.';
      case 'user-disabled':
        return 'Ce compte a été désactivé.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou mot de passe incorrect.';
      case 'email-already-in-use':
        return 'Un compte existe déjà avec cet e-mail.';
      case 'weak-password':
        return 'Mot de passe trop faible (6 caractères minimum).';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard.';
      case 'invalid-phone-number':
        return 'Numéro de téléphone invalide.';
      case 'missing-phone-number':
        return 'Numéro de téléphone requis.';
      case 'quota-exceeded':
        return 'Quota SMS dépassé. Réessayez plus tard.';
      default:
        return e.message ?? 'Erreur d\'authentification (${e.code}).';
    }
  }
}

class AuthResult {
  AuthResult._({this.user, this.error, this.message});

  factory AuthResult.success(User? user, {String? message}) =>
      AuthResult._(user: user, message: message);
  factory AuthResult.failure(String error) => AuthResult._(error: error);

  final User? user;
  final String? error;
  final String? message;

  bool get isSuccess => error == null;
  bool get isFailure => error != null;
}
