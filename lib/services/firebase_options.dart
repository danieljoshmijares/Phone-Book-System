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
        return macos;
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
    apiKey: 'AIzaSyApRYpu03aAtRRCRcUpY5nd03m6ek9ibgY',
    appId: '1:254407247363:web:b452e32a5b961abdaf7036',
    messagingSenderId: '254407247363',
    projectId: 'myphonebook2025',
    authDomain: 'myphonebook2025.firebaseapp.com',
    storageBucket: 'myphonebook2025.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyApRYpu03aAtRRCRcUpY5nd03m6ek9ibgY',
    appId: '1:254407247363:android:PLACEHOLDER',
    messagingSenderId: '254407247363',
    projectId: 'myphonebook2025',
    authDomain: 'myphonebook2025.firebaseapp.com',
    storageBucket: 'myphonebook2025.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyApRYpu03aAtRRCRcUpY5nd03m6ek9ibgY',
    appId: '1:254407247363:ios:PLACEHOLDER',
    messagingSenderId: '254407247363',
    projectId: 'myphonebook2025',
    authDomain: 'myphonebook2025.firebaseapp.com',
    storageBucket: 'myphonebook2025.firebasestorage.app',
    iosClientId: 'PLACEHOLDER',
    iosBundleId: 'com.example.phoneBookSystem',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyApRYpu03aAtRRCRcUpY5nd03m6ek9ibgY',
    appId: '1:254407247363:ios:PLACEHOLDER',
    messagingSenderId: '254407247363',
    projectId: 'myphonebook2025',
    authDomain: 'myphonebook2025.firebaseapp.com',
    storageBucket: 'myphonebook2025.firebasestorage.app',
    iosClientId: 'PLACEHOLDER',
    iosBundleId: 'com.example.phoneBookSystem',
  );
}
