import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockFirebaseDatabase extends Mock implements FirebaseDatabase {}
class MockDatabaseReference extends Mock implements DatabaseReference {}

void main() {
  late MockFirebaseAuth auth;
  late MockFirebaseDatabase database;
  late MockDatabaseReference databaseRef;

  setUp(() {
    auth = MockFirebaseAuth();
    database = MockFirebaseDatabase();
    databaseRef = MockDatabaseReference();

    when(() => database.ref()).thenReturn(databaseRef);
    when(() => databaseRef.child(any())).thenReturn(databaseRef);
  });

  test('Null username', () async {
    TextEditingController usernameController = TextEditingController(text: null);

    expect(() => validateUsername(usernameController.text), throwsA(isA<Exception>()));
  });

  test('Invalid name, numbers and special characters are invalid', () async {
    TextEditingController firstNameController = TextEditingController(text: 'Tom');
    TextEditingController lastNameController = TextEditingController(text: '1+/2');

    expect(() => validateNames(firstNameController.text, lastNameController.text), throwsA(isA<Exception>()));
  });

  test('Valid input, only alphabetic characters', () async {
    TextEditingController firstNameController = TextEditingController(text: 'Tom');
    TextEditingController lastNameController = TextEditingController(text: 'Smith');

    expect(() => validateNames(firstNameController.text, lastNameController.text), returnsNormally);
  });

  test('Invalid DOB, age must be >18', () async {
    TextEditingController dobController = TextEditingController(text: '2022-02-22');

    expect(() => validateDOB(dobController.text), throwsA(isA<Exception>()));
  });

  test('Null DOB', () async {
    TextEditingController dobController = TextEditingController(text: null);

    expect(() => validateDOB(dobController.text), throwsA(isA<Exception>()));
  });

  test('Valid DOB, >18', () async {
    TextEditingController dobController = TextEditingController(text: '2002-02-22');

    expect(() => validateDOB(dobController.text), returnsNormally);
  });

  test('Null values for university', () async {
    String? userUniversity = null;

    expect(() => validateUniversity(userUniversity), throwsA(isA<Exception>()));
  });

  test('Valid university from dropdown list', () async {
    String? userUniversity = 'University of Portsmouth';

    expect(() => validateUniversity(userUniversity), returnsNormally);
  });

  test('Null values for course', () async {
    String? userCourse = null;

    expect(() => validateCourse(userCourse), throwsA(isA<Exception>()));
  });

  test('Valid course from dropdown list', () async {
    String? userCourse = 'Computer Science';

    expect(() => validateCourse(userCourse), returnsNormally);
  });

  test('Valid username', () async {
    TextEditingController usernameController = TextEditingController(text: 'student_12-');

    expect(() => validateUsername(usernameController.text), returnsNormally);
  });

  test('Invalid username, <3 characters long', () async {
    TextEditingController usernameController = TextEditingController(text: 'st');

    expect(() => validateUsername(usernameController.text), throwsA(isA<Exception>()));
  });

  test('Invalid username, >15 characters long', () async {
    TextEditingController usernameController = TextEditingController(text: 'studentsssssssss');

    expect(() => validateUsername(usernameController.text), throwsA(isA<Exception>()));
  });

  test('Invalid username with special characters', () async {
    TextEditingController usernameController = TextEditingController(text: 'student+/');

    expect(() => validateUsername(usernameController.text), throwsA(isA<Exception>()));
  });

  test('Missing fields', () async {
    TextEditingController firstNameController = TextEditingController(text: '');
    TextEditingController lastNameController = TextEditingController(text: '');
    TextEditingController dobController = TextEditingController(text: '');
    TextEditingController usernameController = TextEditingController(text: '');

    expect(() => saveUserData(firstNameController, lastNameController, dobController, usernameController), throwsA(isA<Exception>()));
  });

  test('Valid registration input', () async {
    TextEditingController firstNameController = TextEditingController(text: 'Tom');
    TextEditingController lastNameController = TextEditingController(text: 'Smith');
    TextEditingController dobController = TextEditingController(text: '2002-02-22');
    TextEditingController usernameController = TextEditingController(text: 'student_12-');

    expect(() => saveUserData(firstNameController, lastNameController, dobController, usernameController), returnsNormally);
  });

  test('Null values for all fields', () async {
    TextEditingController firstNameController = TextEditingController(text: null);
    TextEditingController lastNameController = TextEditingController(text: null);
    TextEditingController dobController = TextEditingController(text: null);
    TextEditingController usernameController = TextEditingController(text: null);

    expect(() => saveUserData(firstNameController, lastNameController, dobController, usernameController), throwsA(isA<Exception>()));
  });

}


void validateNames(String firstName, String lastName) {
  if (!RegExp(r'^[a-zA-Z]+$').hasMatch(firstName) || !RegExp(r'^[a-zA-Z]+$').hasMatch(lastName)) {
    throw Exception('Only alphabetic characters are allowed');
  }

  if (firstName.isEmpty || lastName.isEmpty) {
    throw Exception('Please fill in all the required fields');
  }
}

void validateDOB(String dob) {
  if (dob == null || dob.isEmpty) {
    throw Exception('Please fill in all the required fields');
  }

  DateTime userDOB = DateTime.parse(dob);
  DateTime now = DateTime.now();
  int age = now.year - userDOB.year;

  if (age < 18) {
    throw Exception('To create an account you must be age 18 or over');
  }
}

void validateUniversity(String? userUniversity) {
  if (userUniversity == null) {
    throw Exception('Please fill in all the required fields');
  }
}

void validateCourse(String? userCourse) {
  if (userCourse == null) {
    throw Exception('Please fill in all the required fields');
  }
}

void validateUsername(String username) {
  if (username.isEmpty) {
    throw Exception('Username cannot be empty');
  }

  if (username.length < 3 || username.length > 15) {
    throw Exception('Username must be between 3 and 15 characters');
  }

  if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(username)) {
    throw Exception('Only letters, numbers, hyphens, and underscores are allowed');
  }
}

void saveUserData(
    TextEditingController firstNameController,
    TextEditingController lastNameController,
    TextEditingController dobController,
    TextEditingController usernameController,
    ) {
  String userFirstName = firstNameController.text.trim();
  String userLastName = lastNameController.text.trim();
  String userDOBString = dobController.text.trim();
  String username = usernameController.text.trim();

  validateNames(userFirstName, userLastName);
  validateDOB(userDOBString);
  validateUsername(username);
}
