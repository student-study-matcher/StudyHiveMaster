import 'package:flutter/material.dart';
import 'EditProfile.dart';
import 'ChangePassword.dart';
import 'ReportBug.dart';
import 'Notifications.dart';
import 'HomeScreen.dart';
import 'UserProfile.dart';
import 'Forums.dart';

class Setting extends StatelessWidget {
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
      body: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  height: 16,
                  width: 16,
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to Edit Profile page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditProfile()),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                    child: ListTile(
                      tileColor: Color(0x00ffffff),
                      title: Text(
                        "Edit Profile",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: 16,
                          color: Color(0xff000000),
                        ),
                        textAlign: TextAlign.left,
                      ),
                      dense: true,
                      contentPadding: EdgeInsets.all(0),
                      selected: false,
                      selectedTileColor: Color(0x42000000),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      leading: Icon(Icons.account_circle,
                          color: Color(0xff3a57e8), size: 24),
                      trailing: Icon(Icons.arrow_forward_ios,
                          color: Color(0xff808080), size: 18),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to Change Password page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChangePassword()),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                    child: ListTile(
                      tileColor: Color(0x1fffffff),
                      title: Text(
                        "Change Password",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: 16,
                          color: Color(0xff000000),
                        ),
                        textAlign: TextAlign.start,
                      ),
                      dense: false,
                      contentPadding: EdgeInsets.all(0),
                      selected: false,
                      selectedTileColor: Color(0x42000000),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                        side: BorderSide(color: Color(0x4dffffff), width: 1),
                      ),
                      leading:
                      Icon(Icons.vpn_key, color: Color(0xff3b58e9), size: 24),
                      trailing: Icon(Icons.arrow_forward_ios,
                          color: Color(0xff828181), size: 18),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to Notifications page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Notifications()),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                    child: ListTile(
                      tileColor: Color(0x00ffffff),
                      title: Text(
                        "Notifications",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: 16,
                          color: Color(0xff000000),
                        ),
                        textAlign: TextAlign.left,
                      ),
                      dense: true,
                      contentPadding: EdgeInsets.all(0),
                      selected: false,
                      selectedTileColor: Color(0x42000000),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      leading: Icon(Icons.notifications,
                          color: Color(0xff3a57e8), size: 24),
                      trailing: Icon(Icons.arrow_forward_ios,
                          color: Color(0xff808080), size: 18),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to Report Bug page
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReportBug()),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                    child: ListTile(
                      tileColor: Color(0x1fffffff),
                      title: Text(
                        "Report Bug",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.normal,
                          fontSize: 16,
                          color: Color(0xff000000),
                        ),
                        textAlign: TextAlign.left,
                      ),
                      dense: false,
                      contentPadding: EdgeInsets.all(0),
                      selected: false,
                      selectedTileColor: Color(0x42000000),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                        side: BorderSide(color: Color(0xffffffff), width: 1),
                      ),
                      leading:
                      Icon(Icons.warning, color: Color(0xff3a56e7), size: 24),
                      trailing: Icon(Icons.arrow_forward_ios,
                          color: Color(0xff818181), size: 18),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 100, 0, 0),
                  child: SizedBox(
                    width: double.infinity,
                    child: Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFFEF2828),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            side: BorderSide(
                              color: Color(0xff808080),
                              width: 1,
                            ),
                          ),
                          padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          minimumSize: Size(
                            MediaQuery.of(context).size.width,
                            50,
                          ),
                        ),
                        child: Text(
                          "Log Out",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            fontStyle: FontStyle.normal,
                            color: Color(0xffffffff), // White color for text
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
