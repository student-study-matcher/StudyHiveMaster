import 'package:flutter/material.dart';
import 'Login.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyD9Rmsgi-hOz6eZUTcVbb7QUFtzPQcXiJk",
          appId: "1:795494178260:web:bd07547862dd0eec870a41",
          messagingSenderId: "795494178260",
          projectId: "study-hive-9a0e6",
          databaseURL: "https://study-hive-9a0e6-default-rtdb.europe-west1.firebasedatabase.app",
          storageBucket: "study-hive-9a0e6.appspot.com"
      )
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Login(),
    );
  }
}
