import 'package:flutter/material.dart';
import 'Login.dart';
import 'Registration2.dart';

class Registration1 extends StatefulWidget {
  @override
  _Registration1State createState() => _Registration1State();
}

class _Registration1State extends State<Registration1> {
  bool _isSecurePassword = true;
  bool _isSecureConfirmPassword = true;
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      appBar: AppBar(
        elevation: 4,
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xffad32fe),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              width: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              "Study Hive",
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal,
                fontSize: 14,
                color: Color(0xffffffff),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            buildTextField("Username", _usernameController),
            buildPasswordTextField("Password", _passwordController),
            buildPasswordTextField("Confirm Password", _confirmPasswordController),
            Padding(
              padding: const EdgeInsets.all(2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  buildMaterialButton("Register", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Registration2()),
                    );
                  }),
                  const SizedBox(width: 5),
                  buildMaterialButton("Already Have an Account? \nLogin", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller) {
    return Container(
      height: 50,
      margin: const EdgeInsets.all(0),
      padding: const EdgeInsets.all(5),
      child: TextField(
        controller: controller,
        obscureText: false,
        textAlign: TextAlign.start,
        maxLines: 1,
        style: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: Color(0xff000000),
        ),
        decoration: _buildInputDecoration(label),
      ),
    );
  }

  Widget buildPasswordTextField(String label, TextEditingController controller) {
    return Container(
      height: 50,
      margin: const EdgeInsets.all(0),
      padding: const EdgeInsets.all(5),
      child: TextField(
        controller: controller,
        obscureText: label == "Password" ? _isSecurePassword : _isSecureConfirmPassword,
        textAlign: TextAlign.start,
        maxLines: 1,
        style: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: Color(0xff000000),
        ),
        decoration: _buildInputDecoration(label),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 14,
      color: Color(0xff000000),
    ),
    hintText: "Enter $label",
    hintStyle: const TextStyle(
      fontWeight: FontWeight.w400,
      fontSize: 14,
      color: Color(0xff000000),
    ),
    filled: true,
    fillColor: const Color(0xfff2f2f3),
    isDense: false,
    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    suffixIcon: label == "Password" || label == "Confirm Password"
        ? IconButton(
      icon: Icon(
        _isSecureIcon(label),
        color: const Color(0xff000000),
      ),
      onPressed: () {
        _toggleSecurePassword(label);
      },
    )
        : null,
  );

  void _toggleSecurePassword(String label) {
    setState(() {
      if (label == "Password") {
        _isSecurePassword = !_isSecurePassword;
      } else {
        _isSecureConfirmPassword = !_isSecureConfirmPassword;
      }
    });
  }

  IconData _isSecureIcon(String label) =>
      label == "Password"
          ? _isSecurePassword
          ? Icons.visibility
          : Icons.visibility_off
          : _isSecureConfirmPassword
          ? Icons.visibility
          : Icons.visibility_off;

  Widget buildMaterialButton(String text, void Function() onPressed) {
    return MaterialButton(
      onPressed: onPressed,
      color: const Color(0xffffffff),
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: Color(0xff808080), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          fontStyle: FontStyle.normal,
        ),
      ),
      textColor: const Color(0xff000000),
      height: 80,
      minWidth: 200,
    );
  }
}
