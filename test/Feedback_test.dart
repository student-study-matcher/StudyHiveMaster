import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockDatabase extends Mock implements FirebaseDatabase {}

class MockDatabaseRef extends Mock implements DatabaseReference {}

class MockUser extends Mock implements User {
  @override
  String get uid => '123';
}

void main() {
  late MockFirebaseAuth auth;
  late MockDatabase database;
  late MockDatabaseRef databaseRef;

  setUpAll(() async {
    auth = MockFirebaseAuth();
    database = MockDatabase();
    databaseRef = MockDatabaseRef();

    when(() => database.ref()).thenReturn(databaseRef);
    when(() => databaseRef.child(any())).thenReturn(databaseRef);
    when(() => databaseRef.push()).thenReturn(databaseRef);
    when(() => auth.currentUser).thenReturn(MockUser());
  });

  group('Writing comments tests', () {
    test('Sending null comment', () async {
      // Test sending a null comment
      String comment = '';

      await sendComment(database, 'commentId', comment, auth);

      // Verify that no comment is sent
      verifyNever(() => databaseRef.child('Comments/commentId').push().set(any()));
    });

    test('Sending valid comment', () async {
      // Test sending a valid comment
      String comment = 'Hello';

      await sendComment(database, 'commentId', comment, auth);

      // Verify that the comment is sent
      verify(() => databaseRef.child('Comments/commentId').push().set({
        'text': comment,
        'userId': auth.currentUser!.uid,
        'timestamp': ServerValue.timestamp,
      })).called(1);
    });

    test('Sending comment with restricted characters', () async {
      // Test sending a comment with restricted characters
      String comment = '1_.-@2';

      await sendComment(database, 'commentId', comment, auth);

      // Verify that no comment is sent
      verifyNever(() => databaseRef.child('Comments/commentId').push().set(any()));
    });
  });

  group('Liking comments tests', () {
    test('Like Comment - User does not press button', () async {
      // Test scenario when user does not press the like button
      bool isLike = false;

      await likeComment(database, 'commentId', isLike, auth);

      // Verify that no action is taken (like counter remains unchanged)
      verifyNever(() => databaseRef.child('Comments/commentId/likes').push().set(any()));
    });

    test('Like Comment - Button press', () async {
      // Test scenario when user presses the like button
      bool isLike = true;

      await likeComment(database, 'commentId', isLike, auth);

      // Verify that the like action is performed
      verify(() => databaseRef.child('Comments/commentId/likes').push().set({
        'userId': auth.currentUser!.uid,
        'isLike': isLike,
      })).called(1);
    });

    test('Dislike Comment - User does not press button', () async {
      // Test scenario when user does not press the dislike button
      bool isLike = true;

      await likeComment(database, 'commentId', isLike, auth);

      // Verify that no action is taken (dislike counter remains unchanged)
      verifyNever(() => databaseRef.child('Comments/commentId/dislikes').push().set(any()));
    });

    test('Dislike Comment - Button press', () async {
      // Test scenario when user presses the dislike button
      bool isLike = false;

      await likeComment(database, 'commentId', isLike, auth);

      // Verify that the dislike action is performed
      verify(() => databaseRef.child('Comments/commentId/dislikes').push().set({
        'userId': auth.currentUser!.uid,
        'isLike': isLike,
      })).called(1);
    });

    test('Toggle from like to dislike', () async {
      // Set up initial like for the comment
      await likeComment(database, 'commentId', true, auth);

      // Toggle to dislike
      await toggleDislike('commentId', database, auth);

      // Verify that the like has been removed
      verify(() => databaseRef.child('Comments/commentId/likes').remove()).called(1);

      // Verify that a dislike action is performed
      verify(() => databaseRef.child('Comments/commentId/dislikes').push().set({
        'userId': auth.currentUser!.uid,
        'isLike': false,
      })).called(1);
    });

    test('Toggle from dislike to like', () async {
      // Set up initial dislike for the comment
      await likeComment(database, 'commentId', false, auth);

      // Toggle to like
      await toggleLike('commentId', database, auth);

      // Verify that the dislike has been removed
      verify(() => databaseRef.child('Comments/commentId/dislikes').remove()).called(1);

      // Verify that a like action is performed
      verify(() => databaseRef.child('Comments/commentId/likes').push().set({
        'userId': auth.currentUser!.uid,
        'isLike': true,
      })).called(1);
    });
  });
}

Future<void> sendComment(MockDatabase database, String commentId, String comment, MockFirebaseAuth auth) async {
  if (commentId.isEmpty || comment.isEmpty || auth == null) {
    // Handle null inputs gracefully
    return;
  }
  final String userId = auth.currentUser!.uid;
  await database.ref().child('Comments/$commentId').push().set({
    'text': comment,
    'userId': userId,
    'timestamp': ServerValue.timestamp,
  });
}

Future<void> likeComment(MockDatabase database, String commentId, bool isLike, MockFirebaseAuth auth) async {
  if (commentId.isEmpty || auth == null) {
    // Handle null inputs gracefully
    return;
  }
  final String userId = auth.currentUser!.uid;
  final String path = isLike ? 'likes' : 'dislikes';
  await database.ref().child('Comments/$commentId/$path').push().set({
    'userId': userId,
    'isLike': isLike,
  });
}

Future<void> toggleLike(String commentId, MockDatabase database, MockFirebaseAuth auth) async {
  if (commentId.isEmpty || database == null || auth == null) {
    // Handle null inputs gracefully
    return;
  }
  final String userId = auth.currentUser!.uid;
  await database.ref().child('Comments/$commentId/likes').remove();
  await likeComment(database, commentId, true, auth);
}

Future<void> toggleDislike(String commentId, MockDatabase database, MockFirebaseAuth auth) async {
  if (commentId.isEmpty || database == null || auth == null) {
    // Handle null inputs gracefully
    return;
  }
  final String userId = auth.currentUser!.uid;
  await database.ref().child('Comments/$commentId/dislikes').remove();
  await likeComment(database, commentId, false, auth);
}

