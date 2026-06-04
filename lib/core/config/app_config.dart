import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

/// Global app configuration flags.
///
/// `firebaseEnabled` is `true` when `Firebase.initializeApp()` succeeded
/// (Android, iOS, Web with valid config, or any desktop with the local
/// Firebase Emulator running). On platforms where Firebase cannot be reached
/// the app runs in a UI-only "Mode démo" state. Reads from Firestore return
/// empty lists and writes are no-ops, so the UI still renders without
/// crashing.
class AppConfig {
  AppConfig._();

  /// True once `Firebase.initializeApp()` has succeeded.
  static bool firebaseEnabled = false;

  /// True on platforms where the FlutterFire-generated options file is known
  /// to have a valid `FirebaseOptions` entry. Android, iOS, Web, plus
  /// Linux/macOS/Windows (we now provide a `linux` options block that the
  /// Firebase Emulator accepts with any non-empty keys).
  static bool get firebaseSupported {
    if (kIsWeb) return true;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows;
  }

  /// True on a desktop platform where we expect the user to run a local
  /// Firebase Emulator (see `firebase.json` + `EMULATORS.md`).
  static bool get isDesktopEmulatorHost {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows;
  }

  /// Where the Firebase Emulator listens. The CLI default ports (see
  /// `firebase.json`): auth = 9099, firestore = 8080.
  static const String emulatorHost = '127.0.0.1';
  static const int authEmulatorPort = 9099;
  static const int firestoreEmulatorPort = 8080;

  /// Force the app to talk to the local emulator on desktop even if the
  /// production project config is present. Set to `false` to talk to the
  /// real Firebase project from a desktop (rare).
  static const bool useEmulatorByDefault = true;

  /// True when running in demo mode (no live Firebase data).
  static bool get isDemoMode => !firebaseEnabled;
}
