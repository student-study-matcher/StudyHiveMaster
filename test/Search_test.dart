import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';// Import the mocktail package

// Mock classes
class MockFirebaseDatabase extends Mock implements FirebaseDatabase {}
class MockDatabaseReference extends Mock implements DatabaseReference {}
class MockDatabaseEvent extends Mock implements DatabaseEvent {}
class MockDataSnapshot extends Mock implements DataSnapshot {}

void main() {
  // Initialize the mocks
  late MockFirebaseDatabase mockDatabase;
  late MockDatabaseReference mockDatabaseRef;
  late MockDatabaseEvent mockDatabaseEvent;
  late MockDataSnapshot mockDataSnapshot;

  setUp(() {
    mockDatabase = MockFirebaseDatabase();
    mockDatabaseRef = MockDatabaseReference();
    mockDatabaseEvent = MockDatabaseEvent();
    mockDataSnapshot = MockDataSnapshot();

    // Ensure that mockDatabase returns mockDatabaseRef when reference() is called
    when(() => mockDatabase.reference()).thenReturn(mockDatabaseRef);
  });

  test('User searches for forums - subject: "Computer Science"', () async {
    String searchQuery = 'Computer Science'; // Input

    // Mock the database response for forum search
    final mockSnapshot = MockDataSnapshot();
    when(() => mockDatabaseRef.child('Forums')).thenReturn(mockDatabaseRef);
    when(() => mockDatabaseRef.once()).thenAnswer((_) async => mockDatabaseEvent); // Return DatabaseEvent

    await performForumSearch(mockDatabase, searchQuery); // Perform forum search operation

    // Verify that the database query is called once
    verify(() => mockDatabaseRef.child('Forums')).called(1);
    verify(() => mockDatabaseRef.once()).called(1);
  });

  test('User searches for forums - null search query', () async {
    String? searchQuery = null; // Input

    // Mock the database response for forum search
    when(() => mockDatabaseRef.child('Forums')).thenReturn(mockDatabaseRef);
    when(() => mockDatabaseRef.once()).thenAnswer((_) async => mockDatabaseEvent); // Return DataSnapshot

    await performForumSearch(mockDatabase, searchQuery); // Perform forum search operation

    // Verify that the database query is called once
    verify(() => mockDatabaseRef.child('Forums')).called(1);
    verify(() => mockDatabaseRef.once()).called(1);
  });

  test('User searches for forums - invalid search query: "1234"', () async {
    String searchQuery = '123456'; // Input

    // Mock the database response for forum search
    when(() => mockDatabaseRef.child('Forums')).thenReturn(mockDatabaseRef);
    when(() => mockDatabaseRef.once()).thenAnswer((_) async => mockDatabaseEvent); // Return DataSnapshot

    await performForumSearch(mockDatabase, searchQuery); // Perform forum search operation

    // Verify that the database query is called once
    verify(() => mockDatabaseRef.child('Forums')).called(1);
    verify(() => mockDatabaseRef.once()).called(1);
  });
  test('User searches for users - username: "Billy"', () async {
    String searchQuery = 'Billy'; // Input

    // Mock the database response for user search
    final mockSnapshot = MockDataSnapshot();
    when(() => mockDatabaseRef.child('Users')).thenReturn(mockDatabaseRef);
    when(() => mockDatabaseRef.once()).thenAnswer((_) async => mockDatabaseEvent);

    await performUserSearch(mockDatabase, searchQuery); // Perform user search operation

    // Verify that the database query is called once
    verify(() => mockDatabaseRef.child('Users')).called(1);
    verify(() => mockDatabaseRef.once()).called(1);
  });

  test('User searches for users - null search query', () async {
    String? searchQuery = null; // Input

    // Mock the database response for user search
    when(() => mockDatabaseRef.child('Users')).thenReturn(mockDatabaseRef);
    when(() => mockDatabaseRef.once()).thenAnswer((_) async => mockDatabaseEvent);

    await performUserSearch(mockDatabase, searchQuery); // Perform user search operation

    // Verify that the database query is called once
    verify(() => mockDatabaseRef.child('Users')).called(1);
    verify(() => mockDatabaseRef.once()).called(1);
  });

  test('User searches for users - invalid search query: "Testusername22456"', () async {
    String searchQuery = 'Testusername22456'; // Input

    // Mock the database response for user search
    when(() => mockDatabaseRef.child('Users')).thenReturn(mockDatabaseRef);
    when(() => mockDatabaseRef.once()).thenAnswer((_) async => mockDatabaseEvent);

    await performUserSearch(mockDatabase, searchQuery); // Perform user search operation

    // Verify that the database query is called once
    verify(() => mockDatabaseRef.child('Users')).called(1);
    verify(() => mockDatabaseRef.once()).called(1);
  });

  test('User searches for groupchats - name: "ComputerScience2024"', () async {
    String searchQuery = 'ComputerScience2024'; // Input

    // Mock the database response for groupchat search
    final mockSnapshot = MockDataSnapshot();
    when(() => mockDatabaseRef.child('Groupchats')).thenReturn(mockDatabaseRef);
    when(() => mockDatabaseRef.once()).thenAnswer((_) async => mockDatabaseEvent);

    await performGroupchatSearch(mockDatabase, searchQuery); // Perform groupchat search operation

    // Verify that the database query is called once
    verify(() => mockDatabaseRef.child('Groupchats')).called(1);
    verify(() => mockDatabaseRef.once()).called(1);
  });

  test('User searches for groupchats - null search query', () async {
    String? searchQuery = null; // Input

    // Mock the database response for groupchat search
    when(() => mockDatabaseRef.child('Groupchats')).thenReturn(mockDatabaseRef);
    when(() => mockDatabaseRef.once()).thenAnswer((_) async => mockDatabaseEvent);

    await performGroupchatSearch(mockDatabase, searchQuery); // Perform groupchat search operation

    // Verify that the database query is called once
    verify(() => mockDatabaseRef.child('Groupchats')).called(1);
    verify(() => mockDatabaseRef.once()).called(1);
  });

  test('User searches for groupchats - invalid search query: "Groupchat2243298"', () async {
    String searchQuery = 'Groupchat2243298'; // Input

    // Mock the database response for groupchat search
    when(() => mockDatabaseRef.child('Groupchats')).thenReturn(mockDatabaseRef);
    when(() => mockDatabaseRef.once()).thenAnswer((_) async => mockDatabaseEvent);

    await performGroupchatSearch(mockDatabase, searchQuery); // Perform groupchat search operation

    // Verify that the database query is called once
    verify(() => mockDatabaseRef.child('Groupchats')).called(1);
    verify(() => mockDatabaseRef.once()).called(1);
  });

}

Future<DatabaseEvent> performForumSearch(FirebaseDatabase database, String? searchQuery) async {
  // Mock the data retrieval
  DatabaseReference ref = database.reference();
  return await ref.child('Forums').once().then((snapshot) => snapshot as DatabaseEvent);
}

Future<DataSnapshot> performUserSearch(FirebaseDatabase database, String? username) async {
  // Mock the data retrieval
  DatabaseReference ref = database.reference();
  return await ref.child('Users').once().then((snapshot) => snapshot as DataSnapshot);
}

Future<DataSnapshot> performGroupchatSearch(FirebaseDatabase database, String? groupchatName) async {
  // Mock the data retrieval
  DatabaseReference ref = database.reference();
  return await ref.child('Groupchats').once().then((snapshot) => snapshot as DataSnapshot);
}
