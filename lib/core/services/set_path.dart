import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:manager/app/constants/constants.dart';
import 'package:manager/core/libraries/services.dart';
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
  String base_url = apiData!.data!['scripts']['base_url'];

  /// Check if given path is null.
  if (path != null) {
    try {
      /// Check the platform.
      /// Windows
      if (Platform.isWindows) {
        List<ProcessResult> envPATH = await shell.run('echo %PATH%');
        if (envPATH[0].stdout.contains(path)) {
          await logger.file(
              LogTypeTag.info, '$path already exists in env PATH variable.');
          return true;
        }
        bool path_appender_exist =
            await checkFile('$appDir\\scripts\\', 'win32.vbs');
        if (!path_appender_exist) {
          appenderLink =
              base_url + apiData!.data!['scripts']['path_appender']['windows'];
          await path_download(appenderLink, 'win32.vbs', appDir: appDir);
        }
        await shell.run('"$appDir\\scripts\\win32.vbs" "$path"');
      }

      /// MacOS
      else if (Platform.isMacOS) {
        appenderLink =
            base_url + apiData!.data!['scripts']['path_appender']['mac'];
        await path_download(appenderLink, 'darwin.sh', appDir: appDir);
        await shell.run('"$appDir\\scripts\\darwin.sh" "$path"');
      }

      /// Linux
      else {
        appenderLink =
            base_url + apiData!.data!['scripts']['path_appender']['linux'];
        await path_download(appenderLink, 'linux.sh', appDir: appDir);
        await shell.run('"$appDir\\scripts\\linux.sh" "$path"');
      }
      await logger.file(LogTypeTag.info,
          '$path was set to ${Platform.operatingSystem}\'s env.');
      return true;
    } on OSError catch (osError) {
      await logger.file(LogTypeTag.error, 'Path appending failed - OS Error');
      await logger.file(LogTypeTag.error, osError.message.toString());
      return false;
    } on ShellException catch (shellException) {
      await logger.file(
          LogTypeTag.error, 'Path appending failed - Shell Exception');
      await logger.file(LogTypeTag.error, shellException.message.toString());
      return false;
    } on FileSystemException catch (fileException) {
      await logger.file(
          LogTypeTag.error, 'Path appending failed - File System Exception');
      await logger.file(LogTypeTag.error, fileException.message.toString());
      return false;
    } catch (e) {
      await logger.file(LogTypeTag.error, 'Path appending failed - Exception');
      await logger.file(LogTypeTag.error, e.toString());
      return false;
    }
  }

  /// Else log a warning stating path was not provided.
  else {
    await logger.file(LogTypeTag.warning, 'Path was not provided');
    return false;
  }
}

/// [path_download] is a function to download tha path appened script.
Future<void> path_download(String? scriptLink, String? script,
    {String? appDir}) async {
  try {
    Directory pathDir =
        await Directory('$appDir\\scripts\\').create(recursive: true);
    await http.get(Uri.parse(scriptLink!)).then((http.Response response) async {
      if (response.statusCode == 200) {
        await File(pathDir.path + script!).writeAsBytes(response.bodyBytes);
      } else {
        await logger.file(LogTypeTag.error,
            'Response code is ${response.statusCode} for downloading script.');
      }
    });
  } on FileSystemException catch (fileException) {
    await logger.file(LogTypeTag.error, fileException.message.toString());
  } catch (e) {
    await logger.file(LogTypeTag.error, 'Exception : ${e.toString()}');
  }
}
