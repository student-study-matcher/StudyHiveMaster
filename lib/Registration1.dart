import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'index.dart';

class Registration1 extends StatefulWidget {
  @override
  _Registration1State createState() => _Registration1State();
}

class _Registration1State extends State<Registration1> {
  final _auth = FirebaseAuth.instance;
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  bool _isSecurePassword = true;
  bool _isSecureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 4,
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xffad32fe),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        title: Text(
          "Registration ",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal,
            fontSize: 18,
            color: Color(0xffffffff),
          ),
        ),
        leading: Icon(
          Icons.arrow_back,
          color: Color(0xff212435),
          size: 24,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField("Username", _usernameController),
            _buildPasswordTextField("Password", _passwordController),
            _buildPasswordTextField("Confirm Password", _confirmPasswordController),
            Padding(
              padding: const EdgeInsets.all(2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildMaterialButton("Register", _registerUser),
                  const SizedBox(width: 5),
                  _buildMaterialButton("Already Have an Account? \nLogin", () {
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

  Widget _buildTextField(String label, TextEditingController controller) {
    return _buildInputField(
      label,
      controller,
      obscureText: false,
    );
  }

  Widget _buildPasswordTextField(String label, TextEditingController controller) {
    return _buildInputField(
      label,
      controller,
      obscureText: label == "Password" ? _isSecurePassword : _isSecureConfirmPassword,
      suffixIcon: label == "Password" || label == "Confirm Password"
          ? IconButton(
        icon: Icon(
          _isSecureIcon(label),
          color: const Color(0xff000000),
        ),
        onPressed: () => _toggleSecurePassword(label),
      )
          : null,
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {bool obscureText = false, Widget? suffixIcon}) {
    return Container(
      height: 50,
      margin: const EdgeInsets.all(0),
      padding: const EdgeInsets.all(5),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        textAlign: TextAlign.start,
        maxLines: 1,
        style: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: Color(0xff000000),
        ),
        decoration: _buildInputDecoration(label, suffixIcon: suffixIcon),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, {Widget? suffixIcon}) {
    return InputDecoration(
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
      suffixIcon: suffixIcon,
    );
  }

  IconData _isSecureIcon(String label) =>
      label == "Password" ? _isSecurePassword ? Icons.visibility : Icons.visibility_off : _isSecureConfirmPassword ? Icons.visibility : Icons.visibility_off;

  void _toggleSecurePassword(String label) {
    setState(() {
      if (label == "Password") {
        _isSecurePassword = !_isSecurePassword;
      } else {
        _isSecureConfirmPassword = !_isSecureConfirmPassword;
      }
    });
  }

  Widget _buildMaterialButton(String text, void Function() onPressed) {
    return MaterialButton(
      onPressed: onPressed,
      color: Colors.white,
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

  Future<void> _registerUser() async {
    final email = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

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
        // Registration successful, navigate to the next screen
        print("registration successful");
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Registration2(user: newUser.user)),
        );
      }
    } on FirebaseAuthException catch (e) {
      _showDialog('Registration Error', e.message ?? 'An unknown error occurred.');
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
}
