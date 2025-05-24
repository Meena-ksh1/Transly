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
    apiKey: 'AIzaSyAlqY1JXMd96GruxlFC9IyRRAywHtmUm7Q',
    appId: '1:160951551838:web:733735feee4e237de5b1cf',
    messagingSenderId: '160951551838',
    projectId: 'transly-c98f9',
    authDomain: 'transly-c98f9.firebaseapp.com',
    storageBucket: 'transly-c98f9.firebasestorage.app',
    measurementId: 'G-GHXSRC2VPM',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB4iIe5kYQYVRp_yTQXTj7c7oc770nc5NI',
    appId: '1:160951551838:android:72a65684b4884491e5b1cf',
    messagingSenderId: '160951551838',
    projectId: 'transly-c98f9',
    storageBucket: 'transly-c98f9.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDxcThnkacE2FW_KNvUL4H-QqDqjeXAbAA',
    appId: '1:160951551838:ios:eb8822097fa487fce5b1cf',
    messagingSenderId: '160951551838',
    projectId: 'transly-c98f9',
    storageBucket: 'transly-c98f9.firebasestorage.app',
    iosBundleId: 'com.example.transly',
  );

  // Corrected macOS setup (previously using iOS values)
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDxcThnkacE2FW_KNvUL4H-QqDqjeXAbAA',
    appId: '1:160951551838:macos:eb8822097fa487fce5b1cf',  // Ensure this is correct for macOS
    messagingSenderId: '160951551838',
    projectId: 'transly-c98f9',
    storageBucket: 'transly-c98f9.firebasestorage.app',
    iosBundleId: 'com.example.transly',  // Keep the iOS bundle ID here for macOS
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAlqY1JXMd96GruxlFC9IyRRAywHtmUm7Q',
    appId: '1:160951551838:web:94248818768bae39e5b1cf',
    messagingSenderId: '160951551838',
    projectId: 'transly-c98f9',
    authDomain: 'transly-c98f9.firebaseapp.com',
    storageBucket: 'transly-c98f9.firebasestorage.app',
    measurementId: 'G-NN1RE4J3GQ',
  );
}
