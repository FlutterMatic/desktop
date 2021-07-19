import 'dart:io';

import 'package:manager/core/services/logs.dart';

/// Checks whether the directory exists in the path provided or not.
///
/// **EG:**
/// ```dart
/// bool imgFolderExists = await checkDir(
///   'C:\\Users\\user\\Pictures\\',
///   'Images1',
/// );
/// ```
/// This function will return `true` or `false`.
Future<bool> checkDir(String dirPath, {required String subDirName}) async {
  Directory dir = Directory(dirPath);
  try {
    await for (FileSystemEntity entity in dir.list()) {
      if (entity.path.endsWith(subDirName)) {
        await logger.file(
            LogTypeTag.INFO, '$subDirName directory found at ${entity.path}');
        return true;
      }
    }
    await logger.file(LogTypeTag.INFO, '$subDirName directory not found.');
    return false;
  } on FileSystemException catch (fileException, s) {
    await logger.file(LogTypeTag.ERROR, fileException.message.toString(),
        stackTraces: s);
    return false;
  } catch (e, s) {
    await logger.file(LogTypeTag.ERROR, e.toString(), stackTraces: s);
    return false;
  }
}
