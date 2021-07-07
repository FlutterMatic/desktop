import 'package:path_provider/path_provider.dart'
    show getApplicationSupportDirectory;
import 'dart:developer' as console;
import 'package:intl/intl.dart' show DateFormat;
import 'dart:io'
    show Directory, File, FileMode, FileSystemException, OSError, Platform;

enum LogTypeTag { INFO, WARNING, ERROR }

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

  Future<void> file(LogTypeTag? tag, String? message) async {
    File file = await _localFile;
    DateTime _now = DateTime.now();
    try {
      if (tag == LogTypeTag.INFO) {
        console.log(
            'INFORMATION [${_now.hour}:${_now.minute}:${_now.second}] - $message\n');
        await file.writeAsString(
          '''INFORMATION [${_now.hour}:${_now.minute}:${_now.second}] - $message\n[StackTraces] - ${StackTrace.fromString(StackTrace.current.toString())}\n''',
          mode: FileMode.writeOnlyAppend,
        );
      }
      if (tag == LogTypeTag.WARNING) {
        console.log(
            'WARNING [${_now.hour}:${_now.minute}:${_now.second}] - $message\n');
        await file.writeAsString(
          '''WARNING [${_now.hour}:${_now.minute}:${_now.second}] - $message\n[StackTraces] - ${StackTrace.empty}\n''',
          mode: FileMode.writeOnlyAppend,
        );
      } else if (tag == LogTypeTag.ERROR) {
        console.log(
            'ERROR [${_now.hour}:${_now.minute}:${_now.second}] - $message\n');
        await file.writeAsString(
          '''ERROR [${_now.hour}:${_now.minute}:${_now.second}] - $message\n[StackTraces] - ${StackTrace.empty}\n''',
          mode: FileMode.writeOnlyAppend,
        );
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
