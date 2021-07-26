import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:manager/app/constants/constants.dart';
import 'package:manager/core/services/logs.dart';
import 'package:process_run/shell.dart';

/// Sets the path of a directory to env path variable.
///
/// **EG:**
/// ```dart
/// bool addedEnvPath = await setPath(
///       'C:\\fluttermatic\\flutter\\bin\\',
///       applicationDirectory,
///   );
/// ```
/// This function will return [Future] `true` or `false`.
Future<bool> setPath(String? path, [String? appDir]) async {
  /// Appending script link.
  String? appenderLink;

  /// Check if given path is null.
  if (path != null) {
    try {
      /// Check the platform.
      /// Windows
      if (Platform.isWindows) {
        List<ProcessResult> envPATH = await shell.run('echo %PATH%');
        if (envPATH.contains(path)) {
          await logger.file(
              LogTypeTag.INFO, '$path already exists in env PATH variable.');
          return false;
        }
        appenderLink = apiData!.data!['path_appender']['windows'];
        await path_download(appenderLink, 'win32.vbs', appDir: appDir);
        await shell.run('$appDir\\path\\win32.vbs "$path"');
      }

      /// MacOS
      else if (Platform.isMacOS) {
        appenderLink = apiData!.data!['path_appender']['mac'];
        await path_download(appenderLink, 'darwin.sh', appDir: appDir);
        await shell.run('$appDir\\path\\darwin.sh "$path"');
      }

      /// Linux
      else {
        appenderLink = apiData!.data!['path_appender']['linux'];
        await path_download(appenderLink, 'linux.sh', appDir: appDir);
        await shell.run('$appDir\\path\\linux.sh "$path"');
      }
      await logger.file(LogTypeTag.INFO,
          '$path was set to ${Platform.operatingSystem}\'s env.');
      return true;
    } on OSError catch (osError) {
      await logger.file(LogTypeTag.ERROR, 'Path appending failed - OS Error');
      await logger.file(LogTypeTag.ERROR, osError.message.toString());
      return false;
    } on ShellException catch (shellException) {
      await logger.file(
          LogTypeTag.ERROR, 'Path appending failed - Shell Exception');
      await logger.file(LogTypeTag.ERROR, shellException.message.toString());
      return false;
    } on FileSystemException catch (fileException) {
      await logger.file(
          LogTypeTag.ERROR, 'Path appending failed - File System Exception');
      await logger.file(LogTypeTag.ERROR, fileException.message.toString());
      return false;
    } catch (e) {
      await logger.file(LogTypeTag.ERROR, 'Path appending failed - Exception');
      await logger.file(LogTypeTag.ERROR, e.toString());
      return false;
    }
  }

  /// Else log a warning stating path was not provided.
  else {
    await logger.file(LogTypeTag.WARNING, 'Path was not provided');
    return false;
  }
}

/// [path_download] is a function to download tha path appened script.
Future<void> path_download(String? scriptLink, String? script,
    {String? appDir}) async {
  try {
    Directory pathDir = await Directory('$appDir\\path').create();
    await http.get(Uri.parse(scriptLink!)).then((http.Response response) async {
      if (response.statusCode == 200) {
        await File(pathDir.path + '\\' + script!)
            .writeAsBytes(response.bodyBytes);
      } else {
        await logger.file(LogTypeTag.ERROR,
            'Response code is ${response.statusCode} for downloading script.');
      }
    });
  } on FileSystemException catch (fileException) {
    await logger.file(LogTypeTag.ERROR, fileException.message.toString());
  } catch (e) {
    await logger.file(LogTypeTag.ERROR, 'Exception : ${e.toString()}');
  }
}
