import 'package:flutter/material.dart';
import 'Login.dart';
import 'HomeScreen.dart';
import 'Forums.dart';
import 'UserProfile.dart';
import 'Settings.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Login(),
    );
  }
}

