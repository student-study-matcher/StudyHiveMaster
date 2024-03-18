import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'index.dart';

class AddGroupChat extends StatefulWidget {
  @override
  _AddGroupChatState createState() => _AddGroupChatState();
}

class _AddGroupChatState extends State<AddGroupChat> {
  Uint8List? _image;
  String selectedCategory = '';
  List<String> friends = [
    "Friend 1", "Friend 2", "Friend 3", "Friend 4", "Friend 5",
    "Friend 6", "Friend 7", "Friend 8", "Friend 9", "Friend 10"
  ];
  String? selectedFriend;

  void selectCategory(String category) {
    setState(() {
      selectedCategory = category;
    });
  }

  ElevatedButton buildCategoryButton(String category) {
    return ElevatedButton(
      onPressed: () {
        selectCategory(category);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedCategory == category ? Colors.blue : null,
      ),
      child: Text(category),
    );
  }

  Future<void> selectImage() async {
    if (kIsWeb) {
      final pickedImage = await ImagePickerWeb.getImageInfo;
      if (pickedImage != null) {
        setState(() {
          _image = pickedImage.data;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      drawer: OpenDrawer(),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xffae32ff),
        title: Text(
          "Add Group Chat",
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
            fontSize: 20,
            color: Color(0xffffffff),
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Group Chat Photo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            GestureDetector(
              onTap: selectImage,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    height: 120,
                    width: 120,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: _image != null
                        ? Image.memory(
                      _image!,
                      fit: BoxFit.cover,
                    )
                        : Container(
                      color: Colors.grey,
                      child: Icon(
                        Icons.add_a_photo_outlined,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(0),
                    padding: EdgeInsets.all(0),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(0xff3a57e8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add_a_photo_outlined,
                      color: Color(0xffffffff),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Group Name',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'Type here',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: [
                buildCategoryButton('General'),
                buildCategoryButton('Technology'),
                buildCategoryButton('Science'),
                buildCategoryButton('Sports'),
                buildCategoryButton('Art'),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Add Participants',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            PopupMenuButton<String>(
              icon: Icon(Icons.arrow_drop_down),
              itemBuilder: (BuildContext context) {
                return friends.map((String friend) {
                  return PopupMenuItem<String>(
                    value: friend,
                    child: Text(friend),
                  );
                }).toList();
              },
              onSelected: (String value) {
                setState(() {
                  selectedFriend = value;
                });
              },
            ),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: () {
                  // Implement submit button functionality
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  textStyle: TextStyle(fontSize: 16),
                ),
                child: Text('Create'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}