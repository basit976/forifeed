import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fori_feed/News_screen2.dart';
import 'package:fori_feed/News_screenTestingV.dart';
import 'package:fori_feed/ProfileScreen.dart';
import 'package:fori_feed/news_screen.dart';
import 'package:fori_feed/selection.dart';
import 'Home_page.dart';
import 'package:flutter/material.dart';

import 'login_screen.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase for web and mobile
  if (kIsWeb) {
    // Web initialization
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyCnRMmBYSqackHMSq16Ny6SvJMEvorMGWg",
        appId: "1:577943125304:web:92d03779123c48434155cd",
        messagingSenderId: "577943125304",
        projectId: "flutterfori",
        authDomain: "flutterfori.firebaseapp.com",  // Add the authDomain
        storageBucket: "flutterfori.appspot.com",  // Add the storageBucket
        databaseURL: "https://flutterfori.firebaseio.com",  // Add the databaseURL
      ),
    );
  } else {
    // Mobile initialization (uses google-services.json or GoogleService-Info.plist)
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fori Feed', // App Title
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(), // Home screen after initialization
    );
  }
}
