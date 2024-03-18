import 'package:flutter/material.dart';
import 'CustomAppBar.dart';

class Friends extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Color(0xfff6f6f6),
        appBar: CustomAppBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TabBar(
              tabs: [
                Tab(text: 'Friends'),
                Tab(text: 'Requests'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _FriendsList(),
                  _RequestsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FriendsList extends StatefulWidget {
  @override
  _FriendsListState createState() => _FriendsListState();
}

class _FriendsListState extends State<_FriendsList> {
  List<String> friends = List.generate(10, (index) => "Friend ${index + 1}");
  List<String> filteredFriends = [];

  @override
  void initState() {
    super.initState();
    filteredFriends.addAll(friends);
  }

  void filterFriends(String query) {
    setState(() {
      filteredFriends = friends
          .where((friend) => friend.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void showProfile(BuildContext context, String friendName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(friendName),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage("assets/profilePicture1.png"),
                ),
                SizedBox(height: 10),
                Text("Bio: I like football"),
                // Add more profile information here
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: filterFriends,
            decoration: InputDecoration(
              hintText: 'Search Friends...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredFriends.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(filteredFriends[index]),
                onTap: () {
                  showProfile(context, filteredFriends[index]);
                },
                trailing: OutlinedButton(
                  onPressed: () {
                    // Implement remove button functionality
                  },
                  style: ButtonStyle(
                    side: MaterialStateProperty.all(BorderSide(color: Colors.black)),
                  ),
                  child: Text('Remove'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RequestsList extends StatefulWidget {
  @override
  _RequestsListState createState() => _RequestsListState();
}

class _RequestsListState extends State<_RequestsList> {
  List<String> requests = List.generate(5, (index) => "Request ${index + 1}");
  List<String> filteredRequests = [];

  @override
  void initState() {
    super.initState();
    filteredRequests.addAll(requests);
  }

  void filterRequests(String query) {
    setState(() {
      filteredRequests = requests
          .where((request) => request.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void showProfile(BuildContext context, String requestName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(requestName),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage("assets/profilePicture1.png"),
                ),
                SizedBox(height: 10),
                Text("Bio: I like football"),
                // Add more profile information here
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            onChanged: filterRequests,
            decoration: InputDecoration(
              hintText: 'Search Requests...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredRequests.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(filteredRequests[index]),
                onTap: () {
                  showProfile(context, filteredRequests[index]);
                },
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        // Implement accept button functionality
                      },
                      style: ButtonStyle(
                        side: MaterialStateProperty.all(BorderSide(color: Colors.black)),
                      ),
                      child: Text('Accept'),
                    ),
                    SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () {
                        // Implement reject button functionality
                      },
                      style: ButtonStyle(
                        side: MaterialStateProperty.all(BorderSide(color: Colors.black)),
                      ),
                      child: Text('Reject'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
