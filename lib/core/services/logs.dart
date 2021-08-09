import 'package:path_provider/path_provider.dart';
import 'dart:developer' as console;
import 'package:intl/intl.dart';
import 'dart:io';

enum LogTypeTag {
  INFO,
  WARNING,
  ERROR,
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
    return File('$path/fluttermatic-${Platform.operatingSystem}-$date.log');
  }

  /// Logs to the log file for later to find any issues user my file on GitHub
  /// and we ask them for this log file to help in finding the cause of the
  /// issue.
  Future<void> file(LogTypeTag tag, String? message,
      {StackTrace? stackTraces}) async {
    File file = await _localFile;
    DateTime _now = DateTime.now();
    String _baseData = '[${_now.hour}:${_now.minute}:${_now.second}] - $message\n';
    try {
      switch (tag) {
        case LogTypeTag.INFO:
          console.log(
              'INFORMATION $_baseData');
          await file.writeAsString(
            '''INFORMATION $_baseData''',
            mode: FileMode.writeOnlyAppend,
          );
          break;
        case LogTypeTag.WARNING:
          console.log(
              'WARNING $_baseData');
          await file.writeAsString(
            '''WARNING $_baseData[StackTraces] - ${stackTraces ?? StackTrace.empty}\n''',
            mode: FileMode.writeOnlyAppend,
          );
          break;
        case LogTypeTag.ERROR:
          console.log(
              'ERROR $_baseData');
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
