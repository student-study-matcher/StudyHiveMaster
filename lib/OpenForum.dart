import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'ReportPage.dart';

class OpenForum extends StatefulWidget {
  final String forumId;

  OpenForum({required this.forumId});

  @override
  _OpenForumState createState() => _OpenForumState();
}

class _OpenForumState extends State<OpenForum> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic> forumData = {};
  List<Map<String, dynamic>> comments = [];
  bool isLoading = true;
  TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchForumData();
  }

  fetchForumData() async {
    setState(() {
      isLoading = true;
    });


    final forumSnapshot = await _databaseReference.child('Forums/${widget.forumId}').get();
    if (forumSnapshot.exists && forumSnapshot.value != null) {
      final forumDetails = Map<String, dynamic>.from(forumSnapshot.value as Map);

      final commentsSnapshot = await _databaseReference.child('Forums/${widget.forumId}/responses').get();
      final List<Map<String, dynamic>> commentsList = [];
      if (commentsSnapshot.exists && commentsSnapshot.value != null) {
        Map<String, dynamic>.from(commentsSnapshot.value as Map).forEach((key, value) {
          commentsList.add({
            "id": key,
            ...value,
          });
        });
      }

      setState(() {
        forumData = forumDetails;
        forumData['content'] = forumDetails['originalPost']['content'];  // Store the fetched content in forumData
        comments = commentsList;
        isLoading = false;
      });
    }
  }

  Future<void> postComment() async {
    final String userId = _auth.currentUser!.uid;
    final String comment = commentController.text.trim();
    if (comment.isNotEmpty) {
      final newCommentRef = _databaseReference.child('Forums/${widget.forumId}/responses').push();
      await newCommentRef.set({
        'content': comment,
        'authorID': userId,
        'thumbsUp': 0,
        'thumbsDown': 0,
        'timestamp': ServerValue.timestamp,
      });
      commentController.clear();
      fetchForumData();
    }
  }
  Future<void> incrementThumbsUp(String commentId) async {
    final commentRef = _databaseReference.child('Forums/${widget.forumId}/responses/$commentId');
    final dataSnapshot = await commentRef.child('thumbsUp').get();
    final currentCount = dataSnapshot.exists ? int.tryParse(dataSnapshot.value.toString()) ?? 0 : 0;
    await commentRef.child('thumbsUp').set(currentCount + 1);
    fetchForumData();
  }

  Future<void> incrementThumbsDown(String commentId) async {
    final commentRef = _databaseReference.child('Forums/${widget.forumId}/responses/$commentId');
    final dataSnapshot = await commentRef.child('thumbsDown').get();
    final currentCount = dataSnapshot.exists ? int.tryParse(dataSnapshot.value.toString()) ?? 0 : 0;
    await commentRef.child('thumbsDown').set(currentCount + 1);
    fetchForumData();
  }


  navigateToReportPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReportPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(forumData['title'] ?? 'Forum'),
        backgroundColor: Color(0xffad32fe),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                forumData['title'] ?? 'No Title',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      forumData['content'] ?? 'No Content',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.report),
                    onPressed: navigateToReportPage,
                  ),
                ],
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return ListTile(
                  title: Text(comment['content']),
                  subtitle: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.thumb_up),
                        onPressed: () => incrementThumbsUp(comment['id']),
                      ),
                      Text('${comment['thumbsUp'] ?? 0}'),
                      IconButton(
                        icon: Icon(Icons.thumb_down),
                        onPressed: () => incrementThumbsDown(comment['id']),
                      ),
                      Text('${comment['thumbsDown'] ?? 0}'),
                      IconButton(
                        icon: Icon(Icons.report),
                        onPressed: navigateToReportPage,
                      ),
                    ],
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
              child: TextField(
                controller: commentController,
                decoration: InputDecoration(
                  labelText: 'Write a comment...',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: postComment,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
