import 'package:flutter/material.dart';
import 'HomeScreen.dart';
import 'UserProfile.dart';

class Forums extends StatefulWidget {
  @override
  _ForumsState createState() => _ForumsState();
}

class _ForumsState extends State<Forums> {
  List<Map<String, dynamic>> forumList = [
    {
      "title": "Software Engineering",
      "subtitle": "Computer Science",
    },
    {
      "title": "BIDMAS",
      "subtitle": "Maths",
    },
    {
      "title": "Bones",
      "subtitle": "Science",
    },
    {
      "title": "Functional Programming",
      "subtitle": "Computer Science",
    },

  ];

  List<Map<String, dynamic>> filteredList = [];

  @override
  void initState() {
    super.initState();
    filteredList.addAll(forumList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      appBar: AppBar(
        backgroundColor: Color(0xffad32fe),
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
          child: Row(
            children: [
              Image.asset(
                'assets/logo.png',
                width: 28,
              ),
              SizedBox(width: 28),
              Text(
                "Study Hive",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: 16,
                  color: Color(0xffffffff),
                ),
              ),
            ],
          ),
        ),

      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.article),
            label: "Forums",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: "Messages",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
            label: "Profile",
          ),
        ],
        onTap: (int index) {
          // Handle bottom navigation item taps
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Forums()),
            );
          } else if (index == 1) {

          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserProfile()),
            );
          }
        },
        backgroundColor: Color(0xffae32ff),
        elevation: 8,
        iconSize: 22,
        selectedItemColor: Color(0xffffffff),
        unselectedItemColor: Color(0xffffffff),
        selectedFontSize: 12,
        unselectedFontSize: 12,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      body: Padding(
        padding: EdgeInsets.all(2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: TextField(
                onChanged: (value) {
                  filterForums(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search forums...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(filteredList[index]["title"]),
                    subtitle: Text(filteredList[index]["subtitle"]),
                    leading: Icon(
                        Icons.article,
                        color: Color(0xff212435),
                        size: 24),
                    trailing: Icon(
                        Icons.arrow_forward,
                        color: Color(0xff212435),
                        size: 24),
                    // Add other properties as needed
                    onTap: () {
                      // Handle forum item tap
                      // Navigate to the forum page or perform any other action
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void filterForums(String query) {
    setState(() {
      filteredList = forumList
          .where((forum) =>
          forum["title"].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }
}
