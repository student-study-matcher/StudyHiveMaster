import 'package:flutter/material.dart';
import 'FriendProfile.dart';

class FriendsPopup extends StatelessWidget {
  final List<Map<String, String>> friendsDetails;

  FriendsPopup({required this.friendsDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Friends', style: TextStyle(color: Colors.white), ),
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
      ),
      body: friendsDetails.isEmpty
          ? Center(child: Text('No friends yet.'))
          : ListView.builder(
        itemCount: friendsDetails.length,
        itemBuilder: (context, index) {
          final friend = friendsDetails[index];
          return ListTile(
            title: Text(friend['username'] ?? 'Unknown'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FriendProfile(friendId: friend['id']!),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
