import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tarek_proj/pages/Choice.dart';
import 'package:tarek_proj/pages/Login.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Check if Firebase is already initialized
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        name: 'Tarek-Proj',
        options: FirebaseOptions(
          apiKey: "AIzaSyAkNposTrjqFsT7zog5xXI1fk-mgvQ9vzM",
          appId: '1:847973994383:android:a72c205d18d4fe240605fa',
          messagingSenderId: "847973994383",
          projectId: "tarek-fd908",
        ),
      );
    }
    runApp(MyApp());
  } catch (e) {
    print("Firebase Initialization Error: $e");
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Choice(), // Set the initial screen
    );
  }
}


