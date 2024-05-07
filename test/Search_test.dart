import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart'; // Import the mocktail package

class MockFirebaseDatabase extends Mock implements FirebaseDatabase {}
class MockDatabaseReference extends Mock implements DatabaseReference {}
class MockDatabaseEvent extends Mock implements DatabaseEvent {}
class MockDataSnapshot extends Mock implements DataSnapshot {}

void main() {
  late MockFirebaseDatabase mockDatabase;
  late MockDatabaseReference mockDatabaseRef;
  late MockDatabaseEvent mockDatabaseEvent;
  late MockDataSnapshot mockDataSnapshot;

  setUp(() {
    mockDatabase = MockFirebaseDatabase();
    mockDatabaseRef = MockDatabaseReference();
    mockDatabaseEvent = MockDatabaseEvent();
    mockDataSnapshot = MockDataSnapshot();

    when(() => mockDatabase.reference()).thenReturn(mockDatabaseRef);
    when(() => mockDatabaseRef.child(any())).thenReturn(mockDatabaseRef);
    when(() => mockDatabaseRef.once()).thenAnswer((_) async => mockDatabaseEvent);
    when(() => mockDatabaseEvent.snapshot).thenReturn(mockDataSnapshot);
  });

  test('User searches for forums - subject: "Computer Science"', () async {
    String searchQuery = 'Computer Science'; // Input
    await performForumSearch(mockDatabase, searchQuery); // Perform forum search operation
    verify(() => mockDatabaseRef.child('Forums')).called(1);
    verify(() => mockDatabaseRef.once()).called(1);
  });

  test('User searches for forums - null search query', () async {
    String? searchQuery = null; // Input
    await performForumSearch(mockDatabase, searchQuery); // Perform forum search operation
    verify(() => mockDatabaseRef.child('Forums')).called(1);
    verify(() => mockDatabaseRef.once()).called(1);
  });

  test('User searches for forums - invalid search query: "123456"', () async {
    String searchQuery = '123456'; // Input
    await performForumSearch(mockDatabase, searchQuery); // Perform forum search operation
    verify(() => mockDatabaseRef.child('Forums')).called(1);
    verify(() => mockDatabaseRef.once()).called(1);
  });

  test('User searches for users - username: "Billy"', () async {
    String searchQuery = 'Billy'; // Input
    await performUserSearch(mockDatabase, searchQuery); // Perform user search operation
    verify(() => mockDatabaseRef.child('Users')).called(1);
    verify(() => mockDatabaseRef.once()).called(1);
  });

  test('User searches for users - null search query', () async {
    String? searchQuery = null; // Input
    await performUserSearch(mockDatabase, searchQuery); // Perform user search operation
    verify(() => mockDatabaseRef.child('Users')).called(1);
    verify(() => mockDatabaseRef.once()).called(1);
  });

  test('User searches for users - invalid search query: "Testusername22456"', () async {
    String searchQuery = 'Testusername22456'; // Input
    await performUserSearch(mockDatabase, searchQuery); // Perform user search operation
    verify(() => mockDatabaseRef.child('Users')).called(1);
    verify(() => mockDatabaseRef.once()).called(1);
  });

  test('User searches for groupchats - name: "ComputerScience2024"', () async {
    String searchQuery = 'ComputerScience2024'; // Input
    await performGroupchatSearch(mockDatabase, searchQuery); // Perform groupchat search operation
    verify(() => mockDatabaseRef.child('Groupchats')).called(1);
    verify(() => mockDatabaseRef.once()).called(1);
  });

  test('User searches for groupchats - null search query', () async {
    String? searchQuery = null; // Input
    await performGroupchatSearch(mockDatabase, searchQuery); // Perform groupchat search operation
    verify(() => mockDatabaseRef.child('Groupchats')).called(1);
    verify(() => mockDatabaseRef.once()).called(1);
  });

  test('User searches for groupchats - invalid search query: "Groupchat2243298"', () async {
    String searchQuery = 'Groupchat2243298'; // Input
    await performGroupchatSearch(mockDatabase, searchQuery); // Perform groupchat search operation
    verify(() => mockDatabaseRef.child('Groupchats')).called(1);
    verify(() => mockDatabaseRef.once()).called(1);
  });
}

Future<DatabaseEvent> performForumSearch(FirebaseDatabase database, String? searchQuery) async {
  DatabaseReference ref = database.reference();
  return await ref.child('Forums').once();
}

Future<DataSnapshot> performUserSearch(FirebaseDatabase database, String? username) async {
  DatabaseReference ref = database.reference();
  DatabaseEvent event = await ref.child('Users').once();
  return event.snapshot;
}

Future<DataSnapshot> performGroupchatSearch(FirebaseDatabase database, String? groupchatName) async {
  DatabaseReference ref = database.reference();
  DatabaseEvent event = await ref.child('Groupchats').once();
  return event.snapshot;
}
