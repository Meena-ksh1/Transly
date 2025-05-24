import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_screen.dart'; // Make sure to import your login screen

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  // Initialize Firebase
  @override
  void initState() {
    super.initState();
    _initializeFirebase();
  }

  // Firebase initialization method
  void _initializeFirebase() async {
    await Firebase.initializeApp();
    // Wait for 1.5 seconds before navigating to the login screen
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()), // Navigate to LoginScreen
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent, // Customize your background color here
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/logo.png', // Your logo image in assets
              width: 150, // Customize size here
              height: 150, // Customize size here
            ),
            SizedBox(height: 20),
            CircularProgressIndicator( // Optional: You can keep the loading indicator if you want
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
