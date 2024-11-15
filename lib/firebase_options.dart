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
        return macos;
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyDjmX2lyTaei1wssU6vHyk7OaL3QCbeia8',
    appId: '1:754649040608:web:ce4e1314fbdd14c47fb285',
    messagingSenderId: '754649040608',
    projectId: 'fluttermiage-6570c',
    authDomain: 'fluttermiage-6570c.firebaseapp.com',
    storageBucket: 'fluttermiage-6570c.appspot.com',
    measurementId: 'G-LFB2BQG3FN',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC88vaYLpDYjVo0EO1cXVMQnLOcsUiz2KY',
    appId: '1:754649040608:android:6570e5755cf8acc57fb285',
    messagingSenderId: '754649040608',
    projectId: 'fluttermiage-6570c',
    storageBucket: 'fluttermiage-6570c.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBBsFGSbrfxivugB_OCoDpzL7wwIgAcuhA',
    appId: '1:754649040608:ios:7d3a11f7372d29877fb285',
    messagingSenderId: '754649040608',
    projectId: 'fluttermiage-6570c',
    storageBucket: 'fluttermiage-6570c.appspot.com',
    iosBundleId: 'com.example.projetFlutter',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBBsFGSbrfxivugB_OCoDpzL7wwIgAcuhA',
    appId: '1:754649040608:ios:7d3a11f7372d29877fb285',
    messagingSenderId: '754649040608',
    projectId: 'fluttermiage-6570c',
    storageBucket: 'fluttermiage-6570c.appspot.com',
    iosBundleId: 'com.example.projetFlutter',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDjmX2lyTaei1wssU6vHyk7OaL3QCbeia8',
    appId: '1:754649040608:web:e3f6746d8a5ed3c47fb285',
    messagingSenderId: '754649040608',
    projectId: 'fluttermiage-6570c',
    authDomain: 'fluttermiage-6570c.firebaseapp.com',
    storageBucket: 'fluttermiage-6570c.appspot.com',
    measurementId: 'G-ZGXRGS05S1',
  );

}