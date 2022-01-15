// 🎯 Dart imports:
import 'dart:io';

// 📦 Package imports:
import 'package:http/http.dart' as http;
import 'package:process_run/shell.dart';

// 🌎 Project imports:
import 'package:manager/app/constants/constants.dart';
import 'package:manager/core/libraries/services.dart';

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
  String baseURL = apiData!.data!['scripts']['base_url'];

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
        bool pathAppenderExist =
            await checkFile('$appDir\\scripts\\', 'win32.vbs');
        if (!pathAppenderExist) {
          appenderLink =
              baseURL + apiData!.data!['scripts']['path_appender']['windows'];
          await pathDownload(appenderLink, 'win32.vbs', appDir: appDir);
        }
        await shell.run('"$appDir\\scripts\\win32.vbs" "$path"');
      }

      /// MacOS
      else if (Platform.isMacOS) {
        appenderLink =
            baseURL + apiData!.data!['scripts']['path_appender']['mac'];
        await pathDownload(appenderLink, 'darwin.sh', appDir: appDir);
        await shell.run('"$appDir\\scripts\\darwin.sh" "$path"');
      }

      /// Linux
      else {
        appenderLink =
            baseURL + apiData!.data!['scripts']['path_appender']['linux'];
        await pathDownload(appenderLink, 'linux.sh', appDir: appDir);
        await shell.run('"$appDir\\scripts\\linux.sh" "$path"');
      }
      await logger.file(LogTypeTag.info,
          '$path was set to ${Platform.operatingSystem}\'s env.');
      return true;
    } on OSError catch (osError, s) {
      await logger.file(LogTypeTag.error, 'Path appending failed - OS Error');
      await logger.file(LogTypeTag.error, osError.message.toString(),
          stackTraces: s);
    } on ShellException catch (shellException, s) {
      await logger.file(
          LogTypeTag.error, 'Path appending failed - Shell Exception');
      await logger.file(LogTypeTag.error, shellException.message.toString(),
          stackTraces: s);
    } on FileSystemException catch (fileException, s) {
      await logger.file(
          LogTypeTag.error, 'Path appending failed - File System Exception');
      await logger.file(LogTypeTag.error, fileException.message.toString(),
          stackTraces: s);
    } catch (_, s) {
      await logger.file(LogTypeTag.error, 'Path appending failed - Exception');
      await logger.file(LogTypeTag.error, _.toString(), stackTraces: s);
    }
    return false;
  } else {
    /// Else log a warning stating path was not provided.
    await logger.file(LogTypeTag.warning, 'Path was not provided');
    return false;
  }
}

/// [pathDownload] is a function to download tha path append script.
Future<void> pathDownload(String? scriptLink, String? script,
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
  } on FileSystemException catch (fileException, s) {
    await logger.file(LogTypeTag.error, fileException.message.toString(),
        stackTraces: s);
  } catch (_, s) {
    await logger.file(LogTypeTag.error, 'Exception: ${_.toString()}',
        stackTraces: s);
  }
}
