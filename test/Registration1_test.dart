import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockDatabase extends Mock implements FirebaseDatabase {}

class MockDatabaseRef extends Mock implements DatabaseReference {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockUser extends Mock implements User {
  @override
  String get uid => '123';
}

class MockUserCredential extends Mock implements UserCredential {
  @override
  User get user => MockUser();
}

void main() async {
  late MockFirebaseAuth auth;
  late MockDatabaseRef database;

  setUp(() async {
    auth = MockFirebaseAuth();
    database = MockDatabaseRef();
  });

  test('register user successfully', () async {
    String email = 'ex@example.com';
    String password = 'password123';

    when(() => auth.createUserWithEmailAndPassword(
        email: email, password: password))
        .thenAnswer((invocation) => Future.value(MockUserCredential()));

    when(() => database.child(any())).thenReturn(database);
    when(() => database.child(any()).child(any())).thenReturn(database);

    when(() => database.set(any())).thenAnswer((_) async => {});

    await registerUser1(auth, database, email, password, password);

    verify(() => auth.createUserWithEmailAndPassword(
        email: email, password: password)).called(1);
  });

  test('register user with already used email', () async {
    String email = 'wrong@email.com';
    String password = 'password123';

    when(() =>
        auth.createUserWithEmailAndPassword(
            email: email, password: password)).thenThrow(FirebaseAuthException(
        code: 'email-already-in-use',
        message: 'The email address is already in use by another account.'));

    when(() => database.child(any())).thenReturn(database);
    when(() => database.child(any()).child(any())).thenReturn(database);

    when(() => database.set(any())).thenAnswer((_) async => {});

    expect(
            () async =>
        await registerUser1(auth, database, email, password, password),
        throwsException);
  });
}

Future<void> registerUser1(MockFirebaseAuth auth, MockDatabaseRef database,
    String email, String password, String confirmPassword) async {
  if (password != confirmPassword) {
    throw Exception('Passwords do not match.');
  }
  try {
    final newUser = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (newUser.user != null) {
      database.child('Users').child(newUser.user!.uid).set({
        'email': email,
      });

      print("registration successful");
    }
  } on FirebaseAuthException catch (e) {
    throw Exception(e.message ?? 'An unknown error occurred.');
  }
}

Future<void> registerUser2(
    MockFirebaseAuth auth,
    MockDatabase database,
    String userFirstName,
    String userLastName,
    String userDOBString,
    String username,
    String userCourse,
    String userUniversity) async {
  if (userFirstName.isEmpty ||
      userLastName.isEmpty ||
      userDOBString.isEmpty ||
      username.isEmpty) {
    throw Exception('Please fill in all the required fields.');
  }

  DateTime userDOB = DateTime.parse(userDOBString);
  DateTime now = DateTime.now();
  int age = now.year - userDOB.year;

  if (age < 18) {
    // Check that the user is old enough to use the app
    throw Exception("Users must be 18 or over");
  }
  if (userFirstName.length > 50 ||
      userLastName.length > 50 ||
      username.length > 15) {
    throw Exception("Input too long!");
  }
//username unique or not
  bool uniqueUsername = isUsernameUnique(username);
  if (!uniqueUsername) {
    throw Exception('Username is already taken. Please choose another one.');
  }

  try {
    User? user = auth.currentUser;
    if (user != null) {
      //updates user tbl
      await database.ref().child('Users').child(user.uid).update({
        'firstName': userFirstName,
        'lastName': userLastName,
        'DOB': userDOB.toIso8601String(),
        'course': userCourse,
        'university': userUniversity,
        'username': username,
      });
      // Update the Usernames table with the new username for quick lookup
      await database.ref().child('Usernames').child(username).set(user.uid);

      print('User data updated successfully!');
    } else {
      print('User not authenticated.');
    }
  } catch (e) {
    print('Error updating user data: $e');
    throw Exception('Failed to update user data.');
  }
}

bool isUsernameUnique(String username) {
  return true;
}
