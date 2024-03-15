import 'dart:async';
import 'package:flutter/material.dart';
import 'index.dart';

class LogHomeScreen extends StatefulWidget {
  @override
  _LogHomeScreenState createState() => _LogHomeScreenState();
}

class _LogHomeScreenState extends State<LogHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      showLoginPopup(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Add this line to provide the key
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: const Text('Login'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
            ),
            ListTile(
              title: const Text('Register'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Registration1()),
                );
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        elevation: 4,
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xffad32fe),
        title: GestureDetector(
          onTap: () => Navigator.of(context).pushReplacementNamed('/home'),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.menu, color: Colors.white),
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer(); // Use the key to open the drawer
                },
              ),
              Image.asset('assets/logo.png', width: 24),
              SizedBox(width: 8),
              Text("Study Hive",
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Colors.white)),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.login, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Login()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(2),
        child: Column(
          children: [
            sectionTitle("Top Forums For You"),
            sectionListTile("Software Engineering", "Computer Science"),
            sectionListTile("BIDMAS", "Maths"),
            sectionListTile("Bones", "Science"),
            sectionTitle("Your Friends Most Recent Posts"),
            sectionListTile("Big Data", "Computer Science"),
            sectionListTile("UI Design", "Computer Science"),
            sectionListTile("Databases", "Computer Science"),
          ],
        ),
      ),
    );
  }

  void showLoginPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              // Add your logo or image widget here
              Image.asset(
                'assets/logo.png',
                width: 70, // Adjust the width as needed
                height: 70, // Adjust the height as needed
              ),
              SizedBox(width: 10),
              Text("Study Hive"),
            ],
          ),
          content: Text("Please log in or register to use all the features."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
              child: Text("Login"),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Registration1()),
                );
              },
              child: Text("Register"),
            ),
          ],
        );
      },
    );
  }

  Widget sectionTitle(String title) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontWeight: FontWeight.w500,
        fontSize: 17,
        color: Colors.black,
      ),
    );
  }

  Widget sectionListTile(String title, String subtitle) {
    return ListTile(
      tileColor: Color(0x1f000000),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: Colors.black,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: Colors.black,
        ),
      ),
      dense: false,
      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
      selected: false,
      selectedTileColor: Color(0x42000000),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: Color(0x4d000000), width: 1),
      ),
      leading: Icon(Icons.article, color: Color(0xff212435), size: 24),
      trailing: Icon(Icons.arrow_forward, color: Color(0xff212435), size: 24),
    );
  }
}
