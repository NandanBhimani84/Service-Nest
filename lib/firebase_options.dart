// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
    apiKey: 'AIzaSyDlSp_oZlrPDu-2rFnCTq1MXsIGxiRWLYU',
    appId: '1:413813736262:web:024fd79e4ae3c2ef63db47',
    messagingSenderId: '413813736262',
    projectId: 'service-nest-3b43d',
    authDomain: 'service-nest-3b43d.firebaseapp.com',
    storageBucket: 'service-nest-3b43d.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBN4ILe9bLweJOtBklUcJ9LOYNH-4DJJs8',
    appId: '1:413813736262:android:f9d64fabe5d515df63db47',
    messagingSenderId: '413813736262',
    projectId: 'service-nest-3b43d',
    storageBucket: 'service-nest-3b43d.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyArJ6ipcBKhFsddbChDvRRDcGeVVnC_Yko',
    appId: '1:413813736262:ios:9d9caeb865348db963db47',
    messagingSenderId: '413813736262',
    projectId: 'service-nest-3b43d',
    storageBucket: 'service-nest-3b43d.firebasestorage.app',
    iosBundleId: 'com.example.majorProject1',
  );
}
