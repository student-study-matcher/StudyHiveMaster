import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'Registration1.dart';
import 'HomeScreen.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _auth = FirebaseAuth.instance;
  final _emailOrUsernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _passwordVisible = false;

  void _signIn() async {
    try {
      final input = _emailOrUsernameController.text.trim();
      String email = '';

      if (input.contains('@')) {
        email = input;
      } else {
        final usernameSnapshot = await FirebaseDatabase.instance
            .ref()
            .child('Usernames/$input')
            .get();
        if (usernameSnapshot.exists) {
          final userId = usernameSnapshot.value as String?;
          if (userId != null) {
            final emailSnapshot =
            await FirebaseDatabase.instance.ref()
                .child('Users/$userId/email')
                .get();
            if (emailSnapshot.exists && emailSnapshot.value != null) {
              email = emailSnapshot.value as String;
            } else {
              throw FirebaseAuthException(
                  code: 'email-not-found',
                  message: 'Email not found for username.');
            }
          } else {
            throw FirebaseAuthException(
                code: 'username-not-found', message: 'Username not found.');
          }
        } else {
          throw FirebaseAuthException(
              code: 'username-not-found', message: 'Username not found.');
        }
      }

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: _passwordController.text,
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
            (Route<dynamic> route) => false,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'An unknown error occurred.';
      });
    }
  }

  void _resetPassword() async {
    final email = _emailOrUsernameController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      setState(() {
        _errorMessage =
        'Please enter a valid email address for password reset.';
      });
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      setState(() {
        _errorMessage = 'Password reset link sent to $email';
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'An unknown error occurred';
      });
    }
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
              SizedBox(height: 40),
              Container(
                padding: EdgeInsets.all(20),
                width: MediaQuery.of(context).size.width * 0.5,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome!',
                      style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Please Login to Your Account',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _emailOrUsernameController,
                      decoration: InputDecoration(
                        labelText: 'Email Address or Username',
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_passwordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible ? Icons.visibility : Icons
                                .visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _resetPassword,
                          child: Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Colors.orangeAccent[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: _signIn,
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
                          'Login',
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
                              Registration1()),
                        );
                      },
                      child: Text(
                        'Register',
                        style: TextStyle(
                          color: Colors.deepPurple[900],
                          fontSize: 18,
                          )

                        ),
                      ),

                    SizedBox(height: 16),
                    Text(
                      _errorMessage,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
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
