import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockDatabaseReference extends Mock implements DatabaseReference {}

void main() {
  late MockFirebaseAuth auth;
  late MockDatabaseReference databaseRef;

  setUp(() {
    auth = MockFirebaseAuth();
    databaseRef = MockDatabaseReference();
  });

  test('Null profile picture', () async {
    expect(() => saveProfilePicture(null), throwsA(isA<Exception>()));
  });

  test('Valid profile picture', () async {
    expect(() => saveProfilePicture('picture1.jpg'), returnsNormally);
  });

  test('Valid bio', () async {
    expect(() => validateBio(null), throwsA(isA<Exception>()));
    expect(() => validateBio('Hello'), returnsNormally);
  });

  test('Bio with 256 characters', () async {
    final longBio = 'a' * 256;
    expect(() => validateBio(longBio), throwsA(isA<Exception>()));
  });
}

void saveProfilePicture(String? profilePic) {
  if (profilePic == null || profilePic.isEmpty) {
    throw Exception('Select one of the given profile pictures');
  }
}

void validateBio(String? bio) {
  if (bio == null) {
    throw Exception('Bio cannot be null');
  }

  if (bio.length > 255) {
    throw Exception('Bio must be up to 255 characters');
  }
}
