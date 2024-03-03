import 'package:flutter/material.dart';
import 'index.dart';


class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  List<String> friends = [
    "Friend 1", "Friend 2", "Friend 3", "Friend 4", "Friend 5",
    "Friend 6", "Friend 7", "Friend 8", "Friend 9", "Friend 10"
  ];
  bool isDropdownOpen = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: OpenDrawer(),
      appBar: CustomAppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
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
                    ProfileFriendsButton(
                      onPressed: () {
                        setState(() {
                          isDropdownOpen = !isDropdownOpen;
                        });
                      },
                    ),
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
          if (isDropdownOpen)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: FriendsPopup(
                friends: friends,
                onFriendSelected: (friend) {
                  setState(() {
                    isDropdownOpen = false;
                  });
                },
                onClose: () => setState(() {
                  isDropdownOpen = false;
                }),
              ),
            ),
        ],
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

class ProfileFriendsButton extends StatelessWidget {
  final VoidCallback onPressed;

  ProfileFriendsButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onPressed,
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text("Friends", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
        ),
      ],
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
}