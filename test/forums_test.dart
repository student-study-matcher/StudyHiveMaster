import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseDatabase extends Mock implements FirebaseDatabase {}
class MockDatabaseReference extends Mock implements DatabaseReference {}
class MockDataSnapshot extends Mock implements DataSnapshot {}
class MockDatabaseEvent extends Mock implements DatabaseEvent {}
class MockUser extends Mock implements User {}

// Declare mock instances as global variables
MockFirebaseAuth? mockAuth;
MockFirebaseDatabase? mockDatabase;
MockDatabaseReference? mockDatabaseRef;
MockDatabaseEvent? mockDatabaseEvent;
MockDataSnapshot? mockDataSnapshot;
MockUser? mockUser;

void setUpMocks() {
  // Initialize the mocks
  mockAuth = MockFirebaseAuth();
  mockDatabase = MockFirebaseDatabase();
  mockDatabaseRef = MockDatabaseReference();
  mockDatabaseEvent = MockDatabaseEvent();
  mockDataSnapshot = MockDataSnapshot();
  mockUser = MockUser();

  // Set up the when conditions
  when(() => mockAuth?.currentUser).thenReturn(mockUser);
  when(() => mockUser?.uid).thenReturn('userId');
  when(() => mockDatabase?.ref()).thenReturn(mockDatabaseRef);
  when(() => mockDatabaseRef?.child(any())).thenReturn(mockDatabaseRef);
  when(() => mockDatabaseRef?.set(any())).thenAnswer((_) async => {});
  when(() => mockDatabaseRef?.remove()).thenAnswer((_) async => {});
  when(() => mockDatabaseRef?.push()).thenReturn(mockDatabaseRef);
  when(() => mockDatabaseRef?.once()).thenAnswer((_) async => mockDatabaseEvent!); // Mock the once method
  when(() => mockDatabaseEvent?.snapshot).thenReturn(mockDataSnapshot);
  when(() => mockDataSnapshot?.exists).thenReturn(true);
}

void main() {
  setUpMocks();

  test('Registered user creates forum', () async {
    print('Test Start: Registered user creates forum');
    when(() => mockDatabaseRef!.child(any())).thenReturn(mockDatabaseRef!);
    when(() => mockDatabaseRef!.set(any())).thenAnswer((_) async => {});

    await createForum(mockDatabase!, 'userId', 'forumTitle', 'forumContent');

    verify(() => mockDatabaseRef!.child('Forums').push().set({
      'title': 'forumTitle',
      'content': 'forumContent',
      'createdBy': 'userId',
    })).called(1);
    print('Test Passed: Forum created successfully');
  });

  test('Registered user deletes forum', () async {
    print('Test Start: Registered user deletes forum');
    when(() => mockDatabaseRef!.remove()).thenAnswer((_) async => {});

    await deleteForum(mockDatabase!, 'forumId');

    verify(() => mockDatabaseRef!.child('Forums/forumId').remove()).called(1);
    print('Test Passed: Forum deleted successfully');
  });

  test('Registered user comments', () async {
    print('Test Start: Registered user comments');
    when(() => mockDatabaseRef!.push()).thenReturn(mockDatabaseRef!);
    when(() => mockDatabaseRef!.set(any())).thenAnswer((_) async => {});

    await addComment(mockDatabase!, 'forumId', 'userId', 'commentContent');

    verify(() => mockDatabaseRef!.child('Comments/forumId').push().set({
      'userId': 'userId',
      'content': 'commentContent',
      'timestamp': DateTime.now().toIso8601String(),
    })).called(1);
    print('Test Passed: Comment added successfully');
  });

  test('User reports a forum', () async {
    print('Test Start: User reports a forum');
    when(() => mockDatabaseRef!.set(any())).thenAnswer((_) async => {});

    await reportForum(mockDatabase!, 'forumId', 'userId', 'reason');

    verify(() => mockDatabaseRef!.child('Reports/forumId').push().set({
      'userId': 'userId',
      'reason': 'reason',
      'timestamp': DateTime.now().toIso8601String(),
    })).called(1);
    print('Test Passed: Forum reported successfully');
  });

  test('Registered user likes/dislikes forum comments', () async {
    print('Test Start: Registered user likes/dislikes forum comments');
    when(() => mockDatabaseRef!.set(any())).thenAnswer((_) async => {});

    await likeComment(mockDatabase!, 'forumId', 'commentId', 'userId', true);

    verify(() => mockDatabaseRef!.child('Likes/forumId/commentId').set({
      'userId': 'userId',
      'isLike': true,
      'timestamp': DateTime.now().toIso8601String(),
    })).called(1);
    print('Test Passed: Comment liked/disliked successfully');
  });

  test('User not logged in tries to interact with forum', () async {
    print('Test Start: User not logged in tries to interact with forum');
    when(() => mockAuth!.currentUser).thenReturn(null);

    final result = await userInteractsWithForum(mockDatabase!, 'forumId', 'userId');

    expect(result, false);
    print('Test Passed: User not logged in');
  });

  test('User tries to send restricted content', () async {
    print('Test Start: User tries to send restricted content');
    when(() => mockDatabaseRef!.set(any())).thenAnswer((_) async => {});

    final result = await sendContent(mockDatabase!, 'userId', 'restrictedContent');

    expect(result, false);
    print('Test Passed: User tried to send restricted content');
  });
}

// Implementations of the functionalities to be tested

Future<void> createForum(FirebaseDatabase db, String userId, String title, String content) async {
  DatabaseReference ref = db.ref();
  await ref.child('Forums').push().set({
    'title': title,
    'content': content,
    'createdBy': userId,
    'timestamp': DateTime.now().toIso8601String(),
  });
}

Future<void> deleteForum(FirebaseDatabase db, String forumId) async {
  DatabaseReference ref = db.ref();
  await ref.child('Forums/$forumId').remove();
}

Future<void> addComment(FirebaseDatabase db, String forumId, String userId, String content) async {
  DatabaseReference ref = db.ref();
  await ref.child('Comments/$forumId').push().set({
    'userId': userId,
    'content': content,
    'timestamp': DateTime.now().toIso8601String(),
  });
}

Future<void> reportForum(FirebaseDatabase db, String forumId, String userId, String reason) async {
  DatabaseReference ref = db.ref();
  await ref.child('Reports/$forumId').push().set({
    'userId': userId,
    'reason': reason,
    'timestamp': DateTime.now().toIso8601String(),
  });
}

Future<void> likeComment(FirebaseDatabase db, String forumId, String commentId, String userId, bool isLike) async {
  DatabaseReference ref = db.ref();
  await ref.child('Likes/$forumId/$commentId').set({
    'userId': userId,
    'isLike': isLike,
    'timestamp': DateTime.now().toIso8601String(),
  });
}

Future<bool> userInteractsWithForum(FirebaseDatabase db, String forumId, String userId) async {
  DatabaseReference ref = db.ref();
  final snapshot = await ref.child('Forums/$forumId').once();
  if (mockAuth!.currentUser != null) {
    return true;
  } else {
    return false;
  }
}

Future<bool> sendContent(FirebaseDatabase db, String userId, String content) async {
  DatabaseReference ref = db.ref();
  if (content.contains('restricted')) {
    return false;
  } else {
    await ref.child('Content').push().set({
      'userId': userId,
      'content': content,
      'timestamp': DateTime.now().toIso8601String(),
    });
    return true;
  }
}
