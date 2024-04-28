import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'HomeScreen.dart';

class Registration3 extends StatefulWidget {
  @override
  _Registration3State createState() => _Registration3State();
}

class _Registration3State extends State<Registration3> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final databaseReference = FirebaseDatabase.instance.ref();
  TextEditingController bioController = TextEditingController();
  int profilePic = 0;
  int selectedProfilePic = -1;

  Future<void> saveBio() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await databaseReference.child('Users/${user.uid}/bio').set(bioController.text);
      await databaseReference.child('Users/${user.uid}/profilePic').set(profilePic);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }
  void selectProfilePic(int index) {
    setState(() {
      selectedProfilePic = index;
    });
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
    ' Complete Registration',
    style: TextStyle(
    fontSize: 35,
    fontWeight: FontWeight.bold,
    ),
    ),
    SizedBox(height: 10),
    Text(
    'Please select profile picture',
    style: TextStyle(
    fontSize: 15,
    color: Colors.grey,
    ),
    ),


      SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildProfilePic(1, 'assets/purple.png'),
                buildProfilePic(2, 'assets/blue.png'),
                buildProfilePic(3, 'assets/blue-purple.png'),
                buildProfilePic(4, 'assets/orange.png'),
                buildProfilePic(5, 'assets/pink.png'),
                buildProfilePic(6, 'assets/turquoise.png'),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: bioController,
              decoration: InputDecoration(
                labelText: 'Bio',
                counterText: '${bioController.text.length}/255',
              ),
              maxLines: 3,
              maxLength: 255,
              onChanged: (text) {
                setState(() {});
              },
            ),
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
    saveBio();
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
    )
    ],
    ),
    ),
    ),
    );
  }

  Widget buildProfilePic(int index, String imagePath) {
    return GestureDetector(
      onTap: () {
        selectProfilePic(index);
        profilePic = index;
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          border: selectedProfilePic == index
              ? Border.all(color: Colors.blue, width: 2)
              : null,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Image.asset(
          imagePath,
          width: 60,
          height: 60,
        ),
      ),
    );
  }
}
