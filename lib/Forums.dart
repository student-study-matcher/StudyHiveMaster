import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'OpenForum.dart';
import 'AddForum.dart';
import 'ReportPage.dart';
import 'OpenDrawer.dart';

class Forums extends StatefulWidget {
  @override
  _ForumsState createState() => _ForumsState();
}

class _ForumsState extends State<Forums> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> allForums = [];
  List<Map<String, dynamic>> userForums = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  Map<String, bool> subjectFilters = {};
  Map<String, String> subjectNames = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchForums();
    fetchSubjectNames();
  }

  void fetchSubjectNames() async {
    DataSnapshot snapshot = await _databaseReference.child('Subjects').get();
    if (snapshot.exists) {
      Map<dynamic, dynamic> subjects = snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        subjectNames = subjects.map((key, value) => MapEntry(key.toString(), value.toString()));
        subjectFilters = subjects.map((key, value) => MapEntry(key.toString(), false));
        print(subjectFilters);
      });
    }
  }

  void fetchForums() {
    _databaseReference.child('Forums').orderByChild('timestamp').onValue.listen((event) {
      final forumsData = event.snapshot.value as Map<dynamic, dynamic>?;
      final currentUser = _auth.currentUser?.uid;

      if (forumsData != null) {
        List<Map<String, dynamic>> loadedAllForums = [];
        List<Map<String, dynamic>> loadedUserForums = [];

        forumsData.forEach((key, value) {
          final forum = Map<String, dynamic>.from(value);
          forum['forumId'] = key;
          loadedAllForums.add(forum);

          if (forum['authorID'] == currentUser) {
            loadedUserForums.add(forum);
          }
        });

        setState(() {
          allForums = loadedAllForums.reversed.toList();
          userForums = loadedUserForums;
        });
      }
    });
  }

  List<Map<String, dynamic>> applySubjectFilters(List<Map<String, dynamic>> forums) {
    print('called');

    Set<String> activeFilters = subjectFilters.entries
        .where((entry) => entry.value)
        .map((entry) => subjectNames[entry.key])
        .whereType<String>()
        .toSet();

    print('Active Filters: $activeFilters');

    List<Map<String, dynamic>> filteredForums = forums.where((forum) {
      bool subjectMatchesFilter = activeFilters.contains(forum['subject']);
      print('Forum Subject: ${forum['subject']}, Matches Filter: $subjectMatchesFilter');
      return subjectMatchesFilter;
    }).toList();

    print('Filtered Forums: $filteredForums');

    return activeFilters.isEmpty ? forums : filteredForums;
  }




  void toggleSubjectFilter(String subjectId) {
    setState(() {
      subjectFilters[subjectId] = !subjectFilters[subjectId]!;
      if (subjectFilters.values.every((v) => !v)) {
        subjectFilters.updateAll((key, value) => false);
      }
    });
  }

  void toggleAllSubjects(bool enable) {
    setState(() {
      subjectFilters.updateAll((key, value) => enable);
    });
  }

  void showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        List<Widget> filterWidgets = subjectNames.entries.map((entry) {
          return CheckboxListTile(
            title: Text(entry.value),
            value: subjectFilters[entry.key],
            onChanged: (bool? value) {
              Navigator.pop(context);
              toggleSubjectFilter(entry.key);
            },
          );
        }).toList();

        return AlertDialog(
          title: Text('Filter by Subject'),
          content: SingleChildScrollView(
            child: Column(
              children: filterWidgets,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      drawer: OpenDrawer(),
      appBar: AppBar(
        title: Text('Forums', style: TextStyle(color: Colors.white), ),
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
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: showFilterDialog,
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddForum())),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.grey,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              tabs: [
                Tab(text: "Current Forums"),
                Tab(text: "Your Forums"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                buildForumList(applySubjectFilters(allForums), false),
                buildForumList(applySubjectFilters(userForums), true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildForumList(List<Map<String, dynamic>> forums, bool showDeleteButton) {
    return ListView.builder(
      itemCount: forums.length,
      itemBuilder: (context, index) {
        final forum = forums[index];
        return Card(
          elevation: 4,
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            title: Text(forum["title"] ?? 'No Title'),
            subtitle: Text("${forum["content"] ?? 'No Content'} - ${forum['subject']}"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => OpenForum(forumId: forum['forumId'])),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.flag, color: Colors.red),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ReportPage(forumId: forum['forumId'])),
                  ),
                ),
                if (showDeleteButton) IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => confirmDelete(context, forum['forumId']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  void deleteForum(String forumId) async {
    await _databaseReference.child('Forums/$forumId').remove();
    fetchForums();
  }

  void confirmDelete(BuildContext context, String forumId) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Confirm Delete"),
            content: Text("Are you sure you want to delete this forum?"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Cancel")
              ),
              TextButton(
                  onPressed: () {
                    deleteForum(forumId);
                    Navigator.of(context). pop();
                  },
                  child: Text("Delete")
              ),
            ],
          );
        }
    );
  }
}
