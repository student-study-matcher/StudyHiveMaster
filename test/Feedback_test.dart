import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockDatabase extends Mock implements FirebaseDatabase {}

class MockDatabaseRef extends Mock implements DatabaseReference {}

class MockBuildContext extends Mock implements BuildContext {}

class MockNavigatorState extends Mock implements NavigatorState {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.debug}) {
    return super.toString();
  }
}

class MockUser extends Mock implements User {
  @override
  String get uid => '123';
}

class MockScaffoldMessengerState extends Mock
    implements ScaffoldMessengerState {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.debug}) {
    return super.toString();
  }
}

class MockSnackBar extends Mock implements SnackBar {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.debug}) {
    return super.toString();
  }
}

void main() {
  late MockFirebaseAuth auth;
  late MockDatabase database;
  late MockDatabaseRef databaseRef;
  late MockBuildContext context;
  late MockNavigatorState navigator;

  setUpAll(() async {
    auth = MockFirebaseAuth();
    database = MockDatabase();
    databaseRef = MockDatabaseRef();
    context = MockBuildContext();
    navigator = MockNavigatorState();

    // Mock the behavior of database methods
    when(() => database.ref()).thenReturn(databaseRef);
    when(() => databaseRef.child(any())).thenReturn(databaseRef);
    when(() => databaseRef.push()).thenReturn(databaseRef);

    // Mock the set method to return a Future<void>
    when(() => databaseRef.set(any())).thenAnswer((_) async => {});

    when(() => auth.currentUser).thenReturn(MockUser());

    when(() => databaseRef.child('Forums').child(any()).push()).thenReturn(databaseRef);
    when(() => databaseRef.child('Forums').child(any()).child('messages').push()).thenReturn(databaseRef);

    when(() => context.findAncestorStateOfType<NavigatorState>())
        .thenReturn(navigator);

    when(() => navigator.pop()).thenAnswer((_) async => {});
  });

  group('Message tests', () {
    test('send message in forums', () async {
      print('Test Start: User send message in forums');
      String forumId = '123';
      String message = 'A message!';

      await sendMessageInForums(
        database: database,
        auth: auth,
        navigator: navigator,
        forumId: forumId,
        message: message,
        context: context,
      );

      verify(() => databaseRef.child('Forums/$forumId/messages').push().set({
        'text': message,
        'senderId': auth.currentUser?.uid,
        'timestamp': ServerValue.timestamp,
      })).called(1);

      verify(() => navigator.pop()).called(1);
      print('Test Passed: User send message in forums');

    });

    test('send message in forums with restricted word', () async {
      print('Test Start: User send message in forums with restricted word');
      String forumId = '123';
      String message = 'This message contains a restricted word: badword';

      await sendMessageInForums(
        database: database,
        auth: auth,
        navigator: navigator,
        forumId: forumId,
        message: message,
        context: context,
      );
      verifyNever(() => databaseRef.child('Forums/$forumId/messages').push().set(any()));
      print('Test Passed: User send message in forums with restricted word');
    });

    test('like or dislike forum comment', () async {
      print('Test Start: User like or dislike forum comment');
      String commentId = '456';
      bool isLike = true;

      await likeOrDislikeComment(
        database: database,
        auth: auth,
        commentId: commentId,
        isLike: isLike,
      );

      verify(() => databaseRef.child('Comments/$commentId/likes').push().set({
        'userId': auth.currentUser?.uid,
        'isLike': isLike,
      })).called(1);
      print('Test Start: User like or dislike forum comment');
    });
  });
}

Future<void> sendMessageInForums({
  required MockDatabase database,
  required MockFirebaseAuth auth,
  required MockNavigatorState navigator,
  required String forumId,
  required String message,
  required MockBuildContext context,
}) async {
  // Check if the message contains any restricted words
  if (message.contains('badword')) {
    // Handle the scenario when the message contains a restricted word
    // You can add further logic here, such as displaying an error message or preventing the message from being sent
    return;
  }

  // Send the message if there are no restricted words
  await database.ref().child('Forums/$forumId/messages').push().set({
    'text': message,
    'senderId': auth.currentUser?.uid,
    'timestamp': ServerValue.timestamp,
  });

  navigator.pop();
}

Future<void> likeOrDislikeComment({
  required MockDatabase database,
  required MockFirebaseAuth auth,
  required String commentId,
  required bool isLike,
}) async {
  await database.ref().child('Comments/$commentId/likes').push().set({
    'userId': auth.currentUser?.uid,
    'isLike': isLike,
  });
}

