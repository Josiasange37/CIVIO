import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

/// Global app configuration flags.
///
/// `firebaseEnabled` is `true` when `Firebase.initializeApp()` succeeded
/// (Android, iOS, Web with valid config). On platforms where Firebase is not
/// configured (Linux, macOS, Windows dev), it is `false` and the app runs in
/// a UI-only "Mode démo" state. Reads from Firestore return empty lists and
/// writes are no-ops, so the UI still renders without crashing.
class AppConfig {
  AppConfig._();

  static bool firebaseEnabled = false;

  /// True if the current platform supports Firebase (Android, iOS, Web).
  /// On Linux/macOS/Windows, the FlutterFire-generated
  /// `DefaultFirebaseOptions.currentPlatform` throws `UnsupportedError`,
  /// so we never even attempt to init on those targets.
  static bool get firebaseSupported {
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// True when running in demo mode (no live Firebase data).
  static bool get isDemoMode => !firebaseEnabled;
}
