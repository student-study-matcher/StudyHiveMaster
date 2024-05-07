import 'package:flutter_test/flutter_test.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';

void main() {
  group('Group Chat Management Tests', () {
    test('Creating Public Group Chat ', () {
      createGroupChat(
        groupId: '123',
        title: 'SoftwareEngineering!!!',
        isPrivate: false,
        memberUsers: [
          {'id': 'user1', 'name': 'John Doe'},
          {'id': 'user2', 'name': 'Jane Doe'},
        ],
      );
    });
    test('Creating Public Group Chat with private slider selected', () {
      createGroupChat(
        groupId: '123',
        title: 'SoftwareEngineering!!!',
        isPrivate: true,
        memberUsers: [
          {'id': 'user1', 'name': 'John Doe'},
          {'id': 'user2', 'name': 'Jane Doe'},
        ],
      );
    });

    test('Creating Private Group Chat with Slider Selected', () {
      createGroupChat(
        groupId: '456',
        title: 'Private Group',
        isPrivate: true,
        memberUsers: [
          {'id': 'user1', 'name': 'John Doe'},
          {'id': 'user2', 'name': 'Jane Doe'},
        ],
      );
    });

    test('Creating Private Group Chat with Slider Not Selected', () {
      createGroupChat(
        groupId: '789',
        title: 'Private Group',
        isPrivate: false,
        memberUsers: [
          {'id': 'user1', 'name': 'John Doe'},
          {'id': 'user2', 'name': 'Jane Doe'},
        ],
      );
    });

    test('Joining Group Chat', () {
      joinChat(
        chatId: '123',
        isPrivate: false,
      );
    });

    test('Adding Member "Billy" to Group Chat', () {
      List<Map<String, dynamic>> memberUsers = [];
      addUser(
        user: {'id': 'Billy', 'name': 'Billy'},
        memberUsers: memberUsers,
      );
    });

    test('Adding Duplicate Member "Billy" to Group Chat', () {
      List<Map<String, dynamic>> memberUsers = [{'id': 'Billy', 'name': 'Billy'}];
      expect(
            () => addUser(
          user: {'id': 'Billy', 'name': 'Billy'},
          memberUsers: memberUsers,
        ),
        throwsException,
      );
    });

    test('Adding Null Member to Group Chat', () {
      List<Map<String, dynamic>> memberUsers = [];
      expect(
            () => addUser(
          user: {'id': null, 'name': 'NullUser'},
          memberUsers: memberUsers,
        ),
        throwsException,
      );
    });


    test('Adding Non-existing Member "Doesntexist" to Group Chat', () {
      List<Map<String, dynamic>> memberUsers = [];
      expect(
            () => addUser(
          user: {'id': 'Doesntexist', 'name': 'Doesntexist'},
          memberUsers: memberUsers,
          existingUsersInDatabase: [],
        ),
        throwsException,
      );
    });

    test('Messaging the Group Chat with "Hello!!!!"', () {
      sendMessage(
        chatId: '123',
        message: 'Hello!!!!',
      );
    });

    test('Messaging the Group Chat with Empty Message', () {
      expect(
            () => sendMessage(
          chatId: '123',
          message: '',
        ),
        throwsException,
      );
    });
    test('Sending a file into Group Chat', () {
      sendMessageNew(
        chatId: '123',
        message: 'File sent.',
        fileBytes: Uint8List(0),
        fileName: 'file.txt',
        uploadFile: () async => 'url',
      );
    });

    test('Sending a file with Size Too Big into Group Chat', () {
      expect(
            () => sendMessageNew(
          chatId: '123',
          message: 'File sent.',
          fileBytes: Uint8List(10485761), // 10MB + 1 byte
          fileName: 'file.txt',
          uploadFile: () async => 'url',
        ),
        throwsException,
      );
    });

    test('Removing a user from Group Chat', () {
      removeUserFromGroup(
        userId: 'user1',
        groupId: '123',
      );
    });

    test('Removing a user from Group Chat - User is not Admin', () {
      expect(
            () => removeUserFromGroup(
          userId: 'user1',
          groupId: '123',
          isAdmin: false,
        ),
        throwsException,
      );
    });

    test('Changing Group Chat Name', () {
      changeGroupChatName(
        groupId: '123',
        newName: 'Changed Name',
      );
    });

    test('Changing Group Chat Name - User is not Admin', () {
      expect(
            () => changeGroupChatName(
          groupId: '123',
          newName: 'New Name',
          isAdmin: false,
        ),
        throwsException,
      );
    });

    test('Changing Group Chat Name - Null Name', () {
      expect(
            () => changeGroupChatName(
          groupId: '123',
          newName: null,
          isAdmin: true,
        ),
        throwsException,
      );
    });

    test('Leaving a Group Chat', () {
      leaveGroupChat(
        userId: 'user1',
        groupId: '123',
      );
    });

    test('Selecting Profile from Group', () {
      selectProfileFromGroup(
        userId: 'user1',
        groupId: '123',
      );
    });
  });
}

void createGroupChat({
  required String groupId,
  required String title,
  required bool isPrivate,
  required List<Map<String, dynamic>> memberUsers,
}) {
  print('Creating group chat with ID: $groupId');
  print('Title: $title');
  print('Private: $isPrivate');
  print('Members:');
  memberUsers.forEach((user) {
    print('User ID: ${user['id']}, Name: ${user['name']}');
  });
}

void joinChat({
  required String chatId,
  required bool isPrivate,
}) {
  print('Joining group chat with ID: $chatId');
}

void addUser({
  required Map<String, dynamic> user,
  required List<Map<String, dynamic>> memberUsers,
  List<Map<String, dynamic>>? existingUsersInDatabase,
}) {
  if (user['id'] == null) {
    throw Exception('User ID cannot be null');
  }
  if (existingUsersInDatabase != null &&
      !existingUsersInDatabase.any((element) => element['id'] == user['id'])) {
    throw Exception('User does not exist in the database');
  }
  if (memberUsers.any((element) => element['id'] == user['id'])) {
    throw Exception('User already exists in the group chat');
  }
  memberUsers.add(user);
}


void sendMessage({
  required String chatId,
  required String message,
}) {
  if (message.isEmpty) {
    throw Exception('Message text cannot be null');
  }
}

void sendMessageNew({
  required String chatId,
  required String message,
  required Uint8List? fileBytes,
  required String? fileName,
  required Future<String?> Function() uploadFile,
}) async {
  String? fileUrl;
  if (fileBytes != null) {
    // Check if file size is less than 10MB
    if (fileBytes.lengthInBytes > 10485760) {
      throw Exception('File size must be less than 10MB');
    }
    fileUrl = await uploadFile();
    if (fileUrl == null) {
      throw Exception('Failed to upload file. Message not sent.');
    }
  }
}

void removeUserFromGroup({
  required String userId,
  required String groupId,
  bool isAdmin = true,
}) {
  if (isAdmin) {
  } else {
    throw Exception('User is not admin. Cannot remove user from group chat.');
  }
}

void changeGroupChatName({
  required String groupId,
  required String? newName,
  bool isAdmin = true,
}) {
  if (newName != null) {
    if (isAdmin) {

    } else {
      throw Exception('User is not admin. Cannot change group chat name.');
    }
  } else {
    throw Exception('Group chat name cannot be null.');
  }
}

void leaveGroupChat({
  required String userId,
  required String groupId,
}) {
}

void selectProfileFromGroup({
  required String userId,
  required String groupId,
}) {
}
