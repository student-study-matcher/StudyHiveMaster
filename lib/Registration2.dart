import 'package:flutter/material.dart';
import 'Registration3.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class Registration2 extends StatefulWidget {
  final User? user;

  Registration2({Key? key, this.user}) : super(key: key);
  @override
  _Registration2State createState() => _Registration2State();
}

class _Registration2State extends State<Registration2> {
  String? userCourse;
  String? userUniversity;
  List<String> courses = [];
  List<String> universities = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  String? usernameError;


  @override
  void initState() {
    super.initState();
    fetchUniversities();
    fetchCourses();
  }

  Future<void> fetchUniversities() async {
    DatabaseEvent event = await _database.ref()
        .child('Universities')
        .once();
    if (event.snapshot.value != null) {
      Map<dynamic, dynamic> universitiesMap = Map<dynamic, dynamic>.from(
          event.snapshot.value as Map);
      setState(() {
        universities = universitiesMap.values.toList().cast<String>();
        userUniversity = universities.isNotEmpty ? universities.first : null;
      });
    }
  }

  Future<void> fetchCourses() async {
    DatabaseEvent event = await _database.ref().child('Subjects').once();
    if (event.snapshot.value != null) {
      Map<dynamic, dynamic> coursesMap = Map<dynamic, dynamic>.from(
          event.snapshot.value as Map);
      setState(() {
        courses = coursesMap.values.toList().cast<String>();
        userCourse = courses.isNotEmpty ? courses.first : null;
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 260),
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
              SizedBox(height: 20),
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
                      controller: firstNameController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        hintStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: 14,
                          color: Color(0xff000000),
                        ),
                        filled: true,
                        fillColor: Color(0xfff2f2f3),
                        isDense: false,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                      ),
                    ),

                    SizedBox(height: 20),
                    TextField(
                      controller: lastNameController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                        hintStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: 14,
                          color: Color(0xff000000),
                        ),
                        filled: true,
                        fillColor: Color(0xfff2f2f3),
                        isDense: false,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                      ),
                    ),

                    SizedBox(height: 20),
                    TextField(
                      controller: dobController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Date of Birth',
                        hintStyle: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: 14,
                          color: Color(0xff000000),
                        ),
                        filled: true,
                        fillColor: Color(0xfff2f2f3),
                        isDense: false,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                      ),
                      onTap: () {
                        _selectDate();
                      },
                      readOnly: true,
                    ),

                    SizedBox(height: 20),
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Courses',
                        filled: true,
                        fillColor: Color(0xfff2f2f3),
                        isDense: false,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: userCourse,
                        items: courses.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            userCourse = value!;
                          });
                        },
                        style: TextStyle(
                          color: Color(0xff000000),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                        ),
                        elevation: 8,
                        isExpanded: true,
                      ),
                    ),


                    SizedBox(height: 20),
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'University Of',
                        filled: true,
                        fillColor: Color(0xfff2f2f3),
                        isDense: false,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: userUniversity,
                        items: universities.map((String value) {
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
                        onChanged: (value) {
                          setState(() {
                            userUniversity = value!;
                          });
                        },
                        elevation: 8,
                        isExpanded: true,
                      ),
                    ),

                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        hintText: 'Choose a username',
                        errorText: usernameError, // Display the error message if not null
                      ),
                      onChanged: (value) {
                        validateUsername(value); // Call validateUsername on each input change
                      },
                    ),


                    // Confirm Details Button
                    Container(
                      width: 200,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF8A2387),
                            Color(0xFFE94057),
                            Color(0xFFF27121),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: MaterialButton(
                        onPressed: () {
                          saveUserData();
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: BorderSide(color: Color(0xff808080), width: 1),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          "Confirm Details",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
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






  Future<void> _selectDate() async {
    DateTime? _picked = await showDatePicker(context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100));

    if (_picked != null) {
      setState(() {
        dobController.text = _picked.toString().split(" ")[0];
      });
    }
  }

  Future<bool> isUsernameUnique(String username) async {
    final event = await _database.ref().child('Usernames').child(username).once();
    final snapshot = event.snapshot;
    return snapshot.value == null;
  }

  Future<void> saveUserData() async {
    String userFirstName = firstNameController.text.trim();
    String userLastName = lastNameController.text.trim();
    String userDOBString = dobController.text.trim();
    String username = usernameController.text.trim();

    if (userFirstName.isEmpty || userLastName.isEmpty ||
        userDOBString.isEmpty || username.isEmpty) {
      _showDialog('Error', 'Please fill in all the required fields.');
      return;
    }

    DateTime userDOB = DateTime.parse(userDOBString);
    DateTime now = DateTime.now();
    int age = now.year - userDOB.year;

    if (age < 18) { // Check that the user is old enough to use the app
      _showDialog('Error', "Users must be 18 or over");
      return;
    }
    if (userFirstName.length > 50 || userLastName.length > 50 ||
        username.length > 15) {
      _showDialog('Error', "Input too long!");
      return;
    }
    //username unique or not
    bool uniqueUsername = await isUsernameUnique(username);
    if (!uniqueUsername) {
      _showDialog(
          'Error', 'Username is already taken. Please choose another one.');
      return;
    }

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        //updates user tbl
        await _database.ref().child('Users').child(user.uid).update({
          'firstName': userFirstName,
          'lastName': userLastName,
          'DOB': userDOB.toIso8601String(),
          'course': userCourse,
          'university': userUniversity,
          'username': username,
        });
        // Update the Usernames table with the new username for quick lookup
        await _database.ref().child('Usernames').child(username).set(
            user.uid);

        print('User data updated successfully!');

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Registration3()),
        );
      } else {
        print('User not authenticated.');
      }
    } catch (e) {
      print('Error updating user data: $e');
      _showDialog('Error', 'Failed to update user data.');
    }
  }

  //validate username
  void validateUsername(String value) {
    setState(() {
      if (value.isEmpty) {
        usernameError = 'Username cannot be empty';
      } else if (value.length < 3 || value.length > 15) {
        usernameError = 'Username must be between 3 and 15 characters';
      } else if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(value)) {
        usernameError = 'Only letters, numbers, hyphens, and underscores are allowed';
      } else {
        usernameError = null;
      }
    });
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
