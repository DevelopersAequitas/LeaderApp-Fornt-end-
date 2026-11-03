// File generated for Leader App Firebase Configuration.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with Leader App Firebase integration.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAA9_nl067JKS7Nbj4nDoJ07Xv5Pc3jb3g',
    appId: '1:1064828045029:android:185d04646d3450bd42f60c',
    messagingSenderId: '1064828045029',
    projectId: 'peers-global-app',
    storageBucket: 'peers-global-app.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAOSPoouS7U1u8mmE7f5IriSPdocXKs0zY',
    appId: '1:1064828045029:ios:b3f4f5e20c7ce79c42f60c',
    messagingSenderId: '1064828045029',
    projectId: 'peers-global-app',
    storageBucket: 'peers-global-app.firebasestorage.app',
    iosBundleId: 'com.unity.leadersapp',
  );
}
