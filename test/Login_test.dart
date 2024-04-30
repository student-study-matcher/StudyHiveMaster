import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {
  @override
  User get user => MockUser();
}

void main() {
  late MockFirebaseAuth auth;

  setUp(() async {
    auth = MockFirebaseAuth();
  });

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
    // Mocking the signInWithEmailAndPassword method to throw FirebaseAuthException
    when(() =>
        auth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        )).thenThrow(FirebaseAuthException(
      code: 'wrong-password',
      message: 'The password is invalid',
    ));

    // Simulate the login attempt
    try {
      await auth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'incorrect_password',
      );
    } catch (e) {
      // Verify that the FirebaseAuthException is thrown with the correct message
      expect(e, isA<FirebaseAuthException>());
      expect((e as FirebaseAuthException).code, 'wrong-password');
      expect(e.message, 'The password is invalid');
    }
    print('Test Passed: User Input Incorrrect Password');
  });

}
