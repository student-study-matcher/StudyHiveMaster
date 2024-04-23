import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'GroupChatPage.dart';
import 'OpenDrawer.dart';
import 'AddGroupChat.dart';

class JoinGroupChat extends StatefulWidget {
  @override
  _JoinGroupChatState createState() => _JoinGroupChatState();
}

class _JoinGroupChatState extends State<JoinGroupChat> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> myChats = [];
  List<Map<String, dynamic>> allChats = [];
  List<Map<String, dynamic>> filteredAllChats = [];
  List<Map<String, dynamic>> privateChats = [];
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchGroupChats();
    _searchController.addListener(_filterChats);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void fetchGroupChats() async {
    final currentUser = _auth.currentUser?.uid ?? "";
    DatabaseReference chatsRef = _databaseReference.child('GroupChats');

    Map<String, String> userNames = {};
    await _databaseReference.child('Users').once().then((userSnapshot) {
      userSnapshot.snapshot.children.forEach((user) {
        userNames[user.key ?? ""] = (user.value as Map)['username'] ?? 'Unknown';
      });
    });

    chatsRef.onValue.listen((event) {
      var loadedMyChats = <Map<String, dynamic>>[];
      var loadedAllChats = <Map<String, dynamic>>[];
      var loadedPrivateChats = <Map<String, dynamic>>[];

      event.snapshot.children.forEach((DataSnapshot snapshot) {
        Map<String, dynamic> chat = Map<String, dynamic>.from(snapshot.value as Map);
        bool isPrivate = chat['isPrivate'] ?? false;
        bool isAdmin = chat['adminID'] == currentUser;
        bool userIsMember = chat['memberIDs'] != null && chat['memberIDs'].containsKey(currentUser);

        Map<String, dynamic> chatDetails = {
          ...chat,
          'id': snapshot.key ?? "",
          'adminName': userNames[chat['adminID']] ?? 'Unknown'
        };

        if (userIsMember) {
          loadedMyChats.add(chatDetails);
        }

        if (!isPrivate) {
          loadedAllChats.add(chatDetails);
        }

        if (isPrivate && (userIsMember || isAdmin)) {
          loadedPrivateChats.add(chatDetails);
        }
      });

      setState(() {
        myChats = loadedMyChats;
        allChats = loadedAllChats;
        privateChats = loadedPrivateChats;
        filteredAllChats = List<Map<String, dynamic>>.from(allChats);
      });
    });
  }




  void _filterChats() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        filteredAllChats = List<Map<String, dynamic>>.from(allChats);
      });
    } else {
      setState(() {
        filteredAllChats = allChats.where((chat) {
          return chat['title'] != null && chat['title'].toLowerCase().contains(query);
        }).toList();
      });
    }
  }

  Widget buildChatList(List<Map<String, dynamic>> chats, bool isMyChatList) {
    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        bool joined = chat['memberIDs'] != null && chat['memberIDs'][_auth.currentUser?.uid] == true;
        bool isPrivate = chat['isPrivate'] ?? false;


        if (isPrivate && !joined && chat['adminID'] != _auth.currentUser?.uid) {
          return Container();
        }


        void openChat() {
          Navigator.push(context, MaterialPageRoute(builder: (_) => GroupChatPage(chatId: chat['id'] ?? "", isAdmin: chat['adminID'] == _auth.currentUser?.uid)));
        }


        String buttonText = "Open Chat";
        VoidCallback? onTapFunction = openChat;

        if (!isPrivate && !joined) {
          buttonText = "Join";
          onTapFunction = () => joinChat(chat['id'] ?? "", isPrivate);
        }

        return ListTile(
          title: Text(chat['title'] ?? "Untitled Chat"),
          subtitle: Text('Owner: ${chat['adminName']}'),
          trailing: ElevatedButton(
            onPressed: onTapFunction,
            child: Text(buttonText),
          ),
        );
      },
    );
  }



  void joinChat(String chatId, bool isPrivate) async {
    if (!isPrivate) {
      await _databaseReference.child('GroupChats/$chatId/memberIDs/${_auth.currentUser!.uid}').set(true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Joined the chat!")));
      fetchGroupChats();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Request sent to join private chat.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: OpenDrawer(),
      appBar: AppBar(
        title: Text("Join Group Chat"),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: "My Chats"),
            Tab(text: "All Chats"),
            Tab(text: "Private Chats"),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddGroupChat())),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search for group chats...',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                buildChatList(myChats, true),
                buildChatList(filteredAllChats, false),
                buildChatList(privateChats, false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
