// PLACEHOLDER — replace by running:
//   dart pub global run flutterfire_cli:flutterfire configure --platforms=web,android
// which regenerates this file with the real keys of the Firebase project.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError('DefaultFirebaseOptions are not configured for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCVdRUfnufFLg2AJ9piZ6QEovPQgs0t7Cc',
    appId: '1:502048843819:web:020847f957a461b001626e',
    messagingSenderId: '502048843819',
    projectId: 'emplake-20262',
    authDomain: 'emplake-20262.firebaseapp.com',
    storageBucket: 'emplake-20262.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC6_uiCUAi5vqwVzZnN61pj4nGgP1bJq7U',
    appId: '1:502048843819:android:d1a9132d119f3afc01626e',
    messagingSenderId: '502048843819',
    projectId: 'emplake-20262',
    storageBucket: 'emplake-20262.firebasestorage.app',
  );
}
