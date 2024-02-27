import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      appBar: AppBar(
        elevation: 4,
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xffad32fe),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        title: GestureDetector(                                          // press the app logo to go back to the home screen
          onTap: () {
            Navigator.of(context).pushReplacementNamed('/home');
          },
          child: Row(
            children: [
              Image.asset(
                'assets/logo.png',
                width: 24,
              ),
              SizedBox(width: 8), // Add some spacing if needed
              Text(
                "Study Hive",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontStyle: FontStyle.normal,
                  fontSize: 14,
                  color: Color(0xffffffff),
                ),
              ),
            ],
          ),
        ),

        actions: [
          Icon(Icons.search, color: Color(0xffffffff), size: 24),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.article),
              label: "Forums"

          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.message),
              label: "Messages"
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_box),
              label: "Profile"
          ),

        ],
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
        onTap: (value) {},

      ),
      body: Padding(
        padding: EdgeInsets.all(2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              "Top Forums For You",
              textAlign: TextAlign.center,
              overflow: TextOverflow.clip,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.normal,
                fontSize: 17,
                color: Color(0xff000000),
              ),
            ),
            ListView(
              scrollDirection: Axis.vertical,
              padding: EdgeInsets.all(0),
              shrinkWrap: true,
              physics: ScrollPhysics(),
              children: [
                ListTile(
                  tileColor: Color(0x1f000000),
                  title: Text(
                    "Software Engineering",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 14,
                      color: Color(0xff000000),
                    ),
                    textAlign: TextAlign.start,
                  ),
                  subtitle: Text(
                    "Computer Science",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 14,
                      color: Color(0xff000000),
                    ),
                    textAlign: TextAlign.start,
                  ),
                  dense: false,
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  selected: false,
                  selectedTileColor: Color(0x42000000),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                    side: BorderSide(color: Color(0x4d000000), width: 1),
                  ),
                  leading:
                  Icon(Icons.article, color: Color(0xff212435), size: 24),
                  trailing: Icon(Icons.arrow_forward,
                      color: Color(0xff212435), size: 24),
                ),
                ListTile(
                  tileColor: Color(0x1f000000),
                  title: Text(
                    "BIDMAS",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 14,
                      color: Color(0xff000000),
                    ),
                    textAlign: TextAlign.start,
                  ),
                  subtitle: Text(
                    "Maths",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 14,
                      color: Color(0xff000000),
                    ),
                    textAlign: TextAlign.start,
                  ),
                  dense: false,
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  selected: false,
                  selectedTileColor: Color(0x42000000),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                    side: BorderSide(color: Color(0x4d000000), width: 1),
                  ),
                  leading:
                  Icon(Icons.article, color: Color(0xff212435), size: 24),
                  trailing: Icon(Icons.arrow_forward,
                      color: Color(0xff212435), size: 24),
                ),
                ListTile(
                  tileColor: Color(0x1f000000),
                  title: Text(
                    "Bones",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 14,
                      color: Color(0xff000000),
                    ),
                    textAlign: TextAlign.start,
                  ),
                  subtitle: Text(
                    "Science",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 14,
                      color: Color(0xff000000),
                    ),
                    textAlign: TextAlign.start,
                  ),
                  dense: false,
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  selected: false,
                  selectedTileColor: Color(0x42000000),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                    side: BorderSide(color: Color(0x4d000000), width: 1),
                  ),
                  leading:
                  Icon(Icons.article, color: Color(0xff212435), size: 24),
                  trailing: Icon(Icons.arrow_forward,
                      color: Color(0xff212435), size: 24),
                ),
              ],
            ),
            Text(
              "Your Friends Most Recent Posts",
              textAlign: TextAlign.center,
              overflow: TextOverflow.clip,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontStyle: FontStyle.normal,
                fontSize: 17,
                color: Color(0xff000000),
              ),
            ),
            ListView(
              scrollDirection: Axis.vertical,
              padding: EdgeInsets.all(0),
              shrinkWrap: true,
              physics: ScrollPhysics(),
              children: [
                ListTile(
                  tileColor: Color(0x1f000000),
                  title: Text(
                    "Big Data",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 14,
                      color: Color(0xff000000),
                    ),
                    textAlign: TextAlign.start,
                  ),
                  subtitle: Text(
                    "Computer Science",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 14,
                      color: Color(0xff000000),
                    ),
                    textAlign: TextAlign.start,
                  ),
                  dense: false,
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  selected: false,
                  selectedTileColor: Color(0x42000000),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                    side: BorderSide(color: Color(0x4d000000), width: 1),
                  ),
                  leading:
                  Icon(Icons.article, color: Color(0xff212435), size: 24),
                  trailing: Icon(Icons.arrow_forward,
                      color: Color(0xff212435), size: 24),
                ),
                ListTile(
                  tileColor: Color(0x1f000000),
                  title: Text(
                    "UI Design",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 14,
                      color: Color(0xff000000),
                    ),
                    textAlign: TextAlign.start,
                  ),
                  subtitle: Text(
                    "Computer Science",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 14,
                      color: Color(0xff000000),
                    ),
                    textAlign: TextAlign.start,
                  ),
                  dense: false,
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  selected: false,
                  selectedTileColor: Color(0x42000000),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                    side: BorderSide(color: Color(0x4d000000), width: 1),
                  ),
                  leading:
                  Icon(Icons.article, color: Color(0xff212435), size: 24),
                  trailing: Icon(Icons.arrow_forward,
                      color: Color(0xff212435), size: 24),
                ),
                ListTile(
                  tileColor: Color(0x1f000000),
                  title: Text(
                    "Databases",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 14,
                      color: Color(0xff000000),
                    ),
                    textAlign: TextAlign.start,
                  ),
                  subtitle: Text(
                    "Computer Science",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      fontSize: 14,
                      color: Color(0xff000000),
                    ),
                    textAlign: TextAlign.start,
                  ),
                  dense: false,
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  selected: false,
                  selectedTileColor: Color(0x42000000),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                    side: BorderSide(color: Color(0x4d000000), width: 1),
                  ),
                  leading:
                  Icon(Icons.article, color: Color(0xff212435), size: 24),
                  trailing: Icon(Icons.arrow_forward,
                      color: Color(0xff212435), size: 24),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
