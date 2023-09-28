// main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ExplorX/Screens/favourite_screen.dart';
import 'package:ExplorX/Screens/loading_screen.dart';
import 'package:ExplorX/login_directory/sign_in.dart';

 // Import the new screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure that Flutter is initialized
  await Firebase.initializeApp(); // Initialize Firebase

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF0A0E21),
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
      ),

      // Use BottomNavigationScreen as the home screen
      home: SignInScreen(),
    );
  }
}
