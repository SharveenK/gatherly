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
    apiKey: 'AIzaSyCiJy2NUYZRQ72O1MKTYh2F7s9LgT9e5as',
    appId: '1:390022313677:web:2e690982d83071fae0db84',
    messagingSenderId: '390022313677',
    projectId: 'gatherly-65f9b',
    authDomain: 'gatherly-65f9b.firebaseapp.com',
    storageBucket: 'gatherly-65f9b.appspot.com',
    measurementId: 'G-XGT63YXLR1',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDUJdjh2ZLEUW8ueroIita3n6ibK81V8Rc',
    appId: '1:390022313677:android:1bd08d64ddb0103fe0db84',
    messagingSenderId: '390022313677',
    projectId: 'gatherly-65f9b',
    storageBucket: 'gatherly-65f9b.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB0sxCPyQNzDLdxMW-pqnEoRif7xteVQ6s',
    appId: '1:390022313677:ios:06efd36b2bec9e78e0db84',
    messagingSenderId: '390022313677',
    projectId: 'gatherly-65f9b',
    storageBucket: 'gatherly-65f9b.appspot.com',
    iosBundleId: 'com.example.gatherly',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB0sxCPyQNzDLdxMW-pqnEoRif7xteVQ6s',
    appId: '1:390022313677:ios:06efd36b2bec9e78e0db84',
    messagingSenderId: '390022313677',
    projectId: 'gatherly-65f9b',
    storageBucket: 'gatherly-65f9b.appspot.com',
    iosBundleId: 'com.example.gatherly',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCiJy2NUYZRQ72O1MKTYh2F7s9LgT9e5as',
    appId: '1:390022313677:web:836709fe483bb50ce0db84',
    messagingSenderId: '390022313677',
    projectId: 'gatherly-65f9b',
    authDomain: 'gatherly-65f9b.firebaseapp.com',
    storageBucket: 'gatherly-65f9b.appspot.com',
    measurementId: 'G-5WBZT5NDXS',
  );
}