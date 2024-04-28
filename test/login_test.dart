import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUserCredential extends Mock implements UserCredential {}
class MockUser extends Mock implements User {}

class AuthManager {
  final FirebaseAuth auth;

  AuthManager(this.auth);

  Future<bool> signIn(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      return false;
    }
  }
}

void main() {
  late MockFirebaseAuth mockAuth;
  late AuthManager authManager;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    authManager = AuthManager(mockAuth);

    // Set up mock responses
    when(() => mockAuth.signInWithEmailAndPassword(
      email: any(named: 'email'),
      password: any(named: 'password'),
    )).thenAnswer((_) async => MockUserCredential());
  });

  test('Successful login returns true', () async {
    print('Starting test: Successful login returns true');
    final result = await authManager.signIn('testtin2@gmail.com', '111111');
    expect(result, isTrue);
    print('Test passed: Successful login with correct credentials');
  });

  test('Failed login returns false', () async {
    print('Starting test: Failed login returns false');
    when(() => mockAuth.signInWithEmailAndPassword(
      email: any(named: 'email'),
      password: any(named: 'password'),
    )).thenThrow(FirebaseAuthException(code: 'auth/failed', message: 'Test Failure'));

    final result = await authManager.signIn('testtin2@gmail.com', '111111');
    expect(result, isFalse);
    print('Test failed: Login attempt with incorrect credentials');
  });
}
