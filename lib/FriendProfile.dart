import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'CustomAppBar.dart';
import 'OpenDrawer.dart';


class FriendProfile extends StatefulWidget {
  final String friendId;

  FriendProfile({required this.friendId});

  @override
  _FriendProfileState createState() => _FriendProfileState();
}

class _FriendProfileState extends State<FriendProfile> {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  String firstName = '';
  String lastName = '';
  String username = '';
  String bio = '';
  String university = '';
  String course = '';
  int friendCount = 0;
  int profilePic = 0;

  @override
  void initState() {
    super.initState();
    fetchFriendData();
  }

  Future<void> fetchFriendData() async {
    final friendSnapshot = await databaseReference.child('Users/${widget.friendId}').get();
    if (friendSnapshot.exists) {
      final friendData = Map<String, dynamic>.from(friendSnapshot.value as Map);
      setState(() {
        firstName = friendData['firstName'] ?? '';
        lastName = friendData['lastName'] ?? '';
        username = friendData['username'] ?? '';
        bio = friendData['bio'] ?? '';
        university = friendData['university'] ?? '';
        course = friendData['course'] ?? '';
        profilePic = friendData['profilePic'] ?? 0;
        friendCount = friendData['friends'] != null ? Map<String, dynamic>.from(friendData['friends']).length : 0;
      });
    }
  }

  void removeFriend() async {
    await databaseReference.child('Users/$currentUserId/friends/${widget.friendId}').remove();
    await databaseReference.child('Users/${widget.friendId}/friends/$currentUserId').remove();
    Navigator.pop(context);
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
      backgroundColor: Colors.white,
      drawer: OpenDrawer(),
      appBar: CustomAppBar(),
      body: Padding(
        padding: EdgeInsets.only(top: 50.0),
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(2.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(20),
                    width: MediaQuery.of(context).size.width * 0.7,
                    decoration: BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "$firstName $lastName's Profile",
                          style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20),
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: AssetImage(getProfilePicturePath(profilePic)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("$firstName $lastName", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                            Text(username, style: TextStyle(fontSize: 18)),
                          ],
                        ),
                        SizedBox(height: 20),
                        Container(
                          padding: EdgeInsets.all(20),
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
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
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: removeFriend,
                    child: Text("Remove Friend"),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.red),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
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
