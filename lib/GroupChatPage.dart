import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ChatSettingsPage.dart';

class GroupChatPage extends StatefulWidget {
  final String chatId;
  final bool isAdmin;

  GroupChatPage({required this.chatId, required this.isAdmin});

  @override
  _GroupChatPageState createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  Map<String, Map<String, dynamic>> userProfiles = {};
  String chatTitle = "";
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  Uint8List? _fileBytes;
  String? _fileName;

  @override
  void initState() {
    super.initState();
    fetchChatDetails();
    listenToMessages();
  }

  void fetchChatDetails() async {
    DataSnapshot chatSnapshot = await _databaseRef.child('GroupChats/${widget.chatId}').get();
    if (chatSnapshot.exists && chatSnapshot.value != null) {
      Map<dynamic, dynamic> chatData = chatSnapshot.value as Map<dynamic, dynamic>? ?? {};
      setState(() {
        chatTitle = chatData['title'] ?? 'Group Chat';
      });
    }

    DataSnapshot usersSnapshot = await _databaseRef.child('Users').get();
    if (usersSnapshot.exists && usersSnapshot.value != null) {
      Map<dynamic, dynamic> users = usersSnapshot.value as Map<dynamic, dynamic>? ?? {};
      Map<String, Map<String, dynamic>> profiles = {};
      users.forEach((uid, userData) {
        profiles[uid] = {
          'username': userData['username'] ?? 'Unknown',
          'profilePic': getProfilePicturePath(userData['profilePic'])
        };
      });
      setState(() {
        userProfiles = profiles;
      });
    }
  }

  String getProfilePicturePath(dynamic profilePicIndex) {
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

  void listenToMessages() {
    _databaseRef.child('GroupChats/${widget.chatId}/messages').onValue.listen(
            (DatabaseEvent event) {
          var fetchedMessages = <Map<String, dynamic>>[];
          event.snapshot.children.forEach((DataSnapshot snapshot) {
            if (snapshot.value != null) {
              Map<String, dynamic> message = Map<String, dynamic>.from(snapshot.value as Map);
              message['key'] = snapshot.key;
              fetchedMessages.add(message);
            }
          });
          setState(() {
            messages = fetchedMessages;
          });
        },
        onError: (error) {
          print("Error listening to messages: $error");
        }
    );
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpeg', 'doc', 'docx'],
        withData: true
    );

    if (result != null && result.files.single.size <= 10485760) {
      setState(() {
        _fileBytes = result.files.single.bytes;
        _fileName = result.files.single.name;
        _messageController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File too large or invalid type (max size: 10MB)')));
    }
  }

  Future<String?> uploadFile() async {
    if (_fileBytes != null) {
      try {
        String userId = FirebaseAuth.instance.currentUser!.uid;
        String filePath = 'files/${widget.chatId}/$_fileName';
        final ref = FirebaseStorage.instance.ref().child(filePath);
        final result = await ref.putData(_fileBytes!);
        return await result.ref.getDownloadURL();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload file: $e')));
        return null;
      }
    }
    return null;
  }

  Future<void> sendMessage() async {
    String? fileUrl;
    if (_fileBytes != null) {
      fileUrl = await uploadFile();
      if (fileUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload file. Message not sent.'))
        );
        return;
      }
    }

    if (_messageController.text.isNotEmpty || fileUrl != null) {
      Map<String, dynamic> messageData = {
        'text': fileUrl != null ? "File sent: $_fileName" : _messageController.text,
        'senderId': FirebaseAuth.instance.currentUser?.uid,
        'timestamp': ServerValue.timestamp,
        'fileUrl': fileUrl,
        'fileName': _fileName
      };

      await _databaseRef.child('GroupChats/${widget.chatId}/messages').push().set(messageData);
      _messageController.clear();
      setState(() {
        _fileBytes = null;
        _fileName = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No message text or file to send.'))
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffffffff),
    appBar: AppBar(
    title: Text((chatTitle), style: TextStyle(color: Colors.white),),
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
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ChatSettingsPage(chatId: widget.chatId)));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                var user = userProfiles[msg['senderId']] ?? {'username': 'Unknown User', 'profilePic': 'default_profile_picture.png'};
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(user['profilePic']),
                  ),
                  title: Text(msg['text']),
                  subtitle: Text('${user['username']} at ${DateFormat('dd MMM yyyy hh:mm a').format(DateTime.fromMillisecondsSinceEpoch(int.parse(msg['timestamp'].toString())))}'),
                  onTap: msg['fileUrl'] != null ? () => launch(msg['fileUrl']) : null,
                );
              },
            ),
          ),
    Padding(
    padding: EdgeInsets.all(8.0),
    child: Row(
    children: [
    Padding(
    padding: EdgeInsets.only(left: 10),
    child: IconButton(
    icon: Icon(Icons.attach_file),
    onPressed: pickFile,
    ),
    ),
    Expanded(
    child: Padding(
    padding: EdgeInsets.only(left: 10),
    child: Container(
    decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(30),
    boxShadow: [
    BoxShadow(
    color: Colors.grey.withOpacity(0.5),
    spreadRadius: 2,
    blurRadius: 10,
    offset: Offset(0, 3),
    ),
    ],
    ),
    child: Row(
    children: [
    Expanded(
    child: Padding(
    padding: EdgeInsets.symmetric(horizontal: 20),
    child: TextFormField(
    controller: _messageController,
    decoration: InputDecoration(
    hintText: "Type a message",
    border: InputBorder.none,
    ),
    ),
    ),
    ),
    IconButton(
    icon: Icon(Icons.send),
    onPressed: sendMessage,
    ),
    ],
    ),
    ),
    ),
    ),



    ],
    ),
    ),

          if (_fileName != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Chip(
                label: Text(_fileName!),
                onDeleted: () {
                  setState(() {
                    _fileBytes = null;
                    _fileName = null;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
}
