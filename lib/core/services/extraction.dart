import 'dart:io';

import 'package:manager/app/constants/constants.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:process_run/shell.dart';

/// This function will download the files.
///
/// **EG:**
/// ```dart
/// bool extracted = await unzip(
///   'C:\\Users\\user\\Downloads\\Example.zip',
///   'C:\\Users\\user\\Downloads\\',
/// )
/// ```
///
/// This will return the file `path` after downloading.
Future<bool> unzip(String source, String destination, {String? sw}) async {
  try {
    /// Check for temporary Directory to download files
    bool destinationDir = await checkDir('C:\\', subDirName: 'fluttermatic');

    /// If tmpDir is false, then create a temporary directory.
    if (!destinationDir) {
      await Directory('$destination').create();
      await logger.file(LogTypeTag.INFO, 'Created $destination directory.');
    } else {
      if (destination.split('\\').length > 2) {
        bool checkDestination = await checkDir('C:\\fluttermatic\\',
            subDirName: destination.split('\\').last);
        if (!checkDestination) {
          await Directory(destination).create();
          await logger.file(LogTypeTag.INFO,
              'Created ${destination.split('\\').last} directory.');
        }
      }
    }
    await logger.file(
        LogTypeTag.INFO, 'Started extracting $source to $destination');
    String extractionType = source.endsWith('.tar.gz')
        ? 'z'
        : source.endsWith('.tar.bz2') || source.endsWith('.tar.zx')
            ? 'j'
            : '';
    await shell.run('tar -${extractionType}xf "$source" -C "$destination"');
    await logger.file(
        LogTypeTag.INFO, 'Successfully extracted $source to $destination');
    await File(source).delete(recursive: true);
    await logger.file(LogTypeTag.INFO, 'Cleaned ${source.split('\\').last}');
    return true;
  } on OSError catch (osError) {
    await File(source).delete(recursive: true);
    await logger.file(LogTypeTag.ERROR, 'Extracting failed - OS Error',
        stackTraces: null);
    await logger.file(LogTypeTag.ERROR, osError.message.toString());
    return false;
  } on ShellException catch (shellException) {
    await File(source).delete(recursive: true);
    await logger.file(LogTypeTag.ERROR, 'Extracting failed - Shell Exception',
        stackTraces: null);
    await logger.file(LogTypeTag.ERROR, shellException.message.toString());
    return false;
  } on FileSystemException catch (fileException) {
    await File(source).delete(recursive: true);
    await logger.file(
        LogTypeTag.ERROR, 'Extracting failed - File System Exception',
        stackTraces: null);
    await logger.file(LogTypeTag.ERROR, fileException.message.toString());
    return false;
  } catch (e) {
    await File(source).delete(recursive: true);
    await logger.file(LogTypeTag.ERROR, 'Extracting failed - ${e.toString()}',
        stackTraces: null);
    return false;
  }
}
