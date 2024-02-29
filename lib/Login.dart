import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'index.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isSecurePassword = true;

  void _signIn() async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      print("Login successful");
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'An unknown error occurred';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Login"),
        backgroundColor: Color(0xffad32fe),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            buildTextField("Username", _emailController),
            buildPasswordTextField("Password", _passwordController),
            buildLoginButtons(),
            SizedBox(height: 16.0),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: TextField(
        controller: controller,
        obscureText: false,
        textAlign: TextAlign.start,
        style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: Color(0xff000000),
        ),
        decoration: InputDecoration(
          labelText: "Enter $label",
          labelStyle: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Color(0xff000000),
          ),
          filled: true,
          fillColor: Color(0xfff2f2f3),
        ),
      ),
    );
  }

  Widget buildPasswordTextField(String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: TextField(
        controller: controller,
        obscureText: _isSecurePassword,
        textAlign: TextAlign.start,
        style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: Color(0xff000000),
        ),
        decoration: InputDecoration(
          labelText: "Enter $label",
          labelStyle: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Color(0xff000000),
          ),
          filled: true,
          fillColor: Color(0xfff2f2f3),
          suffixIcon: IconButton(
            icon: Icon(_isSecurePassword ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                _isSecurePassword = !_isSecurePassword;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget buildLoginButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        buildMaterialButton("Login", _signIn, Color(0xfffed140)),
        buildMaterialButton("Register", () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Registration1()),
          );
        }, Color(0xfffed141)),
      ],
    );
  }

  Widget buildMaterialButton(String text, void Function() onPressed, Color color) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(5),
        child: MaterialButton(
          onPressed: onPressed,
          color: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: Color(0xff808080), width: 1),
          ),
          padding: EdgeInsets.all(16),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
            ),
          ),
          textColor: Color(0xff000000),
          height: 40,
          minWidth: 100,
        ),
      ),
    );
  }
}
