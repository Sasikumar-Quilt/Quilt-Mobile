
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
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
    apiKey: 'AIzaSyBe42WZfTrOAdi85qKvr-bZilM20RDZ30k',
    appId: '1:930588986366:android:c10ee5a45dbf1bf33e4eaf',
    messagingSenderId: '930588986366',
    projectId: 'quilt-8c01a',
    storageBucket: 'quilt-8c01a.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCWnA6t0Thq6bfaH3n922jWzOlRlUcW0k8',
    appId: '1:930588986366:android:c10ee5a45dbf1bf33e4eaf',
    messagingSenderId: '930588986366',
    projectId: 'quilt-8c01a',
    storageBucket: 'quilt-8c01a.appspot.com',
    androidClientId:
    '930588986366-09s6gokn7m8j9g4ulu9ordgh2nt2uea7.apps.googleusercontent.com',
    iosClientId:
    '930588986366-0adio0ec0gma2n63rtfj1b25lsfat5je.apps.googleusercontent.com',
    iosBundleId: 'com.q-u-i-l-t.app',
  );


}