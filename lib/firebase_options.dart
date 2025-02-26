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
    apiKey: 'AIzaSyD21NrYRDJyJkbzGnVG7puTEJP3TJLSyDY',
    appId: '1:830891211750:web:98cba3b6dfdcfd8ab53427',
    messagingSenderId: '830891211750',
    projectId: 'event-management-project-26100',
    authDomain: 'event-management-project-26100.firebaseapp.com',
    storageBucket: 'event-management-project-26100.firebasestorage.app',
    measurementId: 'G-4RX42Z9036',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBGwNbTtfg0KMwI7XWEieEbaUDqNlsogLI',
    appId: '1:830891211750:android:991759b0a03ea75ab53427',
    messagingSenderId: '830891211750',
    projectId: 'event-management-project-26100',
    storageBucket: 'event-management-project-26100.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDmQBYH73TpVm63WjpKeBWyg5SL2jbwO1A',
    appId: '1:830891211750:ios:bd74ea3169b78251b53427',
    messagingSenderId: '830891211750',
    projectId: 'event-management-project-26100',
    storageBucket: 'event-management-project-26100.firebasestorage.app',
    iosBundleId: 'com.example.eventManagementProject',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDmQBYH73TpVm63WjpKeBWyg5SL2jbwO1A',
    appId: '1:830891211750:ios:bd74ea3169b78251b53427',
    messagingSenderId: '830891211750',
    projectId: 'event-management-project-26100',
    storageBucket: 'event-management-project-26100.firebasestorage.app',
    iosBundleId: 'com.example.eventManagementProject',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD21NrYRDJyJkbzGnVG7puTEJP3TJLSyDY',
    appId: '1:830891211750:web:eef3692e5d5c3aafb53427',
    messagingSenderId: '830891211750',
    projectId: 'event-management-project-26100',
    authDomain: 'event-management-project-26100.firebaseapp.com',
    storageBucket: 'event-management-project-26100.firebasestorage.app',
    measurementId: 'G-TDDELH2XJ0',
  );
}
