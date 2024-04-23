import 'package:flutter/material.dart';
import 'CustomAppBar.dart';
import 'OpenDrawer.dart';
import 'OpenForum.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> appForums = [];
  List<Map<String, dynamic>> forYouForums = [];
  List<Map<String, dynamic>> friendsForums = [];
  List<String> userFriends = [];
  String course = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    getForums();
  }

  Future<void> getForums() async {
    User? user = _auth.currentUser;
    if (user != null) {
      final userSnapshot = await databaseReference.child('Users/${user.uid}').get();
      if (userSnapshot.exists) {
        final userData = Map<String, dynamic>.from(userSnapshot.value as Map);
        Map<dynamic, dynamic>? friendsMap = userData['friends'];
        course = userData['course'] ?? '';
        if (friendsMap != null) {
          userFriends = friendsMap.keys.map((key) => key.toString()).toList();
        }
      }
    }

    final DatabaseReference forumsRef = FirebaseDatabase.instance.ref('Forums');
    final forumSnapshot = await forumsRef.get();
    if (forumSnapshot.exists) {
      final Map<dynamic, dynamic> snapshotValue = forumSnapshot.value as Map<dynamic, dynamic>;
      snapshotValue.forEach((key, value) {
        final forum = Map<String, dynamic>.from(value);
        forum['id'] = key;
        setState(() {
          appForums.add(forum);
          if (forum["subject"] == course) {
            forYouForums.add(forum);
          }
          if (userFriends.contains(forum["authorID"])) {
            friendsForums.add(forum);
          }
        });
      });
    }
  }

  void navigateToForum(String forumId) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => OpenForum(forumId: forumId)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: OpenDrawer(),
      appBar: CustomAppBar(),
      body: Padding(
        padding: EdgeInsets.all(2.0),
        child: Column(
          children: [
            const Text(
              "Top Forums for You",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 17,
                color: Colors.black,
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: forYouForums.isEmpty ? 1 : forYouForums.length,
                itemBuilder: (context, index) {
                  if (forYouForums.isEmpty) {
                    return ListTile(
                      title: Text('No forums available'),
                    );
                  } else {
                    final item = forYouForums[index];
                    return ListTile(
                      title: Text(item["title"] ?? 'No Title'),
                      subtitle: Text(item["content"] ?? 'No Content'),
                      leading: Icon(Icons.forum),
                      trailing: Icon(Icons.arrow_forward),
                      onTap: () => navigateToForum(item["id"]),
                    );
                  }
                },
              ),
            ),
            const Text(
              "Recent Posts from Friends",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 17,
                color: Colors.black,
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: friendsForums.isEmpty ? 1 : friendsForums.length,
                itemBuilder: (context, index) {
                  if (friendsForums.isEmpty) {
                    return ListTile(
                      title: Text('No recent posts from friends'),
                    );
                  } else {
                    final item = friendsForums[index];
                    return ListTile(
                      title: Text(item["title"] ?? 'No Title'),
                      subtitle: Text(item["content"] ?? 'No Content'),
                      leading: Icon(Icons.forum),
                      trailing: Icon(Icons.arrow_forward),
                      onTap: () => navigateToForum(item["id"]),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
