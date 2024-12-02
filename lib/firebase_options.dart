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
    apiKey: 'AIzaSyCl88qHvvZ830yn5nF3OUliWml2avmZVB0',
    appId: '1:20893043280:web:172d8d594abd56f8521f55',
    messagingSenderId: '20893043280',
    projectId: 'vehitrack-8cd37',
    authDomain: 'vehitrack-8cd37.firebaseapp.com',
    storageBucket: 'vehitrack-8cd37.firebasestorage.app',
    measurementId: 'G-J848MB87RC',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBjFqUV5z4cU9ANNJ85sAcu2tFGyD90EcE',
    appId: '1:20893043280:android:b24a30af737c728d521f55',
    messagingSenderId: '20893043280',
    projectId: 'vehitrack-8cd37',
    storageBucket: 'vehitrack-8cd37.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBo7gZiBghw5Dh8Y8BPvRx6FMqU7GdTZCQ',
    appId: '1:20893043280:ios:b301f1f9204e8110521f55',
    messagingSenderId: '20893043280',
    projectId: 'vehitrack-8cd37',
    storageBucket: 'vehitrack-8cd37.firebasestorage.app',
    iosBundleId: 'com.example.vehitrack',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBo7gZiBghw5Dh8Y8BPvRx6FMqU7GdTZCQ',
    appId: '1:20893043280:ios:b301f1f9204e8110521f55',
    messagingSenderId: '20893043280',
    projectId: 'vehitrack-8cd37',
    storageBucket: 'vehitrack-8cd37.firebasestorage.app',
    iosBundleId: 'com.example.vehitrack',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCl88qHvvZ830yn5nF3OUliWml2avmZVB0',
    appId: '1:20893043280:web:cec616a08c7fbc36521f55',
    messagingSenderId: '20893043280',
    projectId: 'vehitrack-8cd37',
    authDomain: 'vehitrack-8cd37.firebaseapp.com',
    storageBucket: 'vehitrack-8cd37.firebasestorage.app',
    measurementId: 'G-7M68R1SJ9Z',
  );
}