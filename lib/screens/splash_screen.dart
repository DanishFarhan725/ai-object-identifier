// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:object_detect/screens/object_detection_screen.dart';
import 'dart:async';

import 'package:object_detect/screens/signin.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => SignInScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color(0xFF185A9D),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFFB2FEFA), Color(0xFF0ED2F7)],
                ),
              ),
              child: Center(
                child: Icon(Icons.search, size: 48, color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Object Detection',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            )
          ],
        ),
      ),
    );
  }
}