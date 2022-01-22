// 🎯 Dart imports:
import 'dart:io';

// 📦 Package imports:
import 'package:flutter/cupertino.dart';
import 'package:fluttermatic/core/libraries/notifiers.dart';
import 'package:process_run/shell.dart';
import 'package:provider/provider.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/core/libraries/services.dart';

// import 'package:process_run/shell.dart';

/// This function will download the files.
///
/// **Example:**
/// ```dart
/// bool extracted = await unzip(
///   'C:\\Users\\user\\Downloads\\Example.zip',
///   'C:\\Users\\user\\Downloads\\',
/// )
/// ```
///
/// This will return the file `path` after downloading.
Future<bool> unzip(BuildContext context, String source, String destination) async {
  try {
    String _drive = context.read<SpaceCheck>().drive;
    /// Check for temporary Directory to download files
    bool destinationDir = await checkDir('$_drive:\\', subDirName: 'fluttermatic');

    /// If tmpDir is false, then create a temporary directory.
    if (!destinationDir) {
      await Directory(destination).create(recursive: true);
      await logger.file(LogTypeTag.info, 'Created $destination directory.');
    } else {
      if (destination.split('\\').length > 2) {
        bool checkDestination = await checkDir('$_drive:\\fluttermatic\\',
            subDirName: destination.split('\\').last);
        if (!checkDestination) {
          await Directory(destination).create(recursive: true);
          await logger.file(LogTypeTag.info,
              'Created ${destination.split('\\').last} directory.');
        }
      }
    }
    await logger.file(
        LogTypeTag.info, 'Started extracting $source to $destination');
    String extractionType = source.endsWith('.tar.gz')
        ? 'z'
        : source.endsWith('.tar.bz2') || source.endsWith('.tar.zx')
            ? 'j'
            : '';
    await shell.run('tar -${extractionType}xf "$source" -C "$destination"');
    await logger.file(
        LogTypeTag.info, 'Successfully extracted $source to $destination');
    await File(source).delete(recursive: true);
    await logger.file(LogTypeTag.error, 'Cleaned ${source.split('\\').last}');
    return true;
  } on OSError catch (_, s) {
    await File(source).delete(recursive: true);
    await logger.file(LogTypeTag.error, 'Extracting failed - OS Error: $_',
        stackTraces: s);
    await logger.file(LogTypeTag.error, _.message.toString());
  } on ShellException catch (_, s) {
    await File(source).delete(recursive: true);
    await logger.file(LogTypeTag.error, 'Extracting failed - Shell Exception: $_',
        stackTraces: s);
    await logger.file(LogTypeTag.error, _.message.toString());
  } on FileSystemException catch (_, s) {
    await File(source).delete(recursive: true);
    await logger.file(
        LogTypeTag.error, 'Extracting failed - File System Exception: $_',
        stackTraces: s);
    await logger.file(LogTypeTag.error, _.message.toString());
  } catch (_, s) {
    await File(source).delete(recursive: true);
    await logger.file(LogTypeTag.error, 'Extracting failed - ${_.toString()}',
        stackTraces: s);
  }
  return false;
}
