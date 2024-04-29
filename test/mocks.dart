import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseDatabase extends Mock implements FirebaseDatabase {}
class MockDatabaseReference extends Mock implements DatabaseReference {}
class MockDataSnapshot extends Mock implements DataSnapshot {}
class MockDatabaseEvent extends Mock implements DatabaseEvent {}
class MockUser extends Mock implements User {}

// Declare mock instances as global variables
late MockFirebaseAuth mockAuth;
late MockFirebaseDatabase mockDatabase;
late MockDatabaseReference mockDatabaseRef;
late MockDatabaseEvent mockDatabaseEvent;
late MockDataSnapshot mockDataSnapshot;
late MockUser mockUser;

void setUpMocks() {
  // Initialize the mocks
  mockAuth = MockFirebaseAuth();
  mockDatabase = MockFirebaseDatabase();
  mockDatabaseRef = MockDatabaseReference();
  mockDatabaseEvent = MockDatabaseEvent();
  mockDataSnapshot = MockDataSnapshot();
  mockUser = MockUser();

  // Set up the when conditions
  when(() => mockAuth.currentUser).thenReturn(mockUser);
  when(() => mockUser.uid).thenReturn('userId');
  when(() => mockDatabase.ref()).thenReturn(mockDatabaseRef);
  when(() => mockDatabaseRef.child(any())).thenReturn(mockDatabaseRef);
  when(() => mockDatabaseRef.set(any())).thenAnswer((_) async => {});
  when(() => mockDatabaseRef.remove()).thenAnswer((_) async => {});
  when(() => mockDatabaseRef.push()).thenReturn(mockDatabaseRef);
  when(() => mockDatabaseRef.once()).thenAnswer((_) async => mockDatabaseEvent); // Mock the once method
  when(() => mockDatabaseEvent.snapshot).thenReturn(mockDataSnapshot);
  when(() => mockDataSnapshot.exists).thenReturn(true);
}

