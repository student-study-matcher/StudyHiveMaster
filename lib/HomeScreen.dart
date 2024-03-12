import 'package:flutter/material.dart';
import 'index.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: OpenDrawer(),
      appBar: CustomAppBar(),

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
