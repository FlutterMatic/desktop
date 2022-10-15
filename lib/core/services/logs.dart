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
    } on FileSystemException catch (e, s) {
      console.log('${e.message}\n STACKTRACES: $s');
      throw e.message;
    } on OSError catch (e, s) {
      console.log('${e.message}\n STACKTRACES: $s');
      throw e.message;
    } catch (e, s) {
      console.log('$e\n STACKTRACES: $s');
      throw e.toString();
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
    Object? error,
    StackTrace? stackTrace,
    Directory? logDir,
  }) async {
    File file = await currentFile(logDir);
    DateTime now = DateTime.now();

    String addZero(int number) {
      return number < 10 ? '0$number' : number.toString();
    }

    String baseData =
        '[${addZero(now.hour)}:${addZero(now.minute)}:${addZero(now.second)}] - $message\n';

    if (error != null) {
      baseData += ' - [Error] - $error';
    }

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
            '''WARNING $baseData
            [StackTraces] - ${stackTrace ?? StackTrace.empty}\n''',
            mode: FileMode.writeOnlyAppend,
          );
          break;
        case LogTypeTag.error:
          if (kDebugMode || kProfileMode) console.log('ERROR $baseData');
          await file.writeAsString(
            '''ERROR $baseData
            [StackTraces] - ${stackTrace ?? StackTrace.fromString(StackTrace.current.toString())}\n''',
            mode: FileMode.writeOnlyAppend,
          );
          break;
      }
    } on FileSystemException catch (e, s) {
      console.log(
          '${e.message}\n-FATAL: [FileSystemException] THIS ERROR OCCURRED WHEN TRYING TO WRITE A LOG.\n- StackTraces: $s');
    } on OSError catch (e, s) {
      console.log(
          '${e.message}\n-FATAL: [OSError] THIS ERROR OCCURRED WHEN TRYING TO WRITE A LOG.\n- StackTraces: $s');
    } catch (e, s) {
      console.log(
          '$e\n-FATAL: [Error] THIS ERROR OCCURRED WHEN TRYING TO WRITE A LOG.\n- StackTraces: $s');
    }
  }
}
