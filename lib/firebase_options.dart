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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
}
