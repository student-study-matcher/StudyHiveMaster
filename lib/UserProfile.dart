import 'package:flutter/material.dart';
import 'HomeScreen.dart';
import 'Forums.dart';


class UserProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserProfile()),
            );
          } else if (index == 2) {

          }
        },
        backgroundColor: Color(0xffae32ff),
        elevation: 8,
        selectedItemColor: Color(0xffffffff),
        unselectedItemColor: Color(0xffffffff),
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
                // Implement photo selection logic
              },
              child: CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage("assets/profilePicture1.png"),
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Angelina",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              "Hudhra",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ProfileInfoBox(title: "Big Data", subtitle: ""),
                ProfileInfoBox(title: "120 Friends", subtitle: ""),
                ProfileInfoBox(title: "University of Portsmouth", subtitle: ""),
              ],
            ),
            SizedBox(height: 20),
            ProfileBioBox(
              initialBio: "I like football",
              onBioChanged: (newBio) {
                // Implement edit bio logic
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileInfoBox extends StatelessWidget {
  final String title;
  final String subtitle;

  ProfileInfoBox({required this.title, required this.subtitle});

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
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 5),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
            ),
          ),
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
              Text(
                "Bio",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
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
