import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_and_registration/CustomAppBar.dart';

class OtherUserProfile extends StatefulWidget {
  final String userID;
  final bool isFriend;

  OtherUserProfile({required this.userID, this.isFriend = false});

  @override
  _OtherUserProfileState createState() => _OtherUserProfileState();
}

class _OtherUserProfileState extends State<OtherUserProfile> {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  String firstName = '';
  String lastName = '';
  String username = '';
  String bio = '';
  String university = '';
  String course = '';
  int profilePic = 0;
  int friendCount = 0;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final userSnapshot = await databaseReference.child('Users/${widget.userID}').get();
    if (userSnapshot.exists) {
      final userData = Map<String, dynamic>.from(userSnapshot.value as Map);
      setState(() {
        firstName = userData['firstName'] ?? '';
        lastName = userData['lastName'] ?? '';
        username = userData['username'] ?? '';
        bio = userData['bio'] ?? '';
        university = userData['university'] ?? '';
        course = userData['course'] ?? '';
        profilePic = userData['profilePic'] ?? 0;
        friendCount = userData['friends'] != null ? Map<String, dynamic>.from(userData['friends']).length : 0;
      });
    }
  }

  void modifyFriendship() async {
    if (widget.isFriend) {
      await databaseReference.child('Users/$currentUserId/friends/${widget.userID}').remove();
      await databaseReference.child('Users/${widget.userID}/friends/$currentUserId').remove();
      Navigator.pop(context);
    } else {
      await databaseReference.child('Users/$currentUserId/friendRequestsSent/${widget.userID}').set('pending');
      await databaseReference.child('Users/${widget.userID}/friendRequestsReceived/$currentUserId').set('pending');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Friend request sent!")));
    }
  }

  String getProfilePicturePath(int profilePicIndex) {
    switch (profilePicIndex) {
      case 1: return "assets/purple.png";
      case 2: return "assets/blue.png";
      case 3: return "assets/blue-purple.png";
      case 4: return "assets/orange.png";
      case 5: return "assets/pink.png";
      case 6: return "assets/turquoise.png";
      default: return "assets/default_profile_picture.png";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage(getProfilePicturePath(profilePic)),
            ),
            SizedBox(height: 10),
            Text("$firstName $lastName", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Text(username, style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10)
              ),
              child: Text(bio),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ProfileInfoBox(title: course, subtitle: "Course"),
                ProfileInfoBox(title: "$friendCount friends", subtitle: "Friends"),
                ProfileInfoBox(title: university, subtitle: "University"),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: modifyFriendship,
              child: Text(widget.isFriend ? "Remove Friend" : "Add Friend"),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(widget.isFriend ? Colors.red : Colors.blue),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileInfoBox extends StatelessWidget {
  final String title;
  final String subtitle;

  ProfileInfoBox({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 5),
          Text(subtitle, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
