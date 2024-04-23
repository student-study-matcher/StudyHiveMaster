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
      appBar: AppBar(
        title: Text("Complete Registration"),
      ),
      body: SingleChildScrollView(
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
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveBio,
              child: Text('Finish Registration'),
            ),
          ],
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
