// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
    apiKey: 'AIzaSyBHau_IQNWy_N3KaxIJsW5mZvizsvW1Tp0',
    appId: '1:282788916457:web:225da9a77a33804f4ed478',
    messagingSenderId: '282788916457',
    projectId: 'firebase-message-demo',
    authDomain: 'fir-message-demo-2ab40.firebaseapp.com',
    storageBucket: 'firebase-message-demo.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCUE_Ie29vZ_rO34S4s8C4bW9WVkvXuyCo',
    appId: '1:282788916457:android:2b1135cdad7ad3e64ed478',
    messagingSenderId: '282788916457',
    projectId: 'firebase-message-demo',
    storageBucket: 'firebase-message-demo.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBAbPQJZNCgEUBJIO8zz7LSTAo_u-LHEkg',
    appId: '1:282788916457:ios:a879cd61de5a5dc34ed478',
    messagingSenderId: '282788916457',
    projectId: 'firebase-message-demo',
    storageBucket: 'firebase-message-demo.appspot.com',
    iosBundleId: 'com.example.firebaseMessageDemo',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBAbPQJZNCgEUBJIO8zz7LSTAo_u-LHEkg',
    appId: '1:282788916457:ios:c453d7e9afdd120e4ed478',
    messagingSenderId: '282788916457',
    projectId: 'firebase-message-demo',
    storageBucket: 'firebase-message-demo.appspot.com',
    iosBundleId: 'com.example.firebaseMessageDemo.RunnerTests',
  );
}