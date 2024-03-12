import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'index.dart';

class AddForum extends StatefulWidget {
  @override
  _AddForumState createState() => _AddForumState();
}

class _AddForumState extends State<AddForum> {
  PlatformFile? pickedFile;
  String selectedSubject = '';

  Future uploadFile() async {
    final file = File(pickedFile!.path!);
    // Implement file upload logic here
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
    });
  }

  void selectSubject(String subject) {
    setState(() {
      selectedSubject = subject;
    });
  }

  ElevatedButton buildSubjectButton(String subject) {
    return ElevatedButton(
      onPressed: () {
        selectSubject(subject);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedSubject == subject ? Colors.blue : null,
      ),
      child: Text(subject),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      drawer: OpenDrawer(),
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Forum title',
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
              'Subject',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                buildSubjectButton('Computing'),
                SizedBox(width: 8),
                buildSubjectButton('Big Data'),
                SizedBox(width: 8),
                buildSubjectButton('Cyber security'),
                SizedBox(width: 8),
                buildSubjectButton('Maths'),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Discussion',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Expanded(
              child: TextField(
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Type here',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            if (pickedFile != null)
              Expanded(
                child: Container(
                  color: Colors.blue[100],
                  child: Center(
                    child: Text(pickedFile!.name),
                  ),
                ),
              ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: selectFile,
              child: const Text('Select File'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: uploadFile,
              child: const Text('Upload File'),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                // Implement submit button functionality
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
