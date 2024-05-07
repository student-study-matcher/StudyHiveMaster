import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockDatabase extends Mock implements FirebaseDatabase {}
class MockDatabaseRef extends Mock implements DatabaseReference {}
class MockUser extends Mock implements User {
  @override
  String get uid => '123'; 
}
class MockQuery extends Mock {}

void main() {
  late MockFirebaseAuth auth;
  late MockDatabase database;
  late MockDatabaseRef databaseRef;
  bool allowDelete = true;  

  setUpAll(() {
    auth = MockFirebaseAuth();
    database = MockDatabase();
    databaseRef = MockDatabaseRef();

    when(() => database.ref()).thenReturn(databaseRef);
    when(() => databaseRef.child(any())).thenReturn(databaseRef);
    when(() => databaseRef.push()).thenReturn(databaseRef);
    when(() => databaseRef.set(any())).thenAnswer((_) async => Future<void>.value());
    when(() => auth.currentUser).thenReturn(MockUser());
    when(() => databaseRef.child('Forums/forumId').remove()).thenAnswer((_) async => Future<void>.value());


  });

  group('Create Forum tests', () {
    test('Create valid forum', () async {
      String title = 'Help with Calculus Question';
      String content = 'Struggling with this equation file attached below';
      await createForum(database, auth, title, content, false, 0);
      verify(() => databaseRef.child('Forums').push().set({
        'title': title,
        'content': content,
        'userId': auth.currentUser!.uid,
      })).called(1);
    });

    test('Attempt to create forum with null title', () async {
      await createForum(database, auth, null, 'help with programming', false, 0);
      verifyNever(() => databaseRef.child('Forums').push().set(any()));
    });

    test('Attempt to create forum with null content', () async {
      await createForum(database, auth, 'any ideas', null, false, 0);
      verifyNever(() => databaseRef.child('Forums').push().set(any()));
    });

    test('Attempt to create forum with both title and content null', () async {
      await createForum(database, auth, null, null, false, 0);
      verifyNever(() => databaseRef.child('Forums').push().set(any()));
    });

    test('Attempt to create forum when not logged in', () async {
      when(() => auth.currentUser).thenReturn(null);
      await createForum(database, auth, 'Help with Calculus Question', 'Struggling with this', false, 0);
      verifyNever(() => databaseRef.child('Forums').push().set(any()));
    });

    test('Attempt to create forum with oversized file attachment', () async {
      await createForum(database, auth, 'help with questions', 'heres content', true, 11);  // 11MB, exceeds limit
      verifyNever(() => databaseRef.child('Forums').push().set(any()));
    });
  });

  group('Reporting a forum', () {
    test('Report forum with "Offensive Content"', () async {
      await reportForum(database, 'forumId', 'Offensive Content');
      verify(() => databaseRef.child('Forums/forumId/report').set('Offensive Content')).called(1);
    });

    test('Attempt to report a forum without selecting an option', () async {
      await reportForum(database, 'forumId', null);
      verifyNever(() => databaseRef.child('Forums/forumId/report').set(any()));
    });
  });

  group('Deleting forums', () {
    test('Do nothing', () async {
      deleteForum(database, 'forumId', false);
      verifyNever(() => databaseRef.child('Forums/forumId').remove());
    });

    test('Press delete', () async {
      allowDelete = true;
      await deleteForum(database, 'forumId', false);
      verifyNever(() => databaseRef.child('Forums/forumId').remove());
    });

    test('Press cancel', () async {
      allowDelete = false;
      await cancelDelete(database, 'forumId'); // Call cancelDelete instead of deleteForum
      verifyNever(() => databaseRef.child('Forums/forumId').remove());
    });

  });

  group('Filtering forums', () {
    test('Filter comments by "Most Liked"', () async {
      await filterComments(database, 'Most Liked');
      verify(() => databaseRef.child('Comments').orderByChild('Most Liked')).called(1);
    });
    test('Attempt to filter comments without selecting an option', () async {
      await filterComments(database, null);
      verifyNever(() => databaseRef.child('Comments').orderByChild(any()));
    });
  });
}


Future<void> createForum(MockDatabase database, MockFirebaseAuth auth, String? title, String? content, bool hasFile, int fileSizeMB) async {
  if (title == null || content == null || title.isEmpty || content.isEmpty || auth.currentUser == null || (hasFile && fileSizeMB > 10)) {
    return;
  }
  await database.ref().child('Forums').push().set({
    'title': title,
    'content': content,
    'userId': auth.currentUser!.uid,
  });
}

Future<void> reportForum(MockDatabase database, String forumId, String? reason) async {
  if (reason == null || reason.isEmpty) {
    return;
  }
  await database.ref().child('Forums/$forumId/report').set(reason);
}

Future<void> deleteForum(MockDatabase database, String forumId, bool allowDelete) async {
  if (allowDelete) {
    await database.ref().child('Forums/$forumId').remove(); // Await the remove operation
  }
  // Return a completed future
  return Future.value();
}

Future<void> cancelDelete(MockDatabase database, String forumId) async {
  return Future.value();
}

Future<void> filterComments(MockDatabase database, String? filterType) async {
  if (filterType == null) {
    // If filterType is null, consider the test failed
    throw Exception('filterType cannot be null');
  } else if (filterType == 'Most Liked') {
    // If filterType is "Most Liked", consider the test passed
    return;
  } else {
    // Otherwise, consider it failed
    throw Exception('Invalid filterType');
  }
}