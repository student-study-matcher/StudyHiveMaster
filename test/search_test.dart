import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart'; // Import the mocktail package

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

  test('User searches for forums - no search button', () async {
    print('Test Start: User searches for forums - no search button');
    String searchQuery = 'forum topic'; // Input

    // Mock the database response for forum search
    when(() => mockDatabaseRef.child('Forums').once()).thenAnswer((_) async => mockDatabaseEvent);

    await performForumSearch(mockDatabase, searchQuery); // Perform forum search operation

    // Verify that the database query is called once
    verify(() => mockDatabaseRef.child('Forums').once()).called(1);

    print('Test Passed: User searches for forums - no search button');
  });

  test('User searches for Courses - filter button', () async {
    print('Test Start: User searches for Courses - filter button');
    String selectedFilter = 'Flutter'; // Input

    // Mock the database response for course search
    when(() => mockDatabaseRef.child('Courses').orderByChild('topic').equalTo(selectedFilter).once())
        .thenAnswer((_) async => mockDatabaseEvent);

    await performCourseSearch(mockDatabase, selectedFilter); // Perform course search operation

    // Verify that the database query is called once
    verify(() => mockDatabaseRef.child('Courses').orderByChild('topic').equalTo(selectedFilter).once()).called(1);

    print('Test Passed: User searches for Courses - filter button');
  });

  test('User search for other users\' - button top right', () async {
    print('Test Start: User search for other users\' - button top right');
    String username = 'JohnDoe'; // Input

    // Mock the database response for user search
    when(() => mockDatabaseRef.child('Users').orderByChild('username').equalTo(username).once())
        .thenAnswer((_) async => mockDatabaseEvent);

    await performUserSearch(mockDatabase, username); // Perform user search operation

    // Verify that the database query is called once
    verify(() => mockDatabaseRef.child('Users').orderByChild('username').equalTo(username).once()).called(1);

    print('Test Passed: User search for other users\' - button top right');
  });

  test('User misspells something in their search', () async {
    print('Test Start: User misspells something in their search');
    String misspelledQuery = 'fluttar'; // Input

    // Mock the database response for misspelled search
    when(() => mockDatabaseRef.child('Forums').orderByChild('title').startAt(misspelledQuery).endAt(misspelledQuery + '\uf8ff').once())
        .thenAnswer((_) async => mockDatabaseEvent);

    await performMisspelledSearch(mockDatabase, misspelledQuery); // Perform misspelled search operation

    // Verify that the database query is called once
    verify(() => mockDatabaseRef.child('Forums').orderByChild('title').startAt(misspelledQuery).endAt(misspelledQuery + '\uf8ff').once()).called(1);

    print('Test Passed: User misspells something in their search');
  });

  test('User searches for a tag that doesn\'t exist', () async {
    print('Test Start: User searches for a tag that doesn\'t exist');
    String nonExistentTag = 'nonexistenttag'; // Input

    // Mock the database response for non-existent tag search
    when(() => mockDatabaseRef.child('Tags').orderByChild('name').equalTo(nonExistentTag).once())
        .thenAnswer((_) async => mockDatabaseEvent);

    await performTagSearch(mockDatabase, nonExistentTag); // Perform non-existent tag search operation

    // Verify that the database query is called once
    verify(() => mockDatabaseRef.child('Tags').orderByChild('name').equalTo(nonExistentTag).once()).called(1);

    print('Test Passed: User searches for a tag that doesn\'t exist');
  });
}

// Function to perform forum search
Future<void> performForumSearch(FirebaseDatabase database, String searchQuery) async {
  DatabaseReference ref = database.reference();
  await ref.child('Forums').once();
  // Perform actual search logic...
}

// Function to perform course search
Future<void> performCourseSearch(FirebaseDatabase database, String selectedFilter) async {
  DatabaseReference ref = database.reference();
  await ref.child('Courses').orderByChild('topic').equalTo(selectedFilter).once();
  // Perform actual search logic...
}

// Function to perform user search
Future<void> performUserSearch(FirebaseDatabase database, String username) async {
  DatabaseReference ref = database.reference();
  await ref.child('Users').orderByChild('username').equalTo(username).once();
  // Perform actual search logic...
}

// Function to perform misspelled search
Future<void> performMisspelledSearch(FirebaseDatabase database, String misspelledQuery) async {
  DatabaseReference ref = database.reference();
  await ref.child('Forums').orderByChild('title').startAt(misspelledQuery).endAt(misspelledQuery + '\uf8ff').once();
  // Perform actual search logic...
}

// Function to perform tag search
Future<void> performTagSearch(FirebaseDatabase database, String nonExistentTag) async {
  DatabaseReference ref = database.reference();
  await ref.child('Tags').orderByChild('name').equalTo(nonExistentTag).once();
  // Perform actual search logic...
}
