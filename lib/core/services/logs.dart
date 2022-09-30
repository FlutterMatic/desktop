// 🎯 Dart imports:
import 'dart:developer' as console;
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';

// 📦 Package imports:
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

enum LogTypeTag { info, warning, error }

final Logger logger = Logger();

class Logger {
  static Future<String> _localPath(Directory? dir) async {
    try {
      Directory applicationDirectory;
      applicationDirectory = dir ?? await getApplicationSupportDirectory();
      return '${applicationDirectory.path}\\logs';
    } on FileSystemException catch (_, s) {
      console.log('${_.message}\n STACKTRACES: $s');
      throw _.message;
    } on OSError catch (_, s) {
      console.log('${_.message}\n STACKTRACES: $s');
      throw _.message;
    } catch (_, s) {
      console.log('$_\n STACKTRACES: $s');
      throw _.toString();
    }
  }

  static Future<File> currentFile(Directory? dir) async {
    String path = await _localPath(dir);
    String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    if (!kReleaseMode) {
      return File('$path\\fm-${Platform.operatingSystem}-debug-$date.log');
    } else {
      return File('$path\\fm-${Platform.operatingSystem}-$date.log');
    }
  }

  /// Logs to the log file for later to find any issues user my file on GitHub
  /// and we ask them for this log file to help in finding the cause of the
  /// issue.
  Future<void> file(
    LogTypeTag tag,
    String? message, {
    StackTrace? stackTraces,
    Directory? logDir,
  }) async {
    File file = await currentFile(logDir);
    DateTime now = DateTime.now();

    String addZero(int number) {
      return number < 10 ? '0$number' : number.toString();
    }

    String baseData =
        '[${addZero(now.hour)}:${addZero(now.minute)}:${addZero(now.second)}] - $message\n';

    try {
      switch (tag) {
        case LogTypeTag.info:
          if (kDebugMode || kProfileMode) console.log('INFORMATION $baseData');
          await file.writeAsString(
            '''INFORMATION $baseData''',
            mode: FileMode.writeOnlyAppend,
          );
          break;
        case LogTypeTag.warning:
          if (kDebugMode || kProfileMode) console.log('WARNING $baseData');
          await file.writeAsString(
            '''WARNING $baseData[StackTraces] - ${stackTraces ?? StackTrace.empty}\n''',
            mode: FileMode.writeOnlyAppend,
          );
          break;
        case LogTypeTag.error:
          if (kDebugMode || kProfileMode) console.log('ERROR $baseData');
          await file.writeAsString(
            '''ERROR $baseData[StackTraces] - ${stackTraces ?? StackTrace.fromString(StackTrace.current.toString())}\n''',
            mode: FileMode.writeOnlyAppend,
          );
          break;
      }
    } on FileSystemException catch (_, s) {
      console.log(
          '${_.message}\n- [FileSystemException] This occurred when trying to write a log.\n- StackTraces: $s');
    } on OSError catch (_, s) {
      console.log(
          '${_.message}\n- [OSError] This occurred when trying to write a log.\n- StackTraces: $s');
    } catch (_, s) {
      console.log(
          '$_\n- This occurred when trying to write a log.\n- StackTraces: $s');
    }
  }
}
