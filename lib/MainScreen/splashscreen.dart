import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vehitrack/AuthScreen.dart';
import 'package:vehitrack/MainScreen/Regvehicle.dart';
// Registration form screen
import 'package:vehitrack/main.dart'; // Home screen

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    navigateBasedOnState();
  }

  Future<void> navigateBasedOnState() async {
    // Initialize Firebase
    await Firebase.initializeApp();

    // Check Shared Preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFormCompleted = prefs.getBool('isFormCompleted') ?? false;

    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    // Decide navigation based on user state
    if (user == null) {
      // Navigate to Login Screen
      navigateTo(AuthScreen());
    } else if (!isFormCompleted) {
      // Navigate to Registration Form
      navigateTo(AddDataScreen());
    } else {
      // Navigate to Home Screen
      navigateTo(MyHomePage(title: "Home Page"));
    }
  }

  void navigateTo(Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset('Animation - 1732128982566.json'),
            SizedBox(height: 20),
            Text(
              'Splash Screen',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
