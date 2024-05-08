import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseDatabase extends Mock implements FirebaseDatabase {}
class MockDatabaseReference extends Mock implements DatabaseReference {}
class MockDataSnapshot extends Mock implements DataSnapshot {}
class MockDatabaseEvent extends Mock implements DatabaseEvent {}
class MockUser extends Mock implements User {}

// Declare mock instances as global variables
MockFirebaseAuth? mockAuth;
MockFirebaseDatabase? mockDatabase;
MockDatabaseReference? mockDatabaseRef;
MockDatabaseEvent? mockDatabaseEvent;
MockDataSnapshot? mockDataSnapshot;
MockUser? mockUser;

void setUpMocks() {
  // Initialize the mocks
  mockAuth = MockFirebaseAuth();
  mockDatabase = MockFirebaseDatabase();
  mockDatabaseRef = MockDatabaseReference();
  mockDatabaseEvent = MockDatabaseEvent();
  mockDataSnapshot = MockDataSnapshot();
  mockUser = MockUser();

  // Set up the when conditions
  when(() => mockAuth?.currentUser).thenReturn(mockUser);
  when(() => mockUser?.uid).thenReturn('userId');
  when(() => mockDatabase?.ref()).thenReturn(mockDatabaseRef);
  when(() => mockDatabaseRef?.child(any())).thenReturn(mockDatabaseRef);
  when(() => mockDatabaseRef?.set(any())).thenAnswer((_) async => {});
  when(() => mockDatabaseRef?.remove()).thenAnswer((_) async => {});
  when(() => mockDatabaseRef?.push()).thenReturn(mockDatabaseRef);
  when(() => mockDatabaseRef?.once()).thenAnswer((_) async => mockDatabaseEvent!); // Mock the once method
  when(() => mockDatabaseEvent?.snapshot).thenReturn(mockDataSnapshot);
  when(() => mockDataSnapshot?.exists).thenReturn(true);
}

void main() {
  setUpMocks();

  test('User sends a friend request', () async {     //Sends a friend request
    print('Test Start: Sending a friend request');
    when(() => mockDatabaseRef!.set(true)).thenAnswer((_) async => {});

    await sendFriendRequest(mockDatabase!, 'currentUserId', 'friendUserId');

    verify(() => mockDatabaseRef!.child('Users/currentUserId/friendRequestsSent/friendUserId').set(true)).called(1);
    verify(() => mockDatabaseRef!.child('Users/friendUserId/friendRequestsReceived/currentUserId').set(true)).called(1);
    print('Test Passed: Friend request sent successfully');
  });

  test('User receives a friend request', () async {     //Receive a friend request
    print('Test Start: Receiving a friend request');
    when(() => mockDataSnapshot!.value).thenReturn({'requestId': 'requestUserId'});
    when(() => mockDatabaseRef!.onValue).thenAnswer((_) => Stream.fromIterable([mockDatabaseEvent!]));

    setupFriendRequestListener(mockDatabase!, 'userId');

    await untilCalled(() => mockDatabaseRef!.onValue);
    verify(() => mockDatabaseRef!.child('Users/userId/friendRequestsReceived')).called(1);
    print('Test Passed: Friend request received successfully');
  });

  test('User accepts a friend request', () async {
    print('Test Start: Accepting a friend request');
    when(() => mockDatabaseRef!.set(true)).thenAnswer((_) async => {});

    await acceptFriendRequest(mockDatabase!, 'userId', 'friendId');

    verify(() => mockDatabaseRef!.child('Users/userId/friends/friendId').set(true)).called(1);
    verify(() => mockDatabaseRef!.child('Users/friendId/friends/userId').set(true)).called(1);
    verify(() => mockDatabaseRef!.child('Users/userId/friendRequestsReceived/friendId').remove()).called(1);
    verify(() => mockDatabaseRef!.child('Users/friendId/friendRequestsSent/userId').remove()).called(1);
    print('Test Passed: Friend request accepted successfully');
  });

  test('User denies a friend request', () async {
    print('Test Start: Denying a friend request');
    await rejectFriendRequest(mockDatabase!, 'userId', 'friendId');

    verify(() => mockDatabaseRef!.child('Users/userId/friendRequestsReceived/friendId').remove()).called(1);
    verify(() => mockDatabaseRef!.child('Users/friendId/friendRequestsSent/userId').remove()).called(1);
    print('Test Passed: Friend request denied successfully');
  });

  test('User messages a friend', () async {
    print('Test Start: Messaging a friend');
    when(() => mockDatabaseRef!.set(any())).thenAnswer((_) async => {});

    await sendMessageToFriend(mockDatabase!, 'userId', 'friendId', 'Hello');

    verify(() => mockDatabaseRef!.child('Messages/userId/friendId').push().set(any(named: 'value'))).called(1);
    print('Test Passed: Message sent successfully');
  });
}


Future<void> sendFriendRequest(FirebaseDatabase db, String currentUserId, String friendUserId) async {
  DatabaseReference ref = db.ref();
  await ref.child('Users/$currentUserId/friendRequestsSent/$friendUserId').set(true);
  await ref.child('Users/$friendUserId/friendRequestsReceived/$currentUserId').set(true);
}

void setupFriendRequestListener(FirebaseDatabase db, String userId) {
  DatabaseReference ref = db.ref();
  ref.child('Users/$userId/friendRequestsReceived').onValue.listen((DatabaseEvent event) {
    print('Friend request received from ${event.snapshot.value}');
  });
}

Future<void> acceptFriendRequest(FirebaseDatabase db, String userId, String friendId) async {
  DatabaseReference ref = db.ref();
  await ref.child('Users/$userId/friends/$friendId').set(true);
  await ref.child('Users/$friendId/friends/$userId').set(true);
  await ref.child('Users/$userId/friendRequestsReceived/$friendId').remove();
  await ref.child('Users/$friendId/friendRequestsSent/$userId').remove();
}

Future<void> rejectFriendRequest(FirebaseDatabase db, String userId, String friendId) async {
  DatabaseReference ref = db.ref();
  await ref.child('Users/$userId/friendRequestsReceived/$friendId').remove();
  await ref.child('Users/$friendId/friendRequestsSent/$userId').remove();
}

Future<void> sendMessageToFriend(FirebaseDatabase db, String userId, String friendId, String message) async {
  DatabaseReference ref = db.ref();
  await ref.child('Messages/$userId/$friendId').push().set({
    'message': message,
    'timestamp': DateTime.now().toIso8601String()
  });

}