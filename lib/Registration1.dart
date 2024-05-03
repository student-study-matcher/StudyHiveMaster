import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Login.dart';
import 'Registration2.dart';
import 'package:firebase_database/firebase_database.dart';

class Registration1 extends StatefulWidget {
  @override
  Registration1State createState() => Registration1State();
}
class Registration1State extends State<Registration1> {
  final _auth = FirebaseAuth.instance;
  final _database = FirebaseDatabase.instance.reference();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  void _registerUser() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      _showDialog('Error', 'Passwords do not match.');
      return;
    }
    try {
      final newUser = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (newUser.user != null) {
        _database.child('Users').child(newUser.user!.uid).set({
          'email': email,
        });
        print("registration successful");
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Registration2(user: newUser.user)),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showDialog(
          'Registration Error', e.message ?? 'An unknown error occurred.');
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery
              .of(context)
              .size
              .height,
          width: MediaQuery
              .of(context)
              .size
              .width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF8A2387),
                Color(0xFFE94057),
                Color(0xFFF27121),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 80),
              Image.asset(
                'assets/logo.png',
                width: 150,
                height: 50,
              ),
              SizedBox(height: 10),
              Text(
                'Study Hive',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),

              SizedBox(height: 30),
              Container(
                padding: EdgeInsets.all(20),
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.5,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Registration',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 20),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(labelText: 'Email'),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(labelText: 'Password'),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                          labelText: 'Confirm Password'),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: _registerUser,
                      child: Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF8A2387),
                              Color(0xFFE94057),
                              Color(0xFFF27121),
                            ],
                          ),
                        ),
                        child: Text(
                          'Register',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>
                              Registration2()),
                        );
                      },
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Login()),
                          );
                        },
                        child: Text('Already have an account? Login'),
                      ),
                    ),
                  ],

                ),
              ),

            ],
          ),
        ),
      ),

    );
  }
}
