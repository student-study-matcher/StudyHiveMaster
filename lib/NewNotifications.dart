import 'package:flutter/material.dart';
import 'index.dart';

class NewNotifications extends StatefulWidget {
  @override
  _NewNotificationsState createState() => _NewNotificationsState();
}

class _NewNotificationsState extends State<NewNotifications> {
  int _currentIndex = 0; // Index to keep track of selected tab

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: OpenDrawer(),
      appBar: CustomAppBar(),

      body: IndexedStack(
        index: _currentIndex,
        children: [
          NotificationList(type: 'Friends', notifications: [
            "John sent you a friend request",
            "Lisa liked your post",
            "David commented on your photo",
          ]),
          NotificationList(type: 'Forums', notifications: [
            "New post in Flutter Forum: 'Getting Started with Flutter'",
            "Your answer was accepted in StackOverflow",
          ]),
          NotificationList(type: 'Groupchats', notifications: [
            "New message in Group 1: 'Let's plan a meetup!'",
            "You were mentioned in Group 2",
          ]),
        ],
      ),

      // Bottom navigation bar for switching between sections
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: 'Forums',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Groupchats',
          ),
        ],
      ),
    );
  }
}

class NotificationList extends StatelessWidget {
  final String type;
  final List<String> notifications;

  NotificationList({required this.type, required this.notifications});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(notifications[index]),
          // Add onTap logic to handle tapping on notifications
          onTap: () {
            // Add your logic to handle tapping on notifications
          },
        );
      },
    );
  }
}
