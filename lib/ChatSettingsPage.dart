import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'OtherUserProfile.dart';
import 'FriendProfile.dart';
import 'UserProfile.dart';

class ChatSettingsPage extends StatefulWidget {
  final String chatId;

  ChatSettingsPage({required this.chatId});

  @override
  _ChatSettingsPageState createState() => _ChatSettingsPageState();
}

class _ChatSettingsPageState extends State<ChatSettingsPage> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> participants = [];
  bool isAdmin = false;
  String groupName = "";
  bool isPrivate = false;

  @override
  void initState() {
    super.initState();
    fetchDetails();
  }

  fetchDetails() async {
    DataSnapshot snapshot = await _databaseRef.child('GroupChats/${widget.chatId}').get();
    if (snapshot.exists) {
      Map<String, dynamic> chatData = Map<String, dynamic>.from(snapshot.value as Map);
      isAdmin = chatData['adminID'] == FirebaseAuth.instance.currentUser!.uid;
      groupName = chatData['title'] ?? "Group Chat";
      isPrivate = chatData['isPrivate'] ?? false;
      if (chatData.containsKey('memberIDs')) {
        List<String> memberIDs = List<String>.from(chatData['memberIDs'].keys);
        fetchParticipants(memberIDs, chatData['adminID']);
      }
    }
  }

  fetchParticipants(List<String> memberIDs, String adminID) async {
    List<Map<String, dynamic>> loadedParticipants = [];
    for (String userId in memberIDs) {
      DataSnapshot userSnapshot = await _databaseRef.child('Users/$userId').get();
      if (userSnapshot.exists) {
        Map<String, dynamic> userData = Map<String, dynamic>.from(userSnapshot.value as Map);
        loadedParticipants.add({
          'uid': userId,
          'username': userData['username'] ?? 'Unknown',
          'isAdmin': userId == adminID
        });
      }
    }
    setState(() {
      participants = loadedParticipants;
    });
  }

  void navigateToProfile(String userId) async {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    if (userId == currentUserId) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfile()));
    } else {
      final snapshot = await _databaseRef.child('Users/$currentUserId/friends/$userId').get();
      if (snapshot.exists) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => FriendProfile(friendId: userId)));
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (_) => OtherUserProfile(userID: userId)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffffffff),
    appBar: AppBar(
    title: Text(("Chat Settings"), style: TextStyle(color: Colors.white),),
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

        actions: [
          if (isAdmin)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                await _databaseRef.child('GroupChats/${widget.chatId}').remove();
                Navigator.pop(context);
              },
            )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: TextField(
                controller: TextEditingController(text: groupName),
                decoration: InputDecoration(labelText: "Group Name"),
                onSubmitted: (newName) {
                  if (isAdmin && newName.isNotEmpty) {
                    _databaseRef.child('GroupChats/${widget.chatId}/title').set(newName);
                    setState(() { groupName = newName; });
                  }
                },
              ),
            ),
            SwitchListTile(
              title: Text("Private Chat"),
              value: isPrivate,
              onChanged: isAdmin ? (val) {
                _databaseRef.child('GroupChats/${widget.chatId}/isPrivate').set(val);
                setState(() { isPrivate = val; });
              } : null,
              subtitle: Text(isPrivate ? "Chat is private" : "Chat is public"),
            ),
            Text("Participants (${participants.length}):", style: TextStyle(fontWeight: FontWeight.bold)),
            ...participants.map((participant) => ListTile(
              title: Text(participant['username']),
              subtitle: Text(participant['isAdmin'] ? 'Admin' : 'Member'),
              onTap: () => navigateToProfile(participant['uid']),
              trailing: isAdmin && !participant['isAdmin'] ? IconButton(
                icon: Icon(Icons.remove_circle_outline),
                onPressed: () async {
                  await _databaseRef.child('GroupChats/${widget.chatId}/memberIDs').child(participant['uid']).remove();
                  fetchDetails();
                },
              ) : null,
            )),
            ElevatedButton(
              onPressed: () async {
                if (isAdmin && participants.length == 1) {

                  await _databaseRef.child('GroupChats/${widget.chatId}').remove();
                  Navigator.pop(context);
                } else {

                  if (isAdmin) {
                    String nextAdminId = participants.firstWhere((p) => p['uid'] != FirebaseAuth.instance.currentUser!.uid)['uid'];
                    await _databaseRef.child('GroupChats/${widget.chatId}/adminID').set(nextAdminId);
                  }
                  await _databaseRef.child('GroupChats/${widget.chatId}/memberIDs/${FirebaseAuth.instance.currentUser!.uid}').remove();
                  Navigator.pop(context);
                }
              },
              child: Text("Leave Chat"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            )
          ],
        ),
      ),
    );
  }
}
