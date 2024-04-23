import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class AddGroupChat extends StatefulWidget {
  @override
  _AddGroupChatState createState() => _AddGroupChatState();
}

class _AddGroupChatState extends State<AddGroupChat> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  bool isPrivate = false;
  List<Map<String, dynamic>> memberUsers = [];
  List<Map<String, dynamic>> searchResults = [];
  late String groupId;

  @override
  void initState() {
    super.initState();
    groupId = FirebaseDatabase.instance.ref().child('GroupChats').push().key!;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      setState(() {
        searchResults.clear();
      });
    } else {
      _performSearch(_searchController.text);
    }
  }

  Future<void> _performSearch(String query) async {
    var snapshot = await FirebaseDatabase.instance.ref('Users').orderByChild('username').startAt(query).endAt(query + '\uf8ff').get();
    if (snapshot.exists) {
      var users = snapshot.value as Map;
      setState(() {
        searchResults = users.entries.map((e) => {
          'id': e.key,
          'username': e.value['username'],
          'added': memberUsers.any((user) => user['id'] == e.key)
        }).toList();
      });
    }
  }

  void addUser(Map<String, dynamic> user) {
    setState(() {
      if (!memberUsers.any((element) => element['id'] == user['id'])) {
        memberUsers.add(user);
        searchResults = searchResults.map((u) {
          return u['id'] == user['id'] ? {...u, 'added': true} : u;
        }).toList();
      }
    });
  }

  void removeUser(String userId) {
    setState(() {
      memberUsers.removeWhere((user) => user['id'] == userId);
      searchResults = searchResults.map((u) {
        return u['id'] == userId ? {...u, 'added': false} : u;
      }).toList();
    });
  }

  void createGroupChat() async {
    Map<String, bool> members = {FirebaseAuth.instance.currentUser!.uid: true};
    for (var user in memberUsers) {
      members[user['id']] = true;
    }

    await FirebaseDatabase.instance.ref().child('GroupChats/$groupId').set({
      'title': _titleController.text.trim(),
      'isPrivate': isPrivate,
      'adminID': FirebaseAuth.instance.currentUser!.uid,
      'memberIDs': members,
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Group Chat'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Group Chat Title',
                border: OutlineInputBorder(),
              ),
            ),
            SwitchListTile(
              title: Text('Private Group'),
              value: isPrivate,
              onChanged: (bool value) {
                setState(() {
                  isPrivate = value;
                });
              },
            ),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Users',
                suffixIcon: Icon(Icons.search),
              ),
            ),
            Wrap(
              spacing: 8.0,
              children: searchResults.map((user) => ChoiceChip(
                label: Text(user['username']),
                selected: user['added'],
                onSelected: (_) => user['added'] ? removeUser(user['id']) : addUser(user),
              )).toList(),
            ),
            Wrap(
              spacing: 8.0,
              children: memberUsers.map((user) => Chip(
                label: Text(user['username']),
                onDeleted: () => removeUser(user['id']),
              )).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: createGroupChat,
              child: Text('Create Group Chat'),
            ),
          ],
        ),
      ),
    );
  }
}
