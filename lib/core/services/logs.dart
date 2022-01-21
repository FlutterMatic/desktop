// 🎯 Dart imports:
import 'dart:developer' as console;
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';

// 📦 Package imports:
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

enum LogTypeTag { info, warning, error }

Logger logger = Logger();

class Logger {
  static Future<String> _localPath() async {
    try {
      Directory _applicationDirectory = await getApplicationSupportDirectory();
      return _applicationDirectory.path + '\\logs';
    } on FileSystemException catch (_, s) {
      console.log(_.message + '\n STACKTRACES: ' + s.toString());
      throw _.message;
    } on OSError catch (_, s) {
      console.log(_.message + '\n STACKTRACES: ' + s.toString());
      throw _.message;
    } catch (_, s) {
      console.log(_.toString() + '\n STACKTRACES: ' + s.toString());
      throw _.toString();
    }
  }

  static Future<File> _localFile() async {
    String _path = await _localPath();
    String _date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (kDebugMode || kProfileMode) {
      return File(_path + '\\fm-${Platform.operatingSystem}-debug-$_date.log');
    } else {
      return File(_path + '\\fm-${Platform.operatingSystem}-$_date.log');
    }
  }

  /// Logs to the log file for later to find any issues user my file on GitHub
  /// and we ask them for this log file to help in finding the cause of the
  /// issue.
  Future<void> file(
    LogTypeTag tag,
    String? message, {
    StackTrace? stackTraces,
  }) async {
    File _file = await _localFile();
    DateTime _now = DateTime.now();
    String _baseData =
        '[${_now.hour}:${_now.minute}:${_now.second}] - $message\n';
    try {
      switch (tag) {
        case LogTypeTag.info:
          if (kDebugMode || kProfileMode) console.log('INFORMATION $_baseData');
          await _file.writeAsString(
            '''INFORMATION $_baseData''',
            mode: FileMode.writeOnlyAppend,
          );
          break;
        case LogTypeTag.warning:
          if (kDebugMode || kProfileMode) console.log('WARNING $_baseData');
          await _file.writeAsString(
            '''WARNING $_baseData[StackTraces] - ${stackTraces ?? StackTrace.empty}\n''',
            mode: FileMode.writeOnlyAppend,
          );
          break;
        case LogTypeTag.error:
          if (kDebugMode || kProfileMode) console.log('ERROR $_baseData');
          await _file.writeAsString(
            '''ERROR $_baseData[StackTraces] - ${stackTraces ?? StackTrace.fromString(StackTrace.current.toString())}\n''',
            mode: FileMode.writeOnlyAppend,
          );
          break;
      }
    } on FileSystemException catch (_, s) {
      console.log(_.message +
          '\n- This occurred when trying to write a log.' +
          '\n- StackTraces: $s');
    } on OSError catch (_, s) {
      console.log(_.message +
          '\n- This occurred when trying to write a log.' +
          '\n- StackTraces: $s');
    } catch (_, s) {
      console.log(_.toString() +
          '\n- This occurred when trying to write a log.' +
          '\n- StackTraces: $s');
    }
  }
}
