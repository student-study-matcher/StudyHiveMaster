import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:studyhive/OpenDrawer.dart';

class AddForum extends StatefulWidget {
  @override
  _AddForumState createState() => _AddForumState();
}

class _AddForumState extends State<AddForum> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  List<String> subjects = [];
  String? selectedSubject;
  Uint8List? _fileBytes;
  String? _fileName;

  @override
  void initState() {
    super.initState();
    fetchSubjects();
  }

  void fetchSubjects() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref('Subjects');
    DatabaseEvent event = await ref.once();
    if (event.snapshot.exists) {
      List<String> loadedSubjects = [];
      event.snapshot.children.forEach((DataSnapshot snapshot) {
        loadedSubjects.add(snapshot.value.toString());
      });
      setState(() {
        subjects = loadedSubjects;
        if (subjects.isNotEmpty) selectedSubject = subjects[0];
      });
    }
  }

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpeg', 'doc', 'docx'],
        withData: true
    );

    if (result != null) {
      String? pickedFileName = result.files.single.name;
      List<String> allowedExtensions = ['pdf', 'png', 'jpeg', 'doc', 'docx'];
      String fileExtension = pickedFileName.split('.').last;

      if (!allowedExtensions.contains(fileExtension.toLowerCase())) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid file type. Allowed types: PDF, PNG, JPEG, DOC, DOCX'))
        );
        return;
      }

      if (result.files.single.size <= 10485760) {
        setState(() {
          _fileBytes = result.files.single.bytes;
          _fileName = result.files.single.name;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File too large (max size: 10MB)'))
        );
      }
    }
  }


  Future<String?> uploadFile() async {
    if (_fileBytes != null) {
      try {
        String userId = _auth.currentUser?.uid ?? '';
        String filePath = 'private/$userId/$_fileName';
        final ref = FirebaseStorage.instance.ref().child(filePath);
        final result = await ref.putData(_fileBytes!);
        return await result.ref.getDownloadURL();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload file: $e')));
        return null;
      }
    }
    return null;
  }

  void _submitForum() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Title and content cannot be empty'))
      );
      return;
    }

    String? fileUrl = await uploadFile();

    String userId = _auth.currentUser?.uid ?? '';
    Map<String, dynamic> forum = {
      'title': _titleController.text.trim(),
      'content': _contentController.text.trim(),
      'subject': selectedSubject,
      'authorID': userId,
      'timestamp': ServerValue.timestamp,
      'responses': {},
      'fileUrl': fileUrl,
    };

    await _databaseReference.child('Forums').push().set(forum);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: Text('Add Forum' ,style: TextStyle(color: Colors.white), ),

    flexibleSpace: Container(
    decoration: BoxDecoration(
    gradient: LinearGradient(
    colors: [
    Color(0xFF8A2387),
    Color(0xFFE94057),
    Color(0xFFF27121),
    ],
    ),
    ),
    ),
        ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Forum Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _contentController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Content',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            DropdownButton<String>(
              value: selectedSubject,
              isExpanded: true,
              onChanged: (String? newValue) {
                setState(() {
                  selectedSubject = newValue!;
                });
              },
              items: subjects.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
            _fileName == null
                ? ElevatedButton(
              onPressed: pickFile,
              child: Text('Attach File'),
            )
                : Column(
              children: [
                Text('Attached File: $_fileName'),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _fileBytes = null;
                      _fileName = null;
                    });
                  },
                  child: Text('Remove File'),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForum,
              child: Text('Submit Forum'),
            ),
          ],
        ),
      ),
    );
  }
}
