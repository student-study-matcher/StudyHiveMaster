import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'mocks.dart';

void main() {
  setUpMocks();

  test('User sends a friend request', () async {
    when(() => mockDatabaseRef.set(true)).thenAnswer((_) async => {});

    await sendFriendRequest(mockDatabase, 'currentUserId', 'friendUserId');

    verify(() => mockDatabaseRef.child('Users/currentUserId/friendRequestsSent/friendUserId').set(true)).called(1);
    verify(() => mockDatabaseRef.child('Users/friendUserId/friendRequestsReceived/currentUserId').set(true)).called(1);
  });

  test('User receives a friend request', () async {
    when(() => mockDataSnapshot.value).thenReturn({'requestId': 'requestUserId'});
    when(() => mockDatabaseRef.onValue).thenAnswer((_) => Stream.fromIterable([mockDatabaseEvent]));

    setupFriendRequestListener(mockDatabase, 'userId');

    await Future.delayed(Duration.zero); // Allow some time for the listener to execute

    verify(() => mockDatabaseRef.child('Users/userId/friendRequestsReceived')).called(1);
  });

  test('User accepts a friend request', () async {
    when(() => mockDatabaseRef.set(true)).thenAnswer((_) async => {});

    await acceptFriendRequest(mockDatabase, 'userId', 'friendId');

    verify(() => mockDatabaseRef.child('Users/userId/friends/friendId').set(true)).called(1);
    verify(() => mockDatabaseRef.child('Users/friendId/friends/userId').set(true)).called(1);
    verify(() => mockDatabaseRef.child('Users/userId/friendRequestsReceived/friendId').remove()).called(1);
    verify(() => mockDatabaseRef.child('Users/friendId/friendRequestsSent/userId').remove()).called(1);
  });

  test('User denies a friend request', () async {
    await rejectFriendRequest(mockDatabase, 'userId', 'friendId');

    verify(() => mockDatabaseRef.child('Users/userId/friendRequestsReceived/friendId').remove()).called(1);
    verify(() => mockDatabaseRef.child('Users/friendId/friendRequestsSent/userId').remove()).called(1);
  });

  test('User removes a friend', () async {
    await removeFriend(mockDatabase, 'userId', 'friendId');

    verify(() => mockDatabaseRef.child('Users/userId/friends/friendId').remove()).called(1);
    verify(() => mockDatabaseRef.child('Users/friendId/friends/userId').remove()).called(1);
  });

  test('User messages a friend with a valid message', () async {
    when(() => mockDatabaseRef.set(any())).thenAnswer((_) async => {});

    await sendMessageToFriend(mockDatabase, 'userId', 'friendId', 'Hello');

    verify(() => mockDatabaseRef.child('Messages/userId/friendId').push().set(any(named: 'value'))).called(1);
  });

  test('User messages a friend with a long valid message', () async {
    when(() => mockDatabaseRef.set(any())).thenAnswer((_) async => {});

    final longMessage = 'HellloHellloHellloHellloHellloHellloHellloHellloHellloHellloHellloHellloHellloHellloHellloHelllo...';
    await sendMessageToFriend(mockDatabase, 'userId', 'friendId', longMessage);

    verify(() => mockDatabaseRef.child('Messages/userId/friendId').push().set(any(named: 'value'))).called(1);
  });
  
  test('User sends a friend request with null input (nothing happens)', () async {
    await sendFriendRequest(mockDatabase, null, null);

    verifyNever(() => mockDatabaseRef.child(any()).set(any()));
  });

  test('User receives a friend request with null input (nothing happens)', () async {
    setupFriendRequestListener(mockDatabase, null);

    await Future.delayed(Duration.zero); // Allow some time for the listener to execute

    verifyNever(() => mockDatabaseRef.child('Users/userId/friendRequestsReceived'));
  });

  test('User removes a friend with null input (no friends removed)', () async {
    await removeFriend(mockDatabase, null, null);

    verifyNever(() => mockDatabaseRef.child('Users/userId/friends'));
  });

  test('User messages a friend with null input (no messages sent)', () async {
    await sendMessageToFriend(mockDatabase, null, null, null);

    verifyNever(() => mockDatabaseRef.child('Messages'));
  });
}

Future<void> sendFriendRequest(FirebaseDatabase db, String? currentUserId, String? friendUserId) async {
  if (currentUserId == null || friendUserId == null) {
    return;
  }
  DatabaseReference ref = db.ref();
  await ref.child('Users/$currentUserId/friendRequestsSent/$friendUserId').set(true);
  await ref.child('Users/$friendUserId/friendRequestsReceived/$currentUserId').set(true);
}

void setupFriendRequestListener(FirebaseDatabase db, String? userId) {
  if (userId == null) {
    return;
  }
  DatabaseReference ref = db.ref();
  ref.child('Users/$userId/friendRequestsReceived').onValue.listen((DatabaseEvent event) {});
}

Future<void> acceptFriendRequest(FirebaseDatabase db, String? userId, String? friendId) async {
  if (userId == null || friendId == null) {
    return;
  }
  DatabaseReference ref = db.ref();
  await ref.child('Users/$userId/friends/$friendId').set(true);
  await ref.child('Users/$friendId/friends/$userId').set(true);
  await ref.child('Users/$userId/friendRequestsReceived/$friendId').remove();
  await ref.child('Users/$friendId/friendRequestsSent/$userId').remove();
}

Future<void> rejectFriendRequest(FirebaseDatabase db, String? userId, String? friendId) async {
  if (userId == null || friendId == null) {
    return;
  }
  DatabaseReference ref = db.ref();
  await ref.child('Users/$userId/friendRequestsReceived/$friendId').remove();
  await ref.child('Users/$friendId/friendRequestsSent/$userId').remove();
}

Future<void> removeFriend(FirebaseDatabase db, String? userId, String? friendId) async {
  if (userId == null || friendId == null) {
    return;
  }
  DatabaseReference ref = db.ref();
  await ref.child('Users/$userId/friends/$friendId').remove();
  await ref.child('Users/$friendId/friends/$userId').remove();
}

Future<void> sendMessageToFriend(FirebaseDatabase db, String? userId, String? friendId, String? message) async {
  if (userId == null || friendId == null || message == null) {
    return;
  }
  DatabaseReference ref = db.ref();
  await ref.child('Messages/$userId/$friendId').push().set({
    'message': message,
    'timestamp': DateTime.now().toIso8601String()
  });
}
