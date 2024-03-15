import 'package:flutter/material.dart';
import 'ChatBottomSheet.dart';
import 'ChatSample.dart';
import 'EditChat.dart'; 

class ChatPage extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
        child: Padding(
          padding: EdgeInsets.only(top:5),
          child: AppBar(
            leadingWidth: 30,
            title: Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.asset(
                  "images/avatar.jpg",
                  height: 45,
                  width:45,
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left:10),
                child: Text(
                  "Maths",
                  style: TextStyle(color: Color(0xFF113953)),
                ),
              ),
            ],),
            actions: [
              Padding(
                padding: EdgeInsets.only(right:25),
                child: Icon(Icons.call,
                  color: Color(0xFF113953),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right:10),
                child: IconButton( // Changed from Icon to IconButton
                  icon: Icon(
                    Icons.more_vert,
                    color: Color(0xFF113953),
                  ),
                  onPressed: () {
                    
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditChat()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
          padding: EdgeInsets.only(top: 20, left: 20, right:20, bottom: 80),
          children: [
            ChatSample()
          ]
      ),
      bottomSheet: ChatBottomSheet(),
    );
  }
}
