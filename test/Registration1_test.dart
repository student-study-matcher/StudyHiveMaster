import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock FirebaseAuth and User classes
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

// Mock FirebaseDatabase, DatabaseReference, and other database-related classes
class MockFirebaseDatabase extends Mock implements FirebaseDatabase {}

class MockDatabaseReference extends Mock implements DatabaseReference {}

void main() {
  late MockFirebaseAuth auth;
  late MockFirebaseDatabase database;
  late MockDatabaseReference databaseRef;

  setUp(() {
    auth = MockFirebaseAuth();
    database = MockFirebaseDatabase();
    databaseRef = MockDatabaseReference();

    // Configure mock database interactions
    when(() => database.ref()).thenReturn(databaseRef);
    when(() => databaseRef.child(any())).thenReturn(databaseRef);
  });

  test('Missing email', () async {
    String password = 'password123';
    String confirmPassword = 'password123';

    expect(
          () async => await registerUser1(auth, databaseRef, '', password, confirmPassword),
      throwsA(isA<Exception>()),
    );
  });

  test('Valid email format, email is not in database already', () async {
    String email = 'testing@test.com';
    String password = 'password123';
    String confirmPassword = 'password123';

    when(() => auth.createUserWithEmailAndPassword(email: email, password: password))
        .thenAnswer((_) => Future.value(MockUserCredential()));

    await registerUser1(auth, databaseRef, email, password, confirmPassword);
  });

  test('Valid email format, email is already in database', () async {
    // Arrange
    final email = 'test@test.com';
    final password = 'password123';
    final confirmPassword = 'password123';

    // Mock FirebaseAuth to throw FirebaseAuthException when createUserWithEmailAndPassword is called
    when(() => auth.createUserWithEmailAndPassword(email: email, password: password))
        .thenThrow(Exception('The email address is already in use by another account.'));

    // Act & Assert
    await expectLater(
          () async => await registerUser1(auth, databaseRef, email, password, confirmPassword),
      throwsA(predicate<Exception>((e) => e.toString().contains('The email address is already in use by another account.'))),
    );

    // Verify that createUserWithEmailAndPassword method was called with the provided email and password
    verify(() => auth.createUserWithEmailAndPassword(email: email, password: password)).called(1);
  });

  test('Invalid email format, msg "Enter a valid email address"', () async {
    String email = 'invalidemail';
    String password = 'password123';
    String confirmPassword = 'password123';

    expect(
          () async => await registerUser1(auth, databaseRef, email, password, confirmPassword),
      throwsA(isA<Exception>()),
    );
  });

  test('Please enter a password', () async {
    String email = 'testing@test.com';
    String confirmPassword = 'password123';

    expect(
          () async => await registerUser1(auth, databaseRef, email, '', confirmPassword),
      throwsA(isA<Exception>()),
    );
  });

  test('Password must be at least 6 characters long', () async {
    String email = 'testing@test.com';
    String password = 'pass';
    String confirmPassword = 'pass';

    expect(
          () async => await registerUser1(auth, databaseRef, email, password, confirmPassword),
      throwsA(isA<Exception>()),
    );
  });

  test('The password don\'t match', () async {
    String email = 'testing@test.com';
    String password = 'password123';
    String confirmPassword = 'password1234';

    expect(
          () async => await registerUser1(auth, databaseRef, email, password, confirmPassword),
      throwsA(isA<Exception>()),
    );
  });

  test('Password match', () async {
    String email = 'testing@test.com';
    String password = 'password123';
    String confirmPassword = 'password123';

    when(() => auth.createUserWithEmailAndPassword(email: email, password: password))
        .thenAnswer((_) => Future.value(MockUserCredential()));

    await registerUser1(auth, databaseRef, email, password, confirmPassword);
  });

  test('Missing fields', () async {
    String email = '';
    String password = '';
    String confirmPassword = '';

    expect(
          () async => await registerUser1(auth, databaseRef, email, password, confirmPassword),
      throwsA(isA<Exception>()),
    );
  });

  test('Valid input', () async {
    String email = 'testing@test.com';
    String password = 'password123';
    String confirmPassword = 'password123';

    when(() => auth.createUserWithEmailAndPassword(email: email, password: password))
        .thenAnswer((_) => Future.value(MockUserCredential()));

    await registerUser1(auth, databaseRef, email, password, confirmPassword);
  });
}

class MockUserCredential extends Mock implements UserCredential {}

Future<void> registerUser1(FirebaseAuth auth, DatabaseReference databaseRef, String email, String password, String confirmPassword) async {
  if (email.isEmpty) {
    throw Exception('Missing email');
  }

  if (!isValidEmail(email)) {
    throw Exception('Invalid email format');
  }

  if (password.isEmpty) {
    throw Exception('Please enter a password');
  }

  if (password.length < 6) {
    throw Exception('Password must be at least 6 characters long');
  }

  if (password != confirmPassword) {
    throw Exception("The password don't match");
  }

  try {
    final newUser = await auth.createUserWithEmailAndPassword(email: email, password: password);
    if (newUser.user != null) {
      // Save user data to database
      await databaseRef.child('Users').child(newUser.user!.uid).set({'email': email});
    }
  } on FirebaseAuthException catch (e) {
    throw Exception(e.message ?? 'An unknown error occurred.');
  }
}

bool isValidEmail(String email) {
  final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  return emailRegex.hasMatch(email);
}