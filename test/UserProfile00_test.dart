import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockDatabase extends Mock implements FirebaseDatabase {}

class MockDatabaseRef extends Mock implements DatabaseReference {}

class MockDatabaseSnapshot extends Mock implements DataSnapshot {}

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  late MockFirebaseAuth auth;
  late MockDatabase database;
  late MockDatabaseRef databaseRef;
  late MockBuildContext context;

  setUpAll(() async {
    auth = MockFirebaseAuth();
    database = MockDatabase();
    databaseRef = MockDatabaseRef();
    context = MockBuildContext();

    when(() => database.ref()).thenReturn(databaseRef);
    when(() => databaseRef.child(any())).thenReturn(databaseRef);
    when(() => databaseRef.update(any())).thenAnswer((_) async {});
    when(() => databaseRef.get()).thenAnswer((_) async => MockDatabaseSnapshot());
  });

  group('User Profile', () {
    print('Test Start: View Others Profile');
    test('Fetch friends data', () async {
      final userId = '123';
      await fetchFriendsData(
        database: database,
        userId: userId,
      );
      verify(() => databaseRef.child('Users/123').get()).called(1);
      print('Test Passed: View Others Profile');
    });

    test('Update user name in database', () async {
      print('Test Start: Edit Profile');
      // Arrange
      final firstName = 'John';
      final lastName = 'Doe';

      await updateNameInDatabase(
        database: database,
        firstName: firstName,
        lastName: lastName,
      );

      verify(() => databaseRef.child('Users/123').update({
        'firstName': firstName,
        'lastName': lastName,
      })).called(1);
    });

    test('Edit user bio in database', () async {
      // Arrange
      final bio = 'New bio';

      await editBioInDatabase(
        database: database,
        bio: bio,
      );

      verify(() => databaseRef.child('Users/123').update({
        'bio': bio,
      })).called(1);
      print('Test Passed: Edit Profile');
    });
  });
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
