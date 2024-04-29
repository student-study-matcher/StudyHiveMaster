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
}
