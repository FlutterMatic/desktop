// 🎯 Dart imports:
import 'dart:developer' as console;
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';

// 📦 Package imports:
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

enum LogTypeTag {
  info,
  warning,
  error,
}

Logger logger = Logger();

class Logger {
  Future<String> get _localPath async {
    try {
      Directory applicationDirectory = await getApplicationSupportDirectory();
      return applicationDirectory.path;
    } on FileSystemException catch (fileSystemException) {
      console.log(fileSystemException.message);
      throw fileSystemException.message;
    } on OSError catch (osError) {
      console.log(osError.message);
      throw osError.message;
    } catch (error) {
      console.log(error.toString());
      throw error.toString();
    }
  }

  Future<File> get _localFile async {
    String path = await _localPath;
    String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return (kDebugMode || kProfileMode)
        ? File('$path/fluttermatic-${Platform.operatingSystem}-debug-$date.log')
        : File('$path/fluttermatic-${Platform.operatingSystem}-$date.log');
  }

  /// Logs to the log file for later to find any issues user my file on GitHub
  /// and we ask them for this log file to help in finding the cause of the
  /// issue.
  Future<void> file(LogTypeTag tag, String? message,
      {StackTrace? stackTraces}) async {
    File file = await _localFile;
    DateTime _now = DateTime.now();
    String _baseData =
        '[${_now.hour}:${_now.minute}:${_now.second}] - $message\n';
    try {
      switch (tag) {
        case LogTypeTag.info:
          if (kDebugMode || kProfileMode) console.log('INFORMATION $_baseData');
          await file.writeAsString(
            '''INFORMATION $_baseData''',
            mode: FileMode.writeOnlyAppend,
          );
          break;
        case LogTypeTag.warning:
          if (kDebugMode || kProfileMode) console.log('WARNING $_baseData');
          await file.writeAsString(
            '''WARNING $_baseData[StackTraces] - ${stackTraces ?? StackTrace.empty}\n''',
            mode: FileMode.writeOnlyAppend,
          );
          break;
        case LogTypeTag.error:
          if (kDebugMode || kProfileMode) console.log('ERROR $_baseData');
          await file.writeAsString(
            '''ERROR $_baseData[StackTraces] - ${stackTraces ?? StackTrace.fromString(StackTrace.current.toString())}\n''',
            mode: FileMode.writeOnlyAppend,
          );
          break;
      }
    } on FileSystemException catch (fileSystemException) {
      console.log(fileSystemException.message);
      throw fileSystemException.message;
    } on OSError catch (osError) {
      console.log(osError.message);
      throw osError.message;
    } catch (error) {
      console.log(error.toString());
      throw error.toString();
    }
  }
}
