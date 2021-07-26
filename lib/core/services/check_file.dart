import 'dart:io';

import 'package:manager/core/libraries/services.dart';

/// Checks whether the file exists in the directory or not.
///
/// **EG:**
/// ```dart
/// bool imgExists = await checkFile(
///   'C:\\Users\\user\\Pictures',
///   'image1.png',
/// );
/// ```
/// This function will return `true` or `false`.
Future<bool> checkFile(String dirPath, String fileName) async {
  Directory dir = Directory(dirPath);
  try {
    await for (FileSystemEntity entity
        in dir.list(recursive: true, followLinks: false)) {
      if (entity.path.endsWith(fileName)) {
        await logger.file(LogTypeTag.INFO,
            '$fileName is at ${entity.path.replaceAll(fileName, '')}');
        return true;
      }
    }
    await logger.file(LogTypeTag.INFO, '$fileName file not found.');
    return false;
  } on FileSystemException catch (fileException) {
    await logger.file(LogTypeTag.ERROR, fileException.message.toString());
    return false;
  } catch (e) {
    await logger.file(LogTypeTag.ERROR, e.toString());
    return false;
  }
}

/// Gets the file path if it exists.
///
/// **EG:**
/// Checking for `flutter.bat` file in the `C:\src` directory.
/// ```dart
/// String? filePath = await getFilePath(
///   'C:\\src\\',
///   'flutter.bat',
/// );
/// ```
/// **OUTPUT:**
///
/// `C:\src\flutter\bin\flutter.bat`
///
///
/// **EG:**
/// Checking for `java.exe` file in the `C:\src` directory.
/// ```dart
/// String? filePath = await getFilePath(
///   'C:\\src\\',
///   'java.exe',
/// );
/// ```
/// **OUTPUT:**
///
/// As the file doesn't exist, this function will return `null`.
/// `null`
///
/// This function will return the `path` of
/// the file if exists or `null` if it doesn't.
Future<String?> getFilePath(String dirPath, String fileName) async {
  Directory dir = Directory(dirPath);
  try {
    await for (FileSystemEntity entity
        in dir.list(recursive: true, followLinks: false)) {
      if (entity.path.contains(fileName)) {
        await logger.file(LogTypeTag.INFO,
            '$fileName found at ${entity.path.replaceAll(fileName, '')}');
        return entity.path.replaceAll(fileName, '');
      }
    }
    await logger.file(LogTypeTag.INFO, '$fileName file not found.');
    return null;
  } on FileSystemException catch (fileException) {
    await logger.file(LogTypeTag.ERROR, fileException.message.toString());
    return null;
  } catch (e) {
    await logger.file(LogTypeTag.ERROR, e.toString());
    return null;
  }
}