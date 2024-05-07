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

  setUpAll(() {
    auth = MockFirebaseAuth();
    database = MockDatabase();
    databaseRef = MockDatabaseRef();
    String commentId = 'commentId';

    when(() => databaseRef.child('Comments/$commentId/likes').remove()).thenAnswer((_) async => Future.value());
    when(() => databaseRef.child('Comments/$commentId/dislikes').remove()).thenAnswer((_) async => Future.value());
    when(() => database.ref()).thenReturn(databaseRef);
    when(() => databaseRef.child(any())).thenReturn(databaseRef);
    when(() => databaseRef.push()).thenReturn(databaseRef);
    when(() => databaseRef.set(any())).thenAnswer((_) async => Future<void>.value());  // Ensure 'set' returns a Future<void>
    when(() => auth.currentUser).thenReturn(MockUser());
  });

  group('Writing comments tests', () {
    test('Sending null comment', () async {
      String comment = '';
      // Expect no action when the comment is empty
      await sendComment(database, 'commentId', comment, auth);
      verifyNever(() => databaseRef.child('Comments/commentId').push().set(any()));
    });

    test('Sending valid comment', () async {
      String comment = 'Hello';
      await sendComment(database, 'commentId', comment, auth);
      verify(() => databaseRef.child('Comments/commentId').push().set({
        'text': comment,
        'userId': auth.currentUser!.uid,
        'timestamp': ServerValue.timestamp,
      })).called(1);
    });
    test('Sending comment with special characters and numbers', () async {
      String comment = '1_.-@2';
      await sendComment(database, 'commentId', comment, auth);
      verify(() => databaseRef.child('Comments/commentId').push().set({
        'text': comment,
        'userId': auth.currentUser!.uid,
        'timestamp': ServerValue.timestamp,
      })).called(1);
    });
  });

  group('Like/Dislike comments tests', () {
    test('Like Comment - User does not press button (no input)', () async {
      bool isLike = false;
      await likeComment(database, 'commentId', isLike, auth);
      verifyNever(() => databaseRef.child('Comments/commentId/likes').push().set(any()));
    });

    test('Like Comment - Button press', () async {
      bool isLike = true;
      await likeComment(database, 'commentId', isLike, auth);
      verify(() => databaseRef.child('Comments/commentId/likes').push().set({
        'userId': auth.currentUser!.uid,
        'isLike': isLike,
      })).called(1);

    });
    test('Dislike Comment - User does not press button (no input)', () async {
      bool isDislike = false; // No dislike action taken
      await likeComment(database, 'commentId', isDislike, auth);
      verifyNever(() => databaseRef.child('Comments/commentId/likes').push().set(any())); // Verify no dislike action is taken
    });

    test('Dislike Comment - Button press', () async {
      bool isDisLike = true;
      await likeComment(database, 'commentId', isDisLike, auth);
      verify(() => databaseRef.child('Comments/commentId/likes').push().set({
        'userId': auth.currentUser!.uid,
        'isDisLike': isDisLike,
      })).called(1);
    });

    test('Toggle from dislike to like', () async {
      String commentId = 'commentId';
      await toggleLike(commentId, database, auth);

      verify(() => databaseRef.child('Comments/$commentId/dislikes').remove());
      verify(() => databaseRef.child('Comments/$commentId/likes').push().set({
        'userId': auth.currentUser!.uid,
        'isLike': false,
      })).called(1);
    });

    test('Toggle from like to dislike', () async {
      String commentId = 'commentId';
      await toggleDislike(commentId, database, auth);

      verify(() => databaseRef.child('Comments/$commentId/likes').remove());
      verify(() => databaseRef.child('Comments/$commentId/dislikes').push().set({
        'userId': auth.currentUser!.uid,
        'isLike': false,
      })).called(1);
    });
  });
}

Future<void> sendComment(MockDatabase database, String commentId, String comment, MockFirebaseAuth auth) async {
  if (commentId.isEmpty || comment.isEmpty || auth.currentUser == null) {
    return;  // Early return if the inputs are invalid
  }
  await database.ref().child('Comments/$commentId').push().set({
    'text': comment,
    'userId': auth.currentUser!.uid,
    'timestamp': ServerValue.timestamp,
  });
}

Future<void> likeComment(MockDatabase database, String commentId, bool isLike, MockFirebaseAuth auth) async {
  if (commentId.isEmpty || auth.currentUser == null) {
    return;  // Early return if the inputs are invalid
  }
  await database.ref().child('Comments/$commentId/${isLike ? "likes" : "dislikes"}').push().set({
    'userId': auth.currentUser!.uid,
    'isLike': isLike,
  });
}

Future<void> toggleLike(String commentId, MockDatabase database, MockFirebaseAuth auth) async {
  if (auth.currentUser == null) {
    print('User is not authenticated.');
    return;
  }

  DatabaseReference likeRef = database.ref().child('Comments/$commentId/likes');
  DatabaseReference dislikeRef = database.ref().child('Comments/$commentId/dislikes');
  DataSnapshot likeSnapshot;
  try {
    likeSnapshot = await likeRef.child(auth.currentUser!.uid).get();
  } catch (error) {
    return;
  }

  bool liked = likeSnapshot.exists;

  if (liked) {
    // If the user has already liked the comment, remove the like
    await likeRef.child(auth.currentUser!.uid).remove();
  } else {
    await dislikeRef.child(auth.currentUser!.uid).remove();
    await likeRef.child(auth.currentUser!.uid).set({
      'userId': auth.currentUser!.uid,
      'isLike': true,
    });
  }
}
Future<void> toggleDislike(String commentId, MockDatabase database, MockFirebaseAuth auth) async {
  if (auth.currentUser == null) {
    return;
  }
  DatabaseReference likeRef = database.ref().child('Comments/$commentId/likes');
  DatabaseReference dislikeRef = database.ref().child('Comments/$commentId/dislikes');

  DataSnapshot dislikeSnapshot;
  try {
    dislikeSnapshot = await dislikeRef.child(auth.currentUser!.uid).get();
  } catch (error) {
    return;
  }

  bool disliked = dislikeSnapshot.exists;
  if (disliked) {
    await dislikeRef.child(auth.currentUser!.uid).remove();
  } else {
    await likeRef.child(auth.currentUser!.uid).remove();
    await dislikeRef.child(auth.currentUser!.uid).set({
      'userId': auth.currentUser!.uid,
      'isDislike': true,
    });
  }
}
