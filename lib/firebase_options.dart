import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return FirebaseOptions(
        apiKey: dotenv.env['WEB_API_KEY']!,
        appId: '1:189104060663:web:c95e4929faad6c43c8bbf2',
        messagingSenderId: '189104060663',
        projectId: 'kasungu-248c4',
        authDomain: 'kasungu-248c4.firebaseapp.com',
        storageBucket: 'kasungu-248c4.firebasestorage.app',
        measurementId: 'G-S2Q0WXVXZV',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return FirebaseOptions(
          apiKey: dotenv.env['ANDROID_API_KEY']!,
          appId: '1:189104060663:android:e0de13bf3fb7b9bac8bbf2',
          messagingSenderId: '189104060663',
          projectId: 'kasungu-248c4',
          storageBucket: 'kasungu-248c4.firebasestorage.app',
        );
      case TargetPlatform.iOS:
        return FirebaseOptions(
          apiKey: dotenv.env['IOS_API_KEY']!,
          appId: '1:189104060663:ios:d9f8ebc4c7f0ebf5c8bbf2',
          messagingSenderId: '189104060663',
          projectId: 'kasungu-248c4',
          storageBucket: 'kasungu-248c4.firebasestorage.app',
          iosBundleId: 'com.example.kasunguRoutes',
        );
      case TargetPlatform.macOS:
        return FirebaseOptions(
          apiKey: dotenv.env['MACOS_API_KEY']!,
          appId: '1:189104060663:ios:d9f8ebc4c7f0ebf5c8bbf2',
          messagingSenderId: '189104060663',
          projectId: 'kasungu-248c4',
          storageBucket: 'kasungu-248c4.firebasestorage.app',
          iosBundleId: 'com.example.kasunguRoutes',
        );
      case TargetPlatform.windows:
        return FirebaseOptions(
          apiKey: dotenv.env['WINDOWS_API_KEY']!,
          appId: '1:189104060663:web:537617461ddbc24cc8bbf2',
          messagingSenderId: '189104060663',
          projectId: 'kasungu-248c4',
          authDomain: 'kasungu-248c4.firebaseapp.com',
          storageBucket: 'kasungu-248c4.firebasestorage.app',
          measurementId: 'G-HC3GZE2EH5',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }
}
