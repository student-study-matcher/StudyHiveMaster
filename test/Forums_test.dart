import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:image_picker/image_picker.dart';


// Mocks
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseDatabase extends Mock implements FirebaseDatabase {
  @override
  DatabaseReference reference() {
    // Return a mock DatabaseReference here
    return MockDatabaseReference();
  }
}
class MockDatabaseReference extends Mock implements DatabaseReference {}
class MockDataSnapshot extends Mock implements DataSnapshot {}
class MockDatabaseEvent extends Mock implements DatabaseEvent {}
class MockUser extends Mock implements User {}
class MockXFile extends Mock implements XFile {
  int lengthSync() {
    return 0; // Return any suitable value for your test case
  }
}


void main() {
  late MockFirebaseDatabase mockDatabase;
  late MockDatabaseReference mockDatabaseRef;
  late MockDatabaseEvent mockDatabaseEvent;
  late MockDataSnapshot mockDataSnapshot;
  late MockFirebaseAuth mockAuth;
  late MockXFile mockFile;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockFile = MockXFile();

    mockDatabase = MockFirebaseDatabase();
    mockDatabaseRef = MockDatabaseReference();
    mockDatabaseEvent = MockDatabaseEvent();
    mockDataSnapshot = MockDataSnapshot();

    // Ensure that mockDatabase returns mockDatabaseRef when reference() is called
    when(() => mockDatabase.reference()).thenReturn(mockDatabaseRef);

  });

  // Forum Creation Tests
  test('Forum Creation: Title and Content Provided', () async {
    when(() => mockDatabase.reference()).thenReturn(mockDatabaseRef);
    when(() => mockDatabaseRef.set(any())).thenAnswer((_) async => {});

    await createForum(mockDatabase, 'userId', 'Help with Calculus Question', 'Struggling with this equation file attached below');

    expect(mockDatabaseRef, isNotNull); // Assert mockDatabaseRef is not null
    verify(() => mockDatabaseRef.child('Forums').push().set({
      'title': 'Help with Calculus Question',
      'content': 'Struggling with this equation file attached below',
      'createdBy': 'userId',
      'timestamp': any(named: 'timestamp'),
    })).called(1);
  });


  test('Forum Creation: No Title Provided', () async {
    await createForum(mockDatabase, 'userId', '', 'Struggling with this equation file attached below');

    verifyNever(() => mockDatabaseRef.child(any()));
  });

  test('Forum Creation: No Content Provided', () async {
    await createForum(mockDatabase, 'userId', 'Help with Calculus Question', '');

    verifyNever(() => mockDatabaseRef.child(any()));
  });

  test('Forum Creation: Title and Content Null', () async {
    await createForum(mockDatabase, 'userId', '', '');

    verifyNever(() => mockDatabaseRef.child(any()));
  });

  test('Forum Creation: Not Logged In', () async {
    when(() => mockAuth.currentUser).thenReturn(null);

    await createForum(mockDatabase, 'userId', 'Help with Calculus Question', 'Struggling with this equation file attached below');

    verifyNever(() => mockDatabaseRef.child(any()));
  });

  test('Forum Creation: Large File Attached', () async {
    final largeFile = List.filled(11 * 1024 * 1024, 0);
    when(() => mockFile.lengthSync()).thenReturn(11 * 1024 * 1024);

    await createForum(mockDatabase, 'userId', 'Help with questions', 'heres content', mockFile);

    verifyNever(() => mockDatabaseRef.child(any()));
  });

  // Reporting a Forum Tests
  test('Reporting a Forum: Valid Reason Selected', () async {
    when(() => mockDatabaseRef.set(any())).thenAnswer((_) async => {});

    await reportForum(mockDatabase, 'forumId', 'userId', 'Offensive Content');

    verify(() => mockDatabaseRef.child('Reports/forumId').push().set({
      'userId': 'userId',
      'reason': 'Offensive Content',
      'timestamp': any(named: 'timestamp'),
    })).called(1);
  });

  test('Reporting a Forum: No Reason Selected', () async {
    await reportForum(mockDatabase, 'forumId', 'userId', '');

    verifyNever(() => mockDatabaseRef.child(any()));
  });

  // Delete A Forum Test
  test('Delete A Forum: Valid', () async {
    when(() => mockDatabaseRef.remove()).thenAnswer((_) async => {});

    await deleteForum(mockDatabase, 'forumId');

    verify(() => mockDatabaseRef.child('Forums/forumId').remove()).called(1);
  });

  // Filter Comments Tests
  test('Filter Comments: Most Liked Selected', () async {
    when(() => mockDatabaseRef.set(any())).thenAnswer((_) async => {});

    await filterComments(mockDatabase, 'Most Liked');

    verify(() => mockDatabaseRef.child('Comments').orderByChild('likes').once()).called(1);
  });

  test('Filter Comments: Null Filter', () async {
    await filterComments(mockDatabase, null);

    verifyNever(() => mockDatabaseRef.child(any()));
  });
}



Future<void> deleteForum(FirebaseDatabase db, String forumId) async {
  DatabaseReference ref = db.ref();
  await ref.child('Forums/$forumId').remove();
}

Future<void> reportForum(FirebaseDatabase db, String forumId, String userId, String reason) async {
  DatabaseReference ref = db.ref();
  if (reason.isNotEmpty) {
    await ref.child('Reports/$forumId').push().set({
      'userId': userId,
      'reason': reason,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}

Future<void> filterComments(FirebaseDatabase db, String? filter) async {
  DatabaseReference ref = db.ref();
  if (filter == 'Most Liked') {
    await ref.child('Comments').orderByChild('likes').once();
  }
}
Future<void> createForum(FirebaseDatabase db, String userId, String title, String content, [XFile? file]) async {
  DatabaseReference ref = db.ref();

  if (title.isNotEmpty && content.isNotEmpty && (file == null || await _isFileSizeValid(file))) {
    await ref.child('Forums').push().set({
      'title': title,
      'content': content,
      'createdBy': userId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
Future<bool> _isFileSizeValid(XFile file) async {
  if (file == null) {
    return true; // No file provided, consider size valid
  }

  // Get file size asynchronously
  final fileLength = await file.length();

  // Check if file size exceeds the limit (10 MB)
  const maxSizeBytes = 10 * 1024 * 1024;
  return fileLength <= maxSizeBytes;
}
