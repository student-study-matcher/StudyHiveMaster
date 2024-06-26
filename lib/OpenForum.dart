import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';
import 'ReportPage.dart';
import 'OpenDrawer.dart';

enum CommentFilter { mostLiked, mostRecent, oldest }

class OpenForum extends StatefulWidget {
  final String forumId;

  OpenForum({required this.forumId});

  @override
  _OpenForumState createState() => _OpenForumState();
}

class _OpenForumState extends State<OpenForum> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = true;
  Map<String, dynamic>? forumData;
  List<Map<String, dynamic>> comments = [];
  TextEditingController commentController = TextEditingController();
  CommentFilter currentFilter = CommentFilter.mostRecent;

  @override
  void initState() {
    super.initState();
    fetchForumData();
  }

  void fetchForumData() async {
    setState(() => isLoading = true);
    final forumSnapshot = await _databaseReference.child(
        'Forums/${widget.forumId}').get();
    if (forumSnapshot.exists && forumSnapshot.value != null) {
      List<Map<String, dynamic>> fetchedComments = [];
      Map<dynamic, dynamic> responses = forumSnapshot
          .child('responses')
          .value as Map<dynamic, dynamic>? ?? {};
      for (var entry in responses.entries) {
        Map<dynamic, dynamic> response = entry.value as Map<dynamic,
            dynamic>? ?? {};
        String userId = response['authorID'] ?? '';
        DataSnapshot userSnapshot = await _databaseReference.child(
            'Users/$userId').get();
        Map<dynamic, dynamic> userData = userSnapshot.value as Map<
            dynamic,
            dynamic>? ?? {};
        String profilePicture = getProfilePicturePath(userData['profilePic']);
        Map<String, dynamic> commentData = {
          'id': entry.key,
          'content': response['content'],
          'thumbsUp': response['thumbsUp'] ?? 0,
          'thumbsDown': response['thumbsDown'] ?? 0,
          'username': userData['username'] ?? 'Unknown',
          'profilePicture': profilePicture,
          'timestamp': response['timestamp']
        };
        fetchedComments.add(commentData);
      }
      setState(() {
        forumData =
        Map<String, dynamic>.from(forumSnapshot.value as Map<dynamic, dynamic>);
        comments = fetchedComments;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  String getProfilePicturePath(int? profilePicIndex) {
    switch (profilePicIndex) {
      case 1:
        return "assets/purple.png";
      case 2:
        return "assets/blue.png";
      case 3:
        return "assets/blue-purple.png";
      case 4:
        return "assets/orange.png";
      case 5:
        return "assets/pink.png";
      case 6:
        return "assets/turquoise.png";
      default:
        return "assets/default_profile_picture.png";
    }
  }

  Future<void> postComment() async {
    final String userId = _auth.currentUser!.uid;
    final String comment = commentController.text.trim();
    if (comment.isNotEmpty) {
      await _databaseReference.child('Forums/${widget.forumId}/responses')
          .push()
          .set({
        'content': comment,
        'authorID': userId,
        'thumbsUp': 0,
        'thumbsDown': 0,
        'timestamp': DateTime
            .now()
            .millisecondsSinceEpoch,
      });
      commentController.clear();
      fetchForumData();
    }
  }

  void sortComments(CommentFilter filter) {
    setState(() {
      comments.sort((a, b) {
        switch (filter) {
          case CommentFilter.mostLiked:
            return (b['thumbsUp'] ?? 0).compareTo(a['thumbsUp'] ?? 0);
          case CommentFilter.mostRecent:
            return (b['timestamp'] ?? 0).compareTo(a['timestamp'] ?? 0);
          case CommentFilter.oldest:
            return (a['timestamp'] ?? 0).compareTo(b['timestamp'] ?? 0);
        }
      });
    });
  }

  void navigateToReportPage(String commentId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>
          ReportPage(forumId: widget.forumId, commentId: commentId)),
    );
  }

  Future<void> _launchURL(String url) async {
    await showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('Warning!'),
            content: Text(
                'You are about to download a file from the internet. Always ensure that the source is trustworthy to avoid security risks.'),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text('Continue'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Could not launch $url')));
                  }
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(forumData?['title'] ?? 'Forum'),
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
        actions: [
          PopupMenuButton<CommentFilter>(
            onSelected: (CommentFilter result) {
              currentFilter = result;
              sortComments(currentFilter);
            },
            itemBuilder: (BuildContext context) =>
            <PopupMenuEntry<CommentFilter>>[
              const PopupMenuItem<CommentFilter>(
                value: CommentFilter.mostLiked,
                child: Text('Most Liked'),
              ),
              const PopupMenuItem<CommentFilter>(
                value: CommentFilter.mostRecent,
                child: Text('Most Recent'),
              ),
              const PopupMenuItem<CommentFilter>(
                value: CommentFilter.oldest,
                child: Text('Oldest'),
              ),
            ],
          ),
        ],
      ),
      drawer: OpenDrawer(),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(forumData?['title'] ?? 'No Title', style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text(forumData?['content'] ?? 'No Content',
                  style: TextStyle(fontSize: 18)),

              if (forumData?['fileUrl'] != null)
                InkWell(
                  onTap: () => _launchURL(forumData!['fileUrl']),
                  child: Text(
                    'Download Attached File',
                    style: TextStyle(decoration: TextDecoration.underline,
                        color: Colors.blue),
                  ),
                ),
              Divider(),
              Text('Comments:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...comments.map((comment) =>
                  ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(comment['profilePicture']),
                    ),
                    title: Text(comment['content']),
                    subtitle: Text('Sent by: ${comment['username']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.thumb_up),
                          onPressed: () => toggleLike(comment['id']),

                        ),
                        Text('${comment['thumbsUp'] ?? 0}'),
                        IconButton(
                          icon: Icon(Icons.thumb_down),
                          onPressed: () => toggleDislike(comment['id']),

                        ),
                        Text('${comment['thumbsDown'] ?? 0}'),
                        IconButton(
                          icon: Icon(Icons.report),
                          onPressed: () => navigateToReportPage(comment['id']),
                        ),
                      ],
                    ),
                  )),
              TextField(
                controller: commentController,
                decoration: InputDecoration(
                  labelText: 'Write a comment...',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.send),
                    onPressed: postComment,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> toggleLike(String commentId) async {
    DatabaseReference likeRef = _databaseReference.child(
        'Forums/${widget.forumId}/responses/$commentId/likes/${_auth
            .currentUser!.uid}');
    DataSnapshot snapshot = await likeRef.get();
    bool liked = snapshot.exists;
    if (liked) {
      likeRef.remove();
      int currentLikes = comments.firstWhere((element) =>
      element['id'] == commentId)['thumbsUp'];
      _databaseReference.child('Forums/${widget.forumId}/responses/$commentId')
          .update({'thumbsUp': currentLikes - 1});
    } else {
      DatabaseReference dislikeRef = _databaseReference.child(
          'Forums/${widget.forumId}/responses/$commentId/dislikes/${_auth
              .currentUser!.uid}');
      DataSnapshot dislikeSnapshot = await dislikeRef.get();
      bool disliked = dislikeSnapshot.exists;
      if (disliked) {
        dislikeRef.remove();
        int currentDislikes = comments.firstWhere((element) =>
        element['id'] == commentId)['thumbsDown'];
        _databaseReference.child(
            'Forums/${widget.forumId}/responses/$commentId').update(
            {'thumbsDown': currentDislikes - 1});
      }
      likeRef.set(true);
      int currentLikes = comments.firstWhere((element) =>
      element['id'] == commentId)['thumbsUp'];
      _databaseReference.child('Forums/${widget.forumId}/responses/$commentId')
          .update({'thumbsUp': currentLikes + 1});
    }
    fetchForumData();
  }

  Future<void> toggleDislike(String commentId) async {
    DatabaseReference dislikeRef = _databaseReference.child(
        'Forums/${widget.forumId}/responses/$commentId/dislikes/${_auth
            .currentUser!.uid}');
    DataSnapshot snapshot = await dislikeRef.get();
    bool disliked = snapshot.exists;
    if (disliked) {
      dislikeRef.remove();
      int currentDislikes = comments.firstWhere((element) =>
      element['id'] == commentId)['thumbsDown'];
      _databaseReference.child('Forums/${widget.forumId}/responses/$commentId')
          .update({'thumbsDown': currentDislikes - 1});
    } else {
      DatabaseReference likeRef = _databaseReference.child(
          'Forums/${widget.forumId}/responses/$commentId/likes/${_auth
              .currentUser!.uid}');
      DataSnapshot likeSnapshot = await likeRef.get();
      bool liked = likeSnapshot.exists;
      if (liked) {
        likeRef.remove();
        int currentLikes = comments.firstWhere((element) =>
        element['id'] == commentId)['thumbsUp'];
        _databaseReference.child(
            'Forums/${widget.forumId}/responses/$commentId').update(
            {'thumbsUp': currentLikes - 1});
      }
      dislikeRef.set(true);
      int currentDislikes = comments.firstWhere((element) =>
      element['id'] == commentId)['thumbsDown'];
      _databaseReference.child('Forums/${widget.forumId}/responses/$commentId')
          .update({'thumbsDown': currentDislikes + 1});
    }
    fetchForumData();
  }
}
