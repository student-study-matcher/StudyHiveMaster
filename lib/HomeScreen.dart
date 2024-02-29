import 'package:flutter/material.dart';
import 'Forums.dart';
import 'Settings.dart';
import 'UserProfile.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 4,
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xffad32fe),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        title: GestureDetector(
          onTap: () => Navigator.of(context).pushReplacementNamed('/home'),
          child: Row(
            children: [
              Image.asset(
                'assets/logo.png',
                width: 24,
              ),
              SizedBox(width: 8),
              Text(
                "Study Hive",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Icon(Icons.search, color: Colors.white, size: 24),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          bottomNavItem(Icons.article, "Forums"),
          bottomNavItem(Icons.message, "Messages"),
          bottomNavItem(Icons.account_box, "Profile"),
        ],
        backgroundColor: Color(0xffae32ff),
        elevation: 8,
        iconSize: 22,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (value) {
          if (value == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => Forums()));
          } else if (value == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => UserProfile()));
          }
        },
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

  BottomNavigationBarItem bottomNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: label,
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