import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:login_and_registration/index.dart';
import 'OpenForum.dart';
import 'AddForum.dart';

class Forums extends StatefulWidget {
  @override
  _ForumsState createState() => _ForumsState();
}

class _ForumsState extends State<Forums> {
  List<Map<String, dynamic>> forumList = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  @override
  void initState() {
    super.initState();
    fetchForums();
  }
  void fetchForums() {
    _databaseReference.child('Forums').onValue.listen((event) {
      final forumsData = event.snapshot.value as Map<dynamic, dynamic>?;
      if (forumsData != null) {
        List<Map<String, dynamic>> forums = [];
        forumsData.forEach((key, value) {
          final forum = Map<String, dynamic>.from(value);
          forum['forumId'] = key;
          forums.add(forum);
        });
        setState(() {
          forumList = forums;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      drawer: OpenDrawer(),
      appBar: AppBar(
        backgroundColor: Color(0xffad32fe),
        title: Text("Forums"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddForum())),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: forumList.length,
        itemBuilder: (context, index) {
          final forum = forumList[index];
          return ListTile(
            title: Text(forum["title"] ?? 'No Title'),
            subtitle: Text(forum["content"] ?? 'No Content'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OpenForum(forumId: forum['forumId'])),
            ),
          );
        },
      ),
    );
  }
}
