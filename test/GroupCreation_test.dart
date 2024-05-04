import 'package:flutter_test/flutter_test.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';

void main() {
  group('Group Chat Management Tests', () {
    test('Creating Public Group Chat ', () {
      // Test the creation of a public group chat with specified title
      createGroupChat(
        groupId: '123',
        title: 'SoftwareEngineering!!!',
        isPrivate: false,
        memberUsers: [
          {'id': 'user1', 'name': 'John Doe'},
          {'id': 'user2', 'name': 'Jane Doe'},
        ],
      );
      // Assertions
    });
    test('Creating Public Group Chat with private slider selected', () {
      // Test the creation of a public group chat with specified title
      createGroupChat(
        groupId: '123',
        title: 'SoftwareEngineering!!!',
        isPrivate: true,
        memberUsers: [
          {'id': 'user1', 'name': 'John Doe'},
          {'id': 'user2', 'name': 'Jane Doe'},
        ],
      );
      // Assertions
    });

    test('Creating Private Group Chat with Slider Selected', () {
      // Test the creation of a private group chat with slider selected
      createGroupChat(
        groupId: '456',
        title: 'Private Group',
        isPrivate: true,
        memberUsers: [
          {'id': 'user1', 'name': 'John Doe'},
          {'id': 'user2', 'name': 'Jane Doe'},
        ],
      );
      // Assertions
    });

    test('Creating Private Group Chat with Slider Not Selected', () {
      // Test the creation of a private group chat with slider not selected
      createGroupChat(
        groupId: '789',
        title: 'Private Group',
        isPrivate: false,
        memberUsers: [
          {'id': 'user1', 'name': 'John Doe'},
          {'id': 'user2', 'name': 'Jane Doe'},
        ],
      );
      // Assertions
    });

    test('Joining Group Chat', () {
      // Test joining a group chat
      joinChat(
        chatId: '123',
        isPrivate: false,
      );
      // Assertions
    });

    test('Adding Member "Billy" to Group Chat', () {
      // Test adding member "Billy" to the group chat
      List<Map<String, dynamic>> memberUsers = [];
      addUser(
        user: {'id': 'Billy', 'name': 'Billy'},
        memberUsers: memberUsers,
      );
      // Assertions
    });

    test('Adding Duplicate Member "Billy" to Group Chat', () {
      // Test adding a member "Billy" who is already in the group chat
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
      // Test adding a null member to the group chat
      List<Map<String, dynamic>> memberUsers = [];
      expect(
            () => addUser(
          user: {'id': null, 'name': 'NullUser'},
          memberUsers: memberUsers,
        ),
        throwsException,
      );
    });

// You can remove the 'existingUsersInDatabase' parameter from this test
    test('Adding Non-existing Member "Doesntexist" to Group Chat', () {
      // Arrange
      List<Map<String, dynamic>> memberUsers = [];

      // Act and Assert
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
      // Test sending a message to the group chat
      sendMessage(
        chatId: '123',
        message: 'Hello!!!!',
      );
      // Assertions
    });

    test('Messaging the Group Chat with Empty Message', () {
      // Test sending an empty message to the group chat
      expect(
            () => sendMessage(
          chatId: '123',
          message: '',
        ),
        throwsException,
      );
    });
    test('Sending a file into Group Chat', () {
      // Test sending a file into the group chat
      sendMessageNew(
        chatId: '123',
        message: 'File sent.',
        fileBytes: Uint8List(0),
        fileName: 'file.txt',
        uploadFile: () async => 'url',
      );
      // No assertions as the function should not throw an exception
    });

    test('Sending a file with Size Too Big into Group Chat', () {
      // Test sending a file with size exceeding the limit
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
      // Test removing a user from the group chat
      removeUserFromGroup(
        userId: 'user1',
        groupId: '123',
      );
      // No assertions as the function should not throw an exception
    });

    test('Removing a user from Group Chat - User is not Admin', () {
      // Test removing a user from the group chat when the user is not admin
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
      // Test changing the group chat name
      changeGroupChatName(
        groupId: '123',
        newName: 'Changed Name',
      );
      // No assertions as the function should not throw an exception
    });

    test('Changing Group Chat Name - User is not Admin', () {
      // Test changing the group chat name when the user is not admin
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
      // Test changing the group chat name to null
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
      // Test leaving the group chat
      leaveGroupChat(
        userId: 'user1',
        groupId: '123',
      );
      // No assertions as the function should not throw an exception
    });

    test('Selecting Profile from Group', () {
      // Test selecting profile from the group
      selectProfileFromGroup(
        userId: 'user1',
        groupId: '123',
      );
      // No assertions as the function should not throw an exception
    });

  });
}

// Required functions:

void createGroupChat({
  required String groupId,
  required String title,
  required bool isPrivate,
  required List<Map<String, dynamic>> memberUsers,
}) {
  // Implementation for creating a group chat
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
  // Implementation for joining a chat
  print('Joining group chat with ID: $chatId');
}

void addUser({
  required Map<String, dynamic> user,
  required List<Map<String, dynamic>> memberUsers,
  List<Map<String, dynamic>>? existingUsersInDatabase,
}) {
  // Implementation for adding a user to a group chat
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
  // Implementation for sending a message to a group chat
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
  // Implementation for sending a message with a file
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
  // Implementation for removing a user from a group chat
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
  // Implementation for changing the group chat name
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
  // Implementation for leaving a group chat
}

void selectProfileFromGroup({
  required String userId,
  required String groupId,
}) {
  // Implementation for selecting a profile from a group chat
}
