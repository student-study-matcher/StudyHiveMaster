import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock FirebaseAuth and User classes
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

// Mock FirebaseDatabase, DatabaseReference, and other database-related classes
class MockFirebaseDatabase extends Mock implements FirebaseDatabase {}

class MockDatabaseReference extends Mock implements DatabaseReference {}

class MockDatabaseEvent extends Mock implements DatabaseEvent {}

class MockDatabaseSnapshot extends Mock implements DataSnapshot {}

void main() {
  late MockFirebaseAuth auth;
  late MockFirebaseDatabase database;
  late MockDatabaseReference databaseRef;
  late MockDatabaseEvent databaseEvent;
  late MockDatabaseSnapshot databaseSnapshot;

  setUp(() {
    auth = MockFirebaseAuth();
    database = MockFirebaseDatabase();
    databaseRef = MockDatabaseReference();
    databaseEvent = MockDatabaseEvent();
    databaseSnapshot = MockDatabaseSnapshot();

    // Configure mock database interactions
    when(() => database.ref()).thenReturn(databaseRef);
    when(() => databaseRef.child(any())).thenReturn(databaseRef);
    when(() => databaseRef.once()).thenAnswer((_) async => databaseEvent);
    when(() => databaseEvent.snapshot).thenReturn(databaseSnapshot);
    when(() => databaseSnapshot.value).thenReturn(null);
  });

  test('Login with null email and password', () async {
    when(() => auth.signInWithEmailAndPassword(email: '', password: ''))
        .thenThrow(FirebaseAuthException(
      code: 'invalid-credentials',
      message: 'Enter an email and password to login',
    ));

    try {
      await auth.signInWithEmailAndPassword(email: '', password: '');
    } catch (e) {
      expect(e, isA<FirebaseAuthException>());
      expect((e as FirebaseAuthException).code, 'invalid-credentials');
      expect(e.message, 'Enter an email and password to login');
    }
  });

  test('Login with valid email and password', () async {
    when(() => auth.signInWithEmailAndPassword(
        email: 'test@test.com', password: 'password'))
        .thenAnswer((_) => Future.value(MockUserCredential()));

    final userCredential = await auth.signInWithEmailAndPassword(
        email: 'test@test.com', password: 'password');

    expect(userCredential, isA<MockUserCredential>());
  });

  test('Login with null email', () async {
    when(() => auth.signInWithEmailAndPassword(email: '', password: 'password'))
        .thenThrow(FirebaseAuthException(
      code: 'invalid-email',
      message: 'Enter an email and password to login',
    ));

    try {
      await auth.signInWithEmailAndPassword(email: '', password: 'password');
    } catch (e) {
      expect(e, isA<FirebaseAuthException>());
      expect((e as FirebaseAuthException).code, 'invalid-email');
      expect(e.message, 'Enter an email and password to login');
    }
  });

  test('Login with null password', () async {
    when(() => auth.signInWithEmailAndPassword(email: 'test@test.com', password: ''))
        .thenThrow(FirebaseAuthException(
      code: 'invalid-password',
      message: 'Enter an email and password to login',
    ));

    try {
      await auth.signInWithEmailAndPassword(email: 'test@test.com', password: '');
    } catch (e) {
      expect(e, isA<FirebaseAuthException>());
      expect((e as FirebaseAuthException).code, 'invalid-password');
      expect(e.message, 'Enter an email and password to login');
    }
  });

  test('Login with invalid email', () async {
    when(() => auth.signInWithEmailAndPassword(email: 'testt@test.com', password: 'password'))
        .thenThrow(FirebaseAuthException(
      code: 'invalid-email',
      message: 'Incorrect email or password',
    ));

    try {
      await auth.signInWithEmailAndPassword(email: 'testt@test.com', password: 'password');
    } catch (e) {
      expect(e, isA<FirebaseAuthException>());
      expect((e as FirebaseAuthException).code, 'invalid-email');
      expect(e.message, 'Incorrect email or password');
    }
  });

  test('Login with invalid password', () async {
    when(() => auth.signInWithEmailAndPassword(email: 'test@test.com', password: 'oassword'))
        .thenThrow(FirebaseAuthException(
      code: 'wrong-password',
      message: 'Incorrect email or password',
    ));

    try {
      await auth.signInWithEmailAndPassword(email: 'test@test.com', password: 'oassword');
    } catch (e) {
      expect(e, isA<FirebaseAuthException>());
      expect((e as FirebaseAuthException).code, 'wrong-password');
      expect(e.message, 'Incorrect email or password');
    }
  });
}
class MockUserCredential extends Mock implements UserCredential {}

// Mock LoginState class
class _LoginState {
  final FirebaseAuth auth;
  String errorMessage = '';

  _LoginState({required this.auth});

  Future<void> signIn() async {
    try {
      await auth.signInWithEmailAndPassword(email: 'test@test.com', password: 'password');
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message ?? 'An unknown error occurred.';
    }
  }
}
