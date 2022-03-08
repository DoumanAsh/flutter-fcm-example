import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

//MANABE: Place your config from firebase (each app is separated per platform)
class DefaultFirebaseConfig {
  static FirebaseOptions get platformOptions {
    if (kIsWeb) {
      // Web
      return const FirebaseOptions(
        apiKey: "AIzaSyBgIiRep7VsTD8A45bQf6gkzxbMt7NnSL4",
        authDomain: "omega-metric-229914.firebaseapp.com",
        projectId: "omega-metric-229914",
        storageBucket: "omega-metric-229914.appspot.com",
        messagingSenderId: "1063833877818",
        appId: "1:1063833877818:web:ee6fac33a8239be0d02403",
        measurementId: "G-494G8RB67K"
      );
    } else if (Platform.isIOS || Platform.isMacOS) {
      // iOS and MacOS
      return const FirebaseOptions(
        apiKey: "AIzaSyBgIiRep7VsTD8A45bQf6gkzxbMt7NnSL4",
        authDomain: "omega-metric-229914.firebaseapp.com",
        projectId: "omega-metric-229914",
        storageBucket: "omega-metric-229914.appspot.com",
        messagingSenderId: "1063833877818",
        appId: "1:1063833877818:web:394c18aedc08dad7d02403"
        //todo
      );
    } else {
      // Android
      return const FirebaseOptions(
        appId: "1:1063833877818:android:20a5db9cfdb45fbcd02403",
        apiKey: "AIzaSyBtpCf1la62Gvs4zvgGDocpW3csqG5eyAE",
        authDomain: "omega-metric-229914.firebaseapp.com",
        projectId: "omega-metric-229914",
        storageBucket: "omega-metric-229914.appspot.com",
        messagingSenderId: "1063833877818",
        androidClientId: "1063833877818-j507lg9o3vs8lcutratrmvvlcevcs8bp.apps.googleusercontent.com"
      );
    }
  }
}
