import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'index.dart';

class Registration2 extends StatefulWidget {
  final User? user;

  Registration2({Key? key, this.user}) : super(key: key);

  @override
  _Registration2State createState() => _Registration2State();
}

class _Registration2State extends State<Registration2> {
  String userCourse = "Computer Science";
  String userUniversity = "University of Portsmouth";
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController dobController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      appBar: buildAppBar(),
      body: Padding(
        padding: EdgeInsets.all(5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            buildTextField("First Name", "Enter your first name", firstNameController),
            buildTextField("Last Name", "Enter your last name", lastNameController),
            buildTextField("Date Of Birth", null, dobController, readOnly: true, onTap: _selectDate),
            buildDropdown("Course", userCourse, ["Computer Science", "Maths", "English", "Aerospace Engineering", "Criminology", "Business"], (value) => setState(() => userCourse = value ?? "")),
            buildDropdown("University", userUniversity, ["University of Portsmouth", "University of Exeter", "University of Southampton", "University of Swansea"], (value) => setState(() => userUniversity = value?? "")),
            buildConfirmDetailsButton(),
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
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
    );
  }

  Widget buildTextField(String labelText, String? hintText, TextEditingController controller, {bool readOnly = false, GestureTapCallback? onTap}) {
    return Container(
      margin: EdgeInsets.all(0),
      padding: EdgeInsets.all(0),
      width: 200,
      height: 50,
      decoration: BoxDecoration(
        color: Color(0x1f000000),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: Color(0x4d9e9e9e), width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(5),
        child: TextField(
          controller: controller,
          obscureText: false,
          textAlign: TextAlign.start,
          maxLines: 1,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: Color(0xff000000),
          ),
          decoration: InputDecoration(
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
              borderSide: BorderSide(color: Color(0xff000000), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
              borderSide: BorderSide(color: Color(0xff000000), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
              borderSide: BorderSide(color: Color(0xff000000), width: 1),
            ),
            labelText: labelText,
            labelStyle: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Color(0xff000000),
            ),
            hintText: hintText,
            hintStyle: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: Color(0xff000000),
            ),
            filled: true,
            fillColor: Color(0xfff2f2f3),
            isDense: false,
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          ),
          onTap: onTap,
          readOnly: readOnly,
        ),
      ),
    );
  }

  Widget buildDropdown(String labelText, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Container(
      margin: EdgeInsets.all(0),
      padding: EdgeInsets.all(0),
      width: 200,
      height: 50,
      decoration: BoxDecoration(
        color: Color(0x1f000000),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: Color(0x4d9e9e9e), width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Container(
          width: 130,
          height: 50,
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: Color(0xffffffff),
            borderRadius: BorderRadius.circular(0),
          ),
          child: DropdownButton<String>(
            value: value,
            items: items.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            style: TextStyle(
              color: Color(0xff000000),
              fontSize: 16,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.normal,
            ),
            onChanged: onChanged,
            elevation: 8,
            isExpanded: true,
          ),
        ),
      ),
    );
  }

  Widget buildConfirmDetailsButton() {
    return Container(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      width: 200,
      height: 50,
      decoration: BoxDecoration(
        color: Color(0x1f000000),
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: Color(0x4d9e9e9e), width: 1),
      ),
      child: MaterialButton(
        onPressed: saveUserData,
        color: Color(0xff48ff54),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: Color(0xff808080), width: 1),
        ),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          "Confirm Details",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
          ),
        ),
        textColor: Color(0xff000000),
        height: 40,
        minWidth: 140,
      ),
    );
  }

  Future<void> _selectDate() async {
    DateTime? _picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (_picked != null) {
      setState(() {
        dobController.text = _picked.toString().split(" ")[0];
      });
    }
  }

  Future<void> saveUserData() async {
    String userFirstName = firstNameController.text;
    String userLastName = lastNameController.text;
    String userDOBString = dobController.text;

    if (userFirstName == "" || userLastName == "" || userDOBString == "") {
      showErrorDialog('Please fill in all the required fields.');
      return;
    }

    DateTime userDOB = DateTime.parse(userDOBString);

    DateTime now = DateTime.now();
    int age = now.year - userDOB.year;

    if (age < 18) {
      showErrorDialog('Users must be 18 or over');
      return;
    }

    if (userFirstName.length > 50 || userLastName.length > 50) {
      showErrorDialog('Input too Long!');
      return;
    }

    try {
      User? user = _auth.currentUser;

      if (user != null) {
        await _database.reference().child('users').child(user.uid).set({
          'firstName': userFirstName,
          'lastName': userLastName,
          'DOB': userDOB.toIso8601String(),
          'course': userCourse,
          'university': userUniversity,
        });

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Registration3()),
        );
      } else {
        print('User not authenticated.');
      }
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
        );
      },
    );
  }
}
