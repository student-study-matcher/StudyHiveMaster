import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'OtherUserProfile.dart';
import 'OpenForum.dart';
import 'FriendProfile.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  void _performSearch(String query) async {
    DatabaseReference usersRef = FirebaseDatabase.instance.ref('Users');
    DatabaseReference forumsRef = FirebaseDatabase.instance.ref('Forums');
    DatabaseEvent userEvent = await usersRef.once();
    DatabaseEvent forumEvent = await forumsRef.once();

    List<Map<String, dynamic>> results = [];

    if (userEvent.snapshot.exists) {
      userEvent.snapshot.children.forEach((child) {
        if (child.key == currentUserId) return;
        Map<String, dynamic> userData = Map<String, dynamic>.from(child.value as Map);
        String username = userData['username'] ?? '';
        if (username.toLowerCase().contains(query.toLowerCase())) {
          results.add({
            'type': 'user',
            'username': username,
            'key': child.key,
          });
        }
      });
    }

    if (forumEvent.snapshot.exists) {
      forumEvent.snapshot.children.forEach((child) {
        Map<String, dynamic> forumData = Map<String, dynamic>.from(child.value as Map);
        String title = forumData['title'] ?? '';
        if (title.toLowerCase().contains(query.toLowerCase())) {
          results.add({
            'type': 'forum',
            'title': title,
            'forumId': child.key,
          });
        }
      });
    }

    setState(() {
      _searchResults = results.isEmpty ? [{'type': 'none', 'title': 'No results'}] : results;
    });
  }

  void navigateToProfile(String userId) async {
    final DatabaseReference ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('Users/$currentUserId/friends/$userId').get();

    if (snapshot.exists) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => FriendProfile(friendId: userId)));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => OtherUserProfile(userID: userId)));
    }
  }


  void navigateToForum(String forumId) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => OpenForum(forumId: forumId)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF8A2387),
                Color(0xFFE94057),
                Color(0xFFF27121),
              ],
            ),
          ),
        ),
        title: TextField(
          controller: _searchController,
          onChanged: (value) {
            if (value.isNotEmpty) {
              _performSearch(value);
            } else {
              setState(() => _searchResults.clear());
            }
          },
          decoration: InputDecoration(
            hintText: "Search...",
            hintStyle: TextStyle(color: Colors.white),
            border: InputBorder.none,
          ),
          style: TextStyle(color: Colors.white),
        ),
        leading: BackButton(color: Colors.white),
      ),
      body: ListView.separated(
        itemCount: _searchResults.length,
        separatorBuilder: (context, index) => Divider(height: 1),
        itemBuilder: (context, index) {
          var result = _searchResults[index];
          return ListTile(
            leading: Icon(result['type'] == 'user' ? Icons.person : Icons.forum),
            title: Text(result['type'] == 'user' ? result['username'] : result['title']),
            onTap: () {
              if (result['type'] == 'user') {
                navigateToProfile(result['key']);
              } else if (result['type'] == 'forum') {
                navigateToForum(result['forumId']);
              }
            },
          );
        },
      ),
    );
  }
}
