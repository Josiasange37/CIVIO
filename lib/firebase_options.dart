import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDuwQTnsbzX0NJScGrxWk1eIdThZktNxzo',
    appId: '1:458071945684:web:f1a86cb44146980226e641',
    messagingSenderId: '458071945684',
    projectId: 'civio-ba41e',
    storageBucket: 'civio-ba41e.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDuwQTnsbzX0NJScGrxWk1eIdThZktNxzo',
    appId: '1:458071945684:android:f1a86cb44146980226e641',
    messagingSenderId: '458071945684',
    projectId: 'civio-ba41e',
    storageBucket: 'civio-ba41e.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDuwQTnsbzX0NJScGrxWk1eIdThZktNxzo',
    appId: '1:458071945684:ios:f1a86cb44146980226e641',
    messagingSenderId: '458071945684',
    projectId: 'civio-ba41e',
    storageBucket: 'civio-ba41e.firebasestorage.app',
    iosBundleId: 'com.civio.civio',
  );

  // Used for Linux / macOS / Windows desktop dev with the local Firebase
  // Emulator (see firebase.json). The emulator does not validate apiKey or
  // appId — any non-empty string is fine — so we mirror the web values.
  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyDuwQTnsbzX0NJScGrxWk1eIdThZktNxzo',
    appId: '1:458071945684:web:f1a86cb44146980226e641',
    messagingSenderId: '458071945684',
    projectId: 'civio-ba41e',
    storageBucket: 'civio-ba41e.firebasestorage.app',
  );
}
