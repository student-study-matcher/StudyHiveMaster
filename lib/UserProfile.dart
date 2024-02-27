import 'package:flutter/material.dart';
import 'HomeScreen.dart';
import 'Setting.dart';
import 'Forums.dart';

class UserProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xffad32fe),
        title: GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HomeScreen())),
          child: Row(
            children: [
              Image.asset('assets/logo.png', width: 28),
              SizedBox(width: 28),
              Text("Study Hive", style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16, color: Colors.white)),
            ],
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => Setting())),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.settings),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          bottomNavItem(Icons.article, "Forums"),
          bottomNavItem(Icons.message, "Messages"),
          bottomNavItem(Icons.account_box, "Profile"),
        ],
        onTap: (int index) {
          if (index == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => Forums()));
          } else if (index == 1) {
            // Handle Messages
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfile()));
          }
        },
        backgroundColor: Color(0xffae32ff),
        elevation: 8,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                // select photo
              },
              child: CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage("assets/profilePicture1.png"),
              ),
            ),
            SizedBox(height: 10),
            Text("Angelina", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            Text("Hudhra", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ProfileInfoBox(title: "Big Data"),
                ProfileInfoBox(title: "120 Friends"),
                ProfileInfoBox(title: "University of Portsmouth"),
              ],
            ),
            SizedBox(height: 20),
            ProfileBioBox(
              initialBio: "I like football",
              onBioChanged: (newBio) {
                //  bio
              },
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem bottomNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: label,
    );
  }
}

class ProfileInfoBox extends StatelessWidget {
  final String title;

  ProfileInfoBox({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 5),
          Text("", style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

class ProfileBioBox extends StatefulWidget {
  final String initialBio;
  final void Function(String newBio) onBioChanged;

  ProfileBioBox({required this.initialBio, required this.onBioChanged});

  @override
  _ProfileBioBoxState createState() => _ProfileBioBoxState();
}

class _ProfileBioBoxState extends State<ProfileBioBox> {
  late String _bio;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _bio = widget.initialBio;
    _controller = TextEditingController(text: _bio);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("Bio", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Spacer(),
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  widget.onBioChanged(_bio);
                },
              ),
            ],
          ),
          SizedBox(height: 10),
          TextFormField(
            controller: _controller,
            onChanged: (value) {
              setState(() {
                _bio = value;
              });
            },
            decoration: InputDecoration(
              hintText: "Type your bio here...",
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
