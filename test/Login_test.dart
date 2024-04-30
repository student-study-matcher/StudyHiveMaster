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

  testWidgets('Your test description', (WidgetTester tester) async {
    print("Success!");
// Test code
  });

  test('login with email and password', () async {
    when(() =>
        auth.signInWithEmailAndPassword(
            email: 'test@example.com', password: 'password'))
        .thenAnswer((_) => Future.value(MockUserCredential()));

    expect(
        await auth.signInWithEmailAndPassword(
            email: 'test@example.com', password: 'password'),
        isA<MockUserCredential>());

  });
  test('Login with incorrect password', () async {
    // Mocking the signInWithEmailAndPassword method to throw FirebaseAuthException
    when(() => auth.signInWithEmailAndPassword(
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
  });
  test('Send password reset email with incorrect email', () async {
    // Mocking the sendPasswordResetEmail method to throw FirebaseAuthException
    when(() => auth.sendPasswordResetEmail(
      email: any(named: 'email'),
    )).thenThrow(FirebaseAuthException(
      code: 'user-not-found',
      message: 'There is no user record corresponding to this identifier. The user may have been deleted.',
    ));

    // Simulate sending password reset email with incorrect email
    try {
      await sendPasswordResetEmail(auth);
    } catch (e) {
      // Verify that the FirebaseAuthException is thrown with the correct message
      expect(e, isA<FirebaseAuthException>());
      expect((e as FirebaseAuthException).code, 'user-not-found');
      expect(e.message, 'There is no user record corresponding to this identifier. The user may have been deleted.');
    }
  });
}

Future<void> sendPasswordResetEmail(MockFirebaseAuth auth) async {
  await auth.sendPasswordResetEmail(
    email: 'nonexistent@example.com',
  );
}
