import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'mocks.dart';


void main() {
  setUpMocks();

  test('User sends a friend request', () async {     //Sends a friend request
    print('Test Start: Sending a friend request');
    when(() => mockDatabaseRef.set(true)).thenAnswer((_) async => {});

    await sendFriendRequest(mockDatabase, 'currentUserId', 'friendUserId');

    verify(() => mockDatabaseRef.child('Users/currentUserId/friendRequestsSent/friendUserId').set(true)).called(1);
    verify(() => mockDatabaseRef.child('Users/friendUserId/friendRequestsReceived/currentUserId').set(true)).called(1);
    print('Test Passed: Friend request sent successfully');
  });

  test('User receives a friend request', () async {     //Receive a friend request
    print('Test Start: Receiving a friend request');
    when(() => mockDataSnapshot.value).thenReturn({'requestId': 'requestUserId'});
    when(() => mockDatabaseRef.onValue).thenAnswer((_) => Stream.fromIterable([mockDatabaseEvent]));

    setupFriendRequestListener(mockDatabase, 'userId');

    await untilCalled(() => mockDatabaseRef.onValue);
    verify(() => mockDatabaseRef.child('Users/userId/friendRequestsReceived')).called(1);
    print('Test Passed: Friend request received successfully');
  });

  test('User accepts a friend request', () async {     //Accepts a friend request
    print('Test Start: Accepting a friend request');
    when(() => mockDatabaseRef.set(true)).thenAnswer((_) async => {});

    await acceptFriendRequest(mockDatabase, 'userId', 'friendId');

    verify(() => mockDatabaseRef.child('Users/userId/friends/friendId').set(true)).called(1);
    verify(() => mockDatabaseRef.child('Users/friendId/friends/userId').set(true)).called(1);
    verify(() => mockDatabaseRef.child('Users/userId/friendRequestsReceived/friendId').remove()).called(1);
    verify(() => mockDatabaseRef.child('Users/friendId/friendRequestsSent/userId').remove()).called(1);
    print('Test Passed: Friend request accepted successfully');
  });

  test('User denies a friend request', () async {     //Deny a friend request
    print('Test Start: Denying a friend request');
    await rejectFriendRequest(mockDatabase, 'userId', 'friendId');

    verify(() => mockDatabaseRef.child('Users/userId/friendRequestsReceived/friendId').remove()).called(1);
    verify(() => mockDatabaseRef.child('Users/friendId/friendRequestsSent/userId').remove()).called(1);
    print('Test Passed: Friend request denied successfully');
  });

  test('User messages a friend', () async {     //Messages a friend
    print('Test Start: Messaging a friend');
    when(() => mockDatabaseRef.set(any())).thenAnswer((_) async => {});

    await sendMessageToFriend(mockDatabase, 'userId', 'friendId', 'Hello');

    verify(() => mockDatabaseRef.child('Messages/userId/friendId').push().set(any(named: 'value'))).called(1);
    print('Test Passed: Message sent successfully');
  });
}

// Implementations of the functionalities to be tested
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
