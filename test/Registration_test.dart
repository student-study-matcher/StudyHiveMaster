import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';


class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockDatabase extends Mock implements FirebaseDatabase {}

class MockDatabaseRef extends Mock implements DatabaseReference {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockDatabaseEvent extends Mock implements DatabaseEvent {}

class MockDatabaseSnapshot extends Mock implements DataSnapshot {}

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
  late MockDatabase database;
  late MockDatabaseRef databaseRef;
  late MockDatabaseEvent databaseEvent;
  late MockDatabaseSnapshot databaseSnapshot;

  setUpAll(() async {
    auth = MockFirebaseAuth();
    database = MockDatabase();
    databaseRef = MockDatabaseRef();
    databaseEvent = MockDatabaseEvent();
    databaseSnapshot = MockDatabaseSnapshot();

    when(() => databaseRef.child(any())).thenReturn(databaseRef);
    when(() => databaseRef.child(any()).child(any())).thenReturn(databaseRef);

    when(() => databaseRef.set(any())).thenAnswer((_) async => {});

    when(() => database.ref()).thenReturn(databaseRef);

    when(() => auth.currentUser).thenReturn(MockUser());

    when(() => databaseRef.update(any())).thenAnswer((_) async => {});
  });

  group('registration tests', () {
    print('Test Start: User Registration');
    test('register user successfully step 1', () async {

      String email = 'ex@example.com';
      String password = 'password123';

      when(() => auth.createUserWithEmailAndPassword(
          email: email, password: password))
          .thenAnswer((invocation) => Future.value(MockUserCredential()));

      await registerUser1(auth, databaseRef, email, password, password);

      verify(() => auth.createUserWithEmailAndPassword(
          email: email, password: password)).called(1);
    });

    test('register user with already used email', () async {
      print('Test Started: User inputs already registered email');
      String email = 'wrong@email.com';
      String password = 'password123';

      when(() =>
          auth.createUserWithEmailAndPassword(
              email: email,
              password: password)).thenThrow(FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'The email address is already in use by another account.'));

      expect(
              () async =>
          await registerUser1(auth, databaseRef, email, password, password),
          throwsException);
      print('Test Passed: User inputs already registered email');
    });

    test('registration step 2', () async {
      when(() => databaseRef.once()).thenAnswer((_) async => databaseEvent);

      when(() => databaseEvent.snapshot).thenReturn(databaseSnapshot);
      when(() => databaseSnapshot.value).thenReturn(null);

      await registerUser2(auth, database, 'John', 'Doe', '1990-01-01',
          'johndoe', 'Computer Science', 'University of Example');

      verify(() => databaseRef.update(any())).called(1);
    });

    test('user registers with invalid username length', () async {
      print('Test Start: User input incorrect information');
      when(() => databaseRef.once()).thenAnswer((_) async => databaseEvent);

      when(() => databaseEvent.snapshot).thenReturn(databaseSnapshot);
      when(() => databaseSnapshot.value).thenReturn('123');

      expect(
              () async => await registerUser2(auth, database, 'John', 'Doe',
              '2000-03-15', 'j', 'Computer Science', 'University of Example'),
          throwsException);
      print('Test Passed: User input incorrect information');
    });

    test('register with age under 18', () async {
      print('Test Started: User register with age under 18');
      when(() => databaseRef.once()).thenAnswer((_) async => databaseEvent);

      when(() => databaseEvent.snapshot).thenReturn(databaseSnapshot);
      when(() => databaseSnapshot.value).thenReturn('123');

      expect(
              () async => await registerUser2(
              auth,
              database,
              'John',
              'Doe',
              '2020-03-15',
              'johndoe',
              'Computer Science',
              'University of Example'),
          throwsException);
      print('Test Passed: User register with age under 18');
    });

    test('registration part 3', () async {
      await saveBio(auth, databaseRef, 'Hello, world!', 'profilePic.jpg');

      verify(() => databaseRef.child('Users/123/bio').set('Hello, world!'))
          .called(1);
      print('Test Start: Edit Profile Picture');
      verify(() =>
          databaseRef.child('Users/123/profilePic').set('profilePic.jpg'))
          .called(1);
      print('Test Passed: Edit Profile Picture');
    });
    print('Test Passed: User Registration');
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
  bool uniqueUsername = await isUsernameUnique(database, username);
  if (!uniqueUsername) {
    throw Exception('Username is already taken. Please choose another one.');
  }

  if (username.length < 3) {
    throw Exception('Username too short');
  }
  if (username.length > 15) {
    throw Exception("Username too long");
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

    } else {

    }
  } catch (e) {
    print('Error updating user data: $e');
    throw Exception('Failed to update user data.');
  }
}

Future<bool> isUsernameUnique(MockDatabase database, String username) async {
  final event = await database.ref().child('Usernames').child(username).once();
  final snapshot = event.snapshot;
  return snapshot.value == null;
}

void validateUsername(String value) {
  String? usernameError = '';
  if (value.isEmpty) {
    usernameError = 'Username cannot be empty';
  } else if (value.length < 3 || value.length > 15) {
    usernameError = 'Username must be between 3 and 15 characters';
  } else if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(value)) {
    usernameError =
    'Only letters, numbers, hyphens, and underscores are allowed';
  } else {
    usernameError = null;
  }
  if (usernameError != null) {
    throw Exception(usernameError);
  }
}

Future<void> saveBio(MockFirebaseAuth auth, MockDatabaseRef databaseReference,
    String bioText, String profilePic) async {
  User? user = auth.currentUser;
  if (user != null) {
    await databaseReference.child('Users/${user.uid}/bio').set(bioText);
    await databaseReference
        .child('Users/${user.uid}/profilePic')
        .set(profilePic);
  }
}
