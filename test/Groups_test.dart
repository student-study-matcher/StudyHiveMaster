import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

class MockReference extends Mock implements Reference {
  @override
  UploadTask putData(Uint8List data, [SettableMetadata? metadata]) {
    return MockUploadTask();
  }
}

class MockUploadTask extends Mock implements UploadTask {}

class MockDatabase extends Mock implements FirebaseDatabase {}

class MockDatabaseRef extends Mock implements DatabaseReference {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockDatabaseEvent extends Mock implements DatabaseEvent {}

class MockDatabaseSnapshot extends Mock implements DataSnapshot {}

class MockBuildContext extends Mock implements BuildContext {}

class MockUser extends Mock implements User {
  @override
  String get uid => '123';
}

class MockNavigationState extends Mock implements NavigatorState {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.debug}) {
    return super.toString();
  }
}

class MockUserCredential extends Mock implements UserCredential {
  @override
  User get user => MockUser();
}

class MockScaffoldMessengerState extends Mock
    implements ScaffoldMessengerState {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.debug}) {
    return super.toString();
  }
}

class MockSnackBar extends Mock implements SnackBar {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.debug}) {
    return super.toString();
  }
}

class Uint8ListWrapper {
  Uint8List data;
  Uint8ListWrapper(this.data);
}

class Uint8ListWrapperMock extends Fake implements Uint8ListWrapper {}

void main() {
  late MockFirebaseAuth auth;
  late MockDatabase database;
  late MockDatabaseRef databaseRef;
  late MockDatabaseEvent databaseEvent;
  late MockDatabaseSnapshot databaseSnapshot;
  late MockBuildContext context;
  late MockNavigationState navigator;
  late MockFirebaseStorage firebaseStorage;
  late MockReference reference;

  setUpAll(() async {
    auth = MockFirebaseAuth();
    database = MockDatabase();
    databaseRef = MockDatabaseRef();
    databaseEvent = MockDatabaseEvent();
    databaseSnapshot = MockDatabaseSnapshot();
    context = MockBuildContext();
    navigator = MockNavigationState();
    firebaseStorage = MockFirebaseStorage();
    reference = MockReference();

    registerFallbackValue(Uint8ListWrapperMock());

    when(() => databaseRef.push()).thenReturn(databaseRef);

    when(() => databaseRef.child(any())).thenReturn(databaseRef);
    when(() => databaseRef.child(any()).child(any())).thenReturn(databaseRef);

    when(() => databaseRef.set(any())).thenAnswer((_) async => {});

    when(() => database.ref()).thenReturn(databaseRef);

    when(() => auth.currentUser).thenReturn(MockUser());

    when(() => databaseRef.update(any())).thenAnswer((_) async => {});

    when(() => context.findAncestorStateOfType<NavigatorState>())
        .thenReturn(navigator);

    when(() => navigator.pop(any())).thenAnswer((_) async => {});

    when(() => firebaseStorage.ref()).thenReturn(reference);
    when(() => reference.child(any())).thenReturn(reference);
    // when(() => reference.putData(any())).thenAnswer((_) => MockUploadTask());
    when(() => reference.getDownloadURL()).thenAnswer((_) async => 'url');
  });

  group('group tests', () {
    test('create public group chat', () async {
      String groupId = '123';
      String title = 'title';
      bool isPrivate = false;
      List<Map<String, dynamic>> memberUsers = [
        {'id': '123', 'name': 'name'},
      ];

      await createGroupChat(
        firebaseDatabase: database,
        firebaseAuth: auth,
        navigator: navigator,
        groupId: groupId,
        title: title,
        isPrivate: isPrivate,
        memberUsers: memberUsers,
        context: context,
      );

      verify(() => databaseRef.child('GroupChats/$groupId').set({
        'title': title,
        'isPrivate': isPrivate,
        'adminID': auth.currentUser!.uid,
        'memberIDs': {'123': true, '456': true},
      })).called(1);

      verify(() => navigator.pop(context)).called(1);
    });

    test('create private group chat', () async {
      String groupId = '123';
      String title = 'title';
      bool isPrivate = true;
      List<Map<String, dynamic>> memberUsers = [
        {'id': '123', 'name': 'name'},
        {'id': '456', 'name': 'name2'},
      ];

      await createGroupChat(
        firebaseDatabase: database,
        firebaseAuth: auth,
        navigator: navigator,
        groupId: groupId,
        title: title,
        isPrivate: isPrivate,
        memberUsers: memberUsers,
        context: context,
      );

      verify(() => databaseRef.child('GroupChats/$groupId').set({
        'title': title,
        'isPrivate': isPrivate,
        'adminID': auth.currentUser!.uid,
        'memberIDs': {'123': true, '456': true},
      })).called(1);

      expect(isPrivate, true);
      verify(() => navigator.pop(context)).called(1);
    });

    test('send message', () async {
      when(() => databaseRef.push()).thenReturn(databaseRef);

      String chatId = '123';
      String message = 'A message!';

      sendMessage(
        databaseRef: databaseRef,
        chatId: chatId,
        message: message,
        firebaseAuth: auth,
      );

      verify(() => databaseRef.child('GroupChats/$chatId/messages').push().set({
        'text': message,
        'senderId': auth.currentUser?.uid,
        'timestamp': ServerValue.timestamp,
      })).called(1);
    });

    test('send message with file', () async {
      String chatId = '123';
      String message = 'A message!';
      Uint8List fileBytes = Uint8List(0);
      String fileName = 'file.txt';

      await sendMessageNew(
        message: message,
        databaseRef: databaseRef,
        auth: auth,
        chatId: chatId,
        context: context,
        fileBytes: fileBytes,
        fileName: fileName,
        uploadFile: () async => 'url',
      );

      verify(() => databaseRef.child('GroupChats/$chatId/messages').push().set({
        'text': 'File sent: $fileName',
        'senderId': auth.currentUser?.uid,
        'timestamp': ServerValue.timestamp,
        'fileUrl': 'url',
        'fileName': fileName
      })).called(1);
    });

    test('user selects file which is too big', () async {
      String chatId = '123';
      String message = 'A message!';
      Uint8List fileBytes =
      Uint8List(10485761); // file of size greater than 10mb
      String fileName = 'file.txt';

      expect(
              () async => await sendMessageNew(
            message: message,
            databaseRef: databaseRef,
            auth: auth,
            chatId: chatId,
            context: context,
            fileBytes: fileBytes,
            fileName: fileName,
            uploadFile: () async => 'url',
          ),
          throwsException);
    });

    test('joinChat', () async {
      // Arrange

      var chatId = 'testChatId';
      var isPrivate = false;

      // Act
      await joinChat(
        databaseReference: databaseRef,
        auth: auth,
        context: context,
        chatId: chatId,
        isPrivate: isPrivate,
      );

      // Assert
      verify(() => databaseRef.child(any()).set(true)).called(1);
    });
  });

  group('addUser', () {
    test('should add user to memberUsers list if not already present', () {
      // Arrange
      var user = {'id': 'user1', 'name': 'John Doe'};
      var memberUsers = <Map<String, dynamic>>[];

      // Act
      addUser(user, memberUsers);

      // Assert
      expect(memberUsers.length, 1);
      expect(memberUsers[0], user);
    });

    test('should not add user to memberUsers list if already present', () {
      // Arrange
      var user = {'id': 'user1', 'name': 'John Doe'};
      var memberUsers = <Map<String, dynamic>>[user];

      // Act
      expect(() => addUser(user, memberUsers), throwsException);
    });
  });
}

Future<void> createGroupChat({
  required MockDatabase firebaseDatabase,
  required MockFirebaseAuth firebaseAuth,
  required MockNavigationState navigator,
  required String groupId,
  required String title,
  required bool isPrivate,
  required List<Map<String, dynamic>> memberUsers,
  required MockBuildContext context,
}) async {
  Map<String, bool> members = {for (var user in memberUsers) user['id']: true};

  await firebaseDatabase.ref().child('GroupChats/$groupId').set({
    'title': title,
    'isPrivate': isPrivate,
    'adminID': firebaseAuth.currentUser!.uid,
    'memberIDs': members,
  });

  navigator.pop(context);
}

void sendMessage({
  required MockDatabaseRef databaseRef,
  required String chatId,
  required String message,
  required MockFirebaseAuth firebaseAuth,
}) {
  if (message.isNotEmpty) {
    databaseRef.child('GroupChats/$chatId/messages').push().set({
      'text': message,
      'senderId': firebaseAuth.currentUser?.uid,
      'timestamp': ServerValue.timestamp,
    });
  }
}


Future<void> sendMessageNew({
  required String message,
  required MockDatabaseRef databaseRef,
  required MockFirebaseAuth auth,
  required String chatId,
  required BuildContext context,
  Uint8List? fileBytes,
  String? fileName,
  required Future<String?> Function() uploadFile,
}) async {
  String? fileUrl;
  if (fileBytes != null) {
    // check if file size is less than 10MB
    if (fileBytes.lengthInBytes > 10485760) {
      throw Exception('File size must be less than 10MB');
    }

    fileUrl = await uploadFile();

    if (fileUrl == null) {
      throw Exception('Failed to upload file. Message not sent.');
    }
  }

  if (message.isNotEmpty || fileUrl != null) {
    Map<String, dynamic> messageData = {
      'text': fileUrl != null ? "File sent: $fileName" : message,
      'senderId': auth.currentUser?.uid,
      'timestamp': ServerValue.timestamp,
      'fileUrl': fileUrl,
      'fileName': fileName
    };

    await databaseRef
        .child('GroupChats/$chatId/messages')
        .push()
        .set(messageData);

    fileBytes = null;
    fileName = null;
  } else {
    throw Exception('No message text or file to send.');
  }
}

Future<void> joinChat({
  required MockDatabaseRef databaseReference,
  required MockFirebaseAuth auth,
  required MockBuildContext context,
  required String chatId,
  required bool isPrivate,
}) async {
  if (!isPrivate) {
    await databaseReference
        .child('GroupChats/$chatId/memberIDs/${auth.currentUser!.uid}')
        .set(true);
    print("joined chat!");
    fetchGroupChats();
  } else {
    throw Exception("You can't join private chat");
  }
}

void fetchGroupChats() {
  print('Fetching group chats...');
}

void addUser(
    Map<String, dynamic> user, List<Map<String, dynamic>> memberUsers) {
  if (!memberUsers.any((element) => element['id'] == user['id'])) {
    memberUsers.add(user);
  } else {
    throw Exception('User already exists');
  }
}
