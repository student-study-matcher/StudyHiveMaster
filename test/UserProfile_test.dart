import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

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

class MockBuildContext extends Mock implements BuildContext {}

void main() async {
  late MockFirebaseAuth auth;
  late MockDatabase database;
  late MockDatabaseRef databaseRef;
  late MockDatabaseEvent databaseEvent;
  late MockDatabaseSnapshot databaseSnapshot;
  late MockBuildContext context;

  setUpAll(() async {
    auth = MockFirebaseAuth();
    database = MockDatabase();
    databaseRef = MockDatabaseRef();
    databaseEvent = MockDatabaseEvent();
    databaseSnapshot = MockDatabaseSnapshot();
    context = MockBuildContext();

    when(() => database.ref()).thenReturn(databaseRef);
    when(() => databaseRef.child(any())).thenReturn(databaseRef);
    when(() => databaseRef.update(any())).thenAnswer((_) async {});
    when(() => databaseRef.get()).thenAnswer((_) async => databaseSnapshot);

    when(() => auth.currentUser).thenReturn(MockUser());

    when(() => databaseRef.set(any())).thenAnswer((_) async => {});
    when(() => databaseRef.once()).thenAnswer((_) async => databaseEvent);
    when(() => databaseEvent.snapshot).thenReturn(databaseSnapshot);
    when(() => databaseSnapshot.value).thenReturn(null);
  });

  group('User Login', () {
    test('login with email and password', () async {
      print('Test Start: User Login With Email and Password');
      when(() =>
          auth.signInWithEmailAndPassword(
              email: 'test@example.com', password: 'password'))
          .thenAnswer((_) => Future.value(MockUserCredential()));

      expect(
          await auth.signInWithEmailAndPassword(
              email: 'test@example.com', password: 'password'),
          isA<MockUserCredential>());
      print('Test Passed: User Login With Email and Password');
    });

    test('Login with incorrect password', () async {
      print('Test Start: User Input Incorrrect Password');
      when(() =>
          auth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ))
          .thenThrow(FirebaseAuthException(
        code: 'wrong-password',
        message: 'The password is invalid',
      ));

      try {
        await auth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'incorrect_password',
        );
      } catch (e) {
        expect(e, isA<FirebaseAuthException>());
        expect((e as FirebaseAuthException).code, 'wrong-password');
        expect(e.message, 'The password is invalid');
      }
      print('Test Passed: User Input Incorrrect Password');
    });
  });

  group('Registration Tests', () {
    print('Test Start: User Registration');
    test('register user successfully step 1', () async {
      String email = 'ex@example.com';
      String password = 'password123';

      when(() => auth.createUserWithEmailAndPassword(
          email: email, password: password))
          .thenAnswer((invocation) => Future.value(MockUserCredential()));

      await registerUser1(auth, databaseRef, email, password, password);

      verify(() => auth.createUserWithEmailAndPassword(
          email: email, password: password))
          .called(1);
    });

    test('register user with already used email', () async {
      print('Test Start: User inputs already registered email');
      String email = 'wrong@email.com';
      String password = 'password123';

      when(() => auth.createUserWithEmailAndPassword(
          email: email, password: password))
          .thenThrow(FirebaseAuthException(
        code: 'email-already-in-use',
        message: 'The email address is already in use by another account.',
      ));

      expect(
              () async => await registerUser1(
              auth, databaseRef, email, password, password),
          throwsException);
      print('Test Passed: User inputs already registered email');
    });

    test('registration step 2', () async {
      await registerUser2(
          auth, database, 'John', 'Doe', '1990-01-01', 'johndoe', 'Computer Science', 'University of Example');

      verify(() => databaseRef.update(any())).called(1);
    });

    test('user registers with invalid username length', () async {
      print('Test Start: User input incorrect information');
      expect(
              () async => await registerUser2(auth, database, 'John', 'Doe',
              '2000-03-15', 'j', 'Computer Science', 'University of Example'),
          throwsException);
      print('Test Passed: User input incorrect information');
    });

    test('register with age under 18', () async {
      print('Test Start: User register with age under 18');
      expect(
              () async => await registerUser2(auth, database, 'John', 'Doe',
              '2020-03-15', 'johndoe', 'Computer Science', 'University of Example'),
          throwsException);
      print('Test Passed: User register with age under 18');
    });

    test('registration part 3', () async {
      await saveBio(auth, databaseRef, 'Hello, world!', 'profilePic.jpg');

      verify(() => databaseRef.child('Users/123/bio').set('Hello, world!'))
          .called(1);
      print('Test Start: Edit Profile Picture');
      verify(() => databaseRef.child('Users/123/profilePic').set('profilePic.jpg'))
          .called(1);
      print('Test Passed: Edit Profile Picture');
    });
    print('Test Passed: User Registration');
  });

  group('User Profile', () {
    test('Fetch friends data', () async {
      print('Test Start: View Others Profile');
      final userId = '123';
      await fetchFriendsData(database: database, userId: userId);
      verify(() => databaseRef.child('Users/123').get()).called(1);
      print('Test Passed: View Others Profile');
    });

    test('Update user name in database', () async {
      print('Test Start: Edit Profile');
      final firstName = 'John';
      final lastName = 'Doe';

      await updateNameInDatabase(
          database: database, firstName: firstName, lastName: lastName);

      verify(() => databaseRef.child('Users/123').update({
        'firstName': firstName,
        'lastName': lastName,
      })).called(1);
    });

    test('Edit user bio in database', () async {
      final bio = 'New bio';

      await editBioInDatabase(database: database, bio: bio);

      verify(() => databaseRef.child('Users/123').update({
        'bio': bio,
      })).called(1);
      print('Test Passed: Edit Profile');
    });
  });
}

Future<void> registerUser1(
    MockFirebaseAuth auth,
    MockDatabaseRef database,
    String email,
    String password,
    String confirmPassword) async {
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
    throw Exception("Users must be 18 or over");
  }
  if (userFirstName.length > 50 ||
      userLastName.length > 50 ||
      username.length > 15) {
    throw Exception("Input too long!");
  }

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
      await database.ref().child('Users').child(user.uid).update({
        'firstName': userFirstName,
        'lastName': userLastName,
        'DOB': userDOB.toIso8601String(),
        'course': userCourse,
        'university': userUniversity,
        'username': username,
      });
      await database.ref().child('Usernames').child(username).set(user.uid);
    }
  } catch (e) {
    print('Error updating user data: $e');
    throw Exception('Failed to update user data.');
  }
}

Future<bool> isUsernameUnique(MockDatabase database, String username) async {
  final event =
  await database.ref().child('Usernames').child(username).once();
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
    usernameError = 'Only letters, numbers, hyphens, and underscores are allowed';
  } else {
    usernameError = null;
  }
  if (usernameError != null) {
    throw Exception(usernameError);
  }
}

Future<void> saveBio(
    MockFirebaseAuth auth, MockDatabaseRef databaseReference, String bioText, String profilePic) async {
  User? user = auth.currentUser;
  if (user != null) {
    await databaseReference.child('Users/${user.uid}/bio').set(bioText);
    await databaseReference.child('Users/${user.uid}/profilePic').set(profilePic);
  }
}

Future<void> fetchFriendsData({
  required MockDatabase database,
  required String userId,
}) async {
  await database.ref().child('Users/$userId').get();
}

Future<void> updateNameInDatabase({
  required MockDatabase database,
  required String firstName,
  required String lastName,
}) async {
  await database.ref().child('Users/123').update({
    'firstName': firstName,
    'lastName': lastName,
  });
}

Future<void> editBioInDatabase({
  required MockDatabase database,
  required String bio,
}) async {
  await database.ref().child('Users/123').update({
    'bio': bio,
  });
}
