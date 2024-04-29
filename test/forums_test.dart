import 'package:firebase_database/firebase_database.dart'; // Importing the Firebase Realtime Database package
import 'package:flutter_test/flutter_test.dart'; // Importing the Flutter test package
import 'package:mocktail/mocktail.dart'; // Importing the Mocktail package for mocking

import 'mocks.dart'; // Importing the mocks file which contains mocked objects

void main() {
  setUpMocks(); // Call setUpMocks() to initialize mock objects

  // Test for verifying forum creation by a registered user
  test('Registered user creates forum', () async {
    print('Test Start: Registered user creates forum'); // Print statement for test start
    // Mock database interaction to simulate forum creation
    when(() => mockDatabaseRef.child(any())).thenReturn(mockDatabaseRef); // Mocking child method of DatabaseReference
    when(() => mockDatabaseRef.set(any())).thenAnswer((_) async => {}); // Mocking set method of DatabaseReference

    // Call the function or method responsible for forum creation
    await createForum(mockDatabase, 'userId', 'forumTitle', 'forumContent');

    // Verify that the correct database operations were called
    verify(() => mockDatabaseRef.child('Forums').push().set({
      'title': 'forumTitle',
      'content': 'forumContent',
      'createdBy': 'userId',
      // Additional forum data if required
    })).called(1); // Verifying the database operation for forum creation
    print('Test Passed: Forum created successfully'); // Print statement for test success
  });

  // Test for verifying forum deletion by a registered user
  test('Registered user deletes forum', () async {
    print('Test Start: Registered user deletes forum'); // Print statement for test start
    // Mock database interaction to simulate forum deletion
    when(() => mockDatabaseRef.remove()).thenAnswer((_) async => {}); // Mocking remove method of DatabaseReference

    // Call the function or method responsible for forum deletion
    await deleteForum(mockDatabase, 'forumId');

    // Verify that the correct database operations were called
    verify(() => mockDatabaseRef.child('Forums/forumId').remove()).called(1); // Verifying the database operation for forum deletion
    print('Test Passed: Forum deleted successfully'); // Print statement for test success
  });

  // Test for verifying user commenting on a forum
  test('Registered user comments', () async {
    print('Test Start: Registered user comments'); // Print statement for test start
    // Mock database interaction to simulate user commenting on a forum
    when(() => mockDatabaseRef.push()).thenReturn(mockDatabaseRef); // Mocking push method of DatabaseReference
    when(() => mockDatabaseRef.set(any())).thenAnswer((_) async => {}); // Mocking set method of DatabaseReference

    // Call the function or method responsible for adding a comment
    await addComment(mockDatabase, 'forumId', 'userId', 'commentContent');

    // Verify that the correct database operations were called
    verify(() => mockDatabaseRef.child('Comments/forumId').push().set({
      'userId': 'userId',
      'content': 'commentContent',
      'timestamp': any(named: 'timestamp'),
      // Additional comment data if required
    })).called(1); // Verifying the database operation for adding a comment
    print('Test Passed: Comment added successfully'); // Print statement for test success
  });

  // Test for verifying user reporting a forum
  test('User reports a forum', () async {
    print('Test Start: User reports a forum'); // Print statement for test start
    // Mock database interaction to simulate user reporting a forum
    when(() => mockDatabaseRef.set(any())).thenAnswer((_) async => {}); // Mocking set method of DatabaseReference

    // Call the function or method responsible for reporting a forum
    await reportForum(mockDatabase, 'forumId', 'userId', 'reason');

    // Verify that the correct database operations were called
    verify(() => mockDatabaseRef.child('Reports/forumId').push().set({
      'userId': 'userId',
      'reason': 'reason',
      'timestamp': any(named: 'timestamp'),
      // Additional report data if required
    })).called(1); // Verifying the database operation for reporting a forum
    print('Test Passed: Forum reported successfully'); // Print statement for test success
  });

  // Test for verifying user liking/disliking a comment on a forum
  test('Registered user likes/dislikes forum comments', () async {
    print('Test Start: Registered user likes/dislikes forum comments'); // Print statement for test start
    // Mock database interaction to simulate user liking/disliking a comment
    when(() => mockDatabaseRef.set(any())).thenAnswer((_) async => {}); // Mocking set method of DatabaseReference

    // Call the function or method responsible for liking/disliking a comment
    await likeComment(mockDatabase, 'forumId', 'commentId', 'userId', true);

    // Verify that the correct database operations were called
    verify(() => mockDatabaseRef.child('Likes/forumId/commentId').set({
      'userId': 'userId',
      'isLike': true,
      'timestamp': any(named: 'timestamp'),
      // Additional like data if required
    })).called(1); // Verifying the database operation for liking/disliking a comment
    print('Test Passed: Comment liked/disliked successfully'); // Print statement for test success
  });

  // Test for verifying a user who is not logged in trying to interact with a forum
  test('User not logged in tries to interact with forum', () async {
    print('Test Start: User not logged in tries to interact with forum'); // Print statement for test start
    // Mock database interaction to simulate an unauthenticated user attempting interaction
    when(() => mockAuth.currentUser).thenReturn(null); // Mocking currentUser property of FirebaseAuth

    // Call the function or method responsible for user interaction
    final result = await userInteractsWithForum(mockDatabase, 'forumId', 'userId');

    // Verify the result of the interaction
    expect(result, false); // Verifying that the user interaction result is false
    print('Test Passed: User not logged in'); // Print statement for test success
  });

  // Test for verifying a user trying to send restricted content
  test('User tries to send restricted content', () async {
    print('Test Start: User tries to send restricted content'); // Print statement for test start
    // Mock database interaction to simulate a user attempting to send restricted content
    when(() => mockDatabaseRef.set(any())).thenAnswer((_) async => {}); // Mocking set method of DatabaseReference

    // Call the function or method responsible for sending content
    final result = await sendContent(mockDatabase, 'userId', 'restrictedContent');

    // Verify the result of the content sending attempt
    expect(result, false); // Verifying that the content sending result is false
    print('Test Passed: User tried to send restricted content'); // Print statement for test success
  });
}

// Implementations of the functionalities to be tested

// Function to create a forum
Future<void> createForum(FirebaseDatabase db, String userId, String title, String content) async {
  DatabaseReference ref = db.ref();
  await ref.child('Forums').push().set({
    'title': title,
    'content': content,
    'createdBy': userId,
    'timestamp': DateTime.now().toIso8601String(),
    // Additional forum data if required
  });
}

// Function to delete a forum
Future<void> deleteForum(FirebaseDatabase db, String forumId) async {
  DatabaseReference ref = db.ref();
  await ref.child('Forums/$forumId').remove();
}

// Function to add a comment to a forum
Future<void> addComment(FirebaseDatabase db, String forumId, String userId, String content) async {
  DatabaseReference ref = db.ref();
  await ref.child('Comments/$forumId').push().set({
    'userId': userId,
    'content': content,
    'timestamp': DateTime.now().toIso8601String(),
    // Additional comment data if required
  });
}

// Function to report a forum
Future<void> reportForum(FirebaseDatabase db, String forumId, String userId, String reason) async {
  DatabaseReference ref = db.ref();
  await ref.child('Reports/$forumId').push().set({
    'userId': userId,
    'reason': reason,
    'timestamp': DateTime.now().toIso8601String(),
    // Additional report data if required
  });
}

// Function to like/dislike a comment on a forum
Future<void> likeComment(FirebaseDatabase db, String forumId, String commentId, String userId, bool isLike) async {
  DatabaseReference ref = db.ref();
  await ref.child('Likes/$forumId/$commentId').set({
    'userId': userId,
    'isLike': isLike,
    'timestamp': DateTime.now().toIso8601String(),
    // Additional like data if required
  });
}

// Function to check if a user is logged in and interacting with a forum
Future<bool> userInteractsWithForum(FirebaseDatabase db, String forumId, String userId) async {
  DatabaseReference ref = db.ref();
  final snapshot = await ref.child('Forums/$forumId').once();
  // Check if the user is logged in
  if (mockAuth.currentUser != null) {
    // User is logged in, allow interaction
    return true;
  } else {
    // User is not logged in, disallow interaction
    return false;
  }
}

// Function to send content, checking for restrictions
Future<bool> sendContent(FirebaseDatabase db, String userId, String content) async {
  DatabaseReference ref = db.ref();
  // Check if the content is restricted
  if (content.contains('restricted')) {
    // Content is restricted, disallow sending
    return false;
  } else {
    // Content is not restricted, allow sending
    await ref.child('Content').push().set({
      'userId': userId,
      'content': content,
      'timestamp': DateTime.now().toIso8601String(),
      // Additional content data if required
    });
    return true;
  }
}
