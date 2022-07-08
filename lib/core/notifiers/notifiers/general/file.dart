import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/core/notifiers/models/state/api/fm_api.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:process_run/shell.dart';
import 'package:http/http.dart' as http;
import 'package:fluttermatic/core/notifiers/out.dart';

class FileNotifier extends StateNotifier<void> {
  final Reader read;

  FileNotifier(this.read) : super(null);

  /// Checks whether the directory exists in the path provided or not.
  ///
  /// **EG:**
  /// ```dart
  /// bool imgFolderExists = await checkDir(
  ///   'C:\\Users\\user\\Pictures\\',
  ///   'Images1',
  /// );
  /// ```
  /// This function will return `true` or `false`.
  Future<bool> checkDir(String dirPath, {required String subDirName}) async {
    Directory dir = Directory(dirPath);

    try {
      await for (FileSystemEntity entity in dir.list(recursive: true)) {
        if (entity.path.endsWith(subDirName)) {
          await logger.file(
              LogTypeTag.info, '$subDirName directory found at ${entity.path}');
          return true;
        }
      }
      await logger.file(LogTypeTag.info, '$subDirName directory not found.');
      return false;
    } on FileSystemException catch (_, s) {
      await logger.file(LogTypeTag.error, _.message.toString(), stackTraces: s);
      return false;
    } catch (_, s) {
      await logger.file(LogTypeTag.error, _.toString(), stackTraces: s);
      return false;
    }
  }

  /// Checks whether the file exists in the directory or not, recursively.
  ///
  /// **EG:**
  /// ```dart
  /// bool imgExists = await checkFile(
  ///   'C:\\Users\\user\\Pictures',
  ///   'image1.jpeg',
  /// );
  /// ```
  /// This function will return `true` or `false`.
  Future<bool> fileExists(String dirPath, String fileName) async {
    Directory dir = Directory(dirPath);
    try {
      await for (FileSystemEntity entity in dir.list(recursive: true)) {
        if (entity.path.endsWith(fileName)) {
          await logger.file(LogTypeTag.info,
              '$fileName is at ${entity.path.replaceAll(fileName, '')}');

          return true;
        }
      }

      await logger.file(LogTypeTag.info, '$fileName file not found.');
      return false;
    } on FileSystemException catch (_, s) {
      await logger.file(LogTypeTag.error, _.message.toString(), stackTraces: s);
      return false;
    } catch (_, s) {
      await logger.file(LogTypeTag.error, _.toString(), stackTraces: s);
      return false;
    }
  }

  /// Gets the file path if it exists, recursively.
  ///
  /// **EG:**
  /// Checking for `flutter.bat` file in the `C:\src` directory.
  /// ```dart
  /// String? filePath = await getFilePath(
  ///   'C:\\src\\',
  ///   'flutter.bat',
  /// );
  /// ```
  /// **OUTPUT:**
  ///
  /// `C:\src\flutter\bin\flutter.bat`
  ///
  ///
  /// **EG:**
  /// Checking for `java.exe` file in the `C:\src` directory.
  /// ```dart
  /// String? filePath = await getFilePath(
  ///   'C:\\src\\',
  ///   'java.exe',
  /// );
  /// ```
  /// **OUTPUT:**
  ///
  /// If file doesn't exist, this function will return `null`.
  /// Otherwise, this function will return the `path` of the file.
  Future<String?> searchFile(String dirPath, String fileName) async {
    Directory dir = Directory(dirPath);

    try {
      await for (FileSystemEntity entity in dir.list(recursive: true)) {
        if (entity.path.contains(fileName)) {
          await logger.file(LogTypeTag.info,
              '$fileName found at ${entity.path.replaceAll(fileName, '')}');

          return entity.path.replaceAll(fileName, '');
        }
      }

      await logger.file(LogTypeTag.info, '$fileName file not found.');
    } on FileSystemException catch (_, s) {
      await logger.file(LogTypeTag.error, _.message.toString(), stackTraces: s);
    } catch (_, s) {
      await logger.file(LogTypeTag.error, _.toString(), stackTraces: s);
    }

    return null;
  }

  /// Sets the path of a directory to env path variable.
  ///
  /// **EG:**
  /// ```dart
  /// bool addedEnvPath = await setPath(
  ///       'C:\\fluttermatic\\flutter\\bin\\',
  ///       applicationDirectory,
  ///   );
  /// ```
  ///
  /// This function will return `true` or `false` if successful or not.
  Future<bool> setPath(String? path, [String? appDir]) async {
    /// Appending script link.
    String? appenderLink;
    String baseURL =
        read(fmAPIStateNotifier).apiMap.data!['scripts']['base_url'];

    FlutterMaticAPIState apiState = read(fmAPIStateNotifier);

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
              await fileExists('$appDir\\scripts\\', 'win32.vbs');
          if (!pathAppenderExist) {
            appenderLink = baseURL +
                apiState.apiMap.data!['scripts']['path_appender']['windows'];
            await pathDownload(appenderLink, 'win32.vbs', appDir: appDir);
          }
          await shell.run('"$appDir\\scripts\\win32.vbs" "$path"');
        }

        /// MacOS
        else if (Platform.isMacOS) {
          appenderLink = baseURL +
              apiState.apiMap.data!['scripts']['path_appender']['mac'];
          await pathDownload(appenderLink, 'darwin.sh', appDir: appDir);
          await shell.run('"$appDir\\scripts\\darwin.sh" "$path"');
        }

        /// Linux
        else {
          appenderLink = baseURL +
              apiState.apiMap.data!['scripts']['path_appender']['linux'];
          await pathDownload(appenderLink, 'linux.sh', appDir: appDir);
          await shell.run('"$appDir\\scripts\\linux.sh" "$path"');
        }
        await logger.file(LogTypeTag.info,
            '$path was set to ${Platform.operatingSystem}\'s env.');
        return true;
      } on OSError catch (_, s) {
        await logger.file(LogTypeTag.error, 'Path appending failed - OS Error');
        await logger.file(LogTypeTag.error, _.message.toString(),
            stackTraces: s);
      } on ShellException catch (_, s) {
        await logger.file(
            LogTypeTag.error, 'Path appending failed - Shell Exception');
        await logger.file(LogTypeTag.error, _.message.toString(),
            stackTraces: s);
      } on FileSystemException catch (_, s) {
        await logger.file(
            LogTypeTag.error, 'Path appending failed - File System Exception');
        await logger.file(LogTypeTag.error, _.message.toString(),
            stackTraces: s);
      } catch (_, s) {
        await logger.file(
            LogTypeTag.error, 'Path appending failed - Exception');
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
      await http
          .get(Uri.parse(scriptLink!))
          .then((http.Response response) async {
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

  /// This function will extract the files to the specified destination.
  ///
  /// **Example:**
  /// ```dart
  /// bool extracted = await unzip(
  ///   'C:\\Users\\user\\Downloads\\Example.zip',
  ///   'C:\\Users\\user\\Downloads\\',
  /// )
  /// ```
  ///
  /// This will return `true` or `false` if successful.
  Future<bool> unzip(String source, String destination) async {
    try {
      String drive = read(spaceStateController).drive;

      /// Check for temporary Directory to download files
      bool destinationDir =
          await checkDir('$drive:\\', subDirName: 'fluttermatic');

      /// If tmpDir is false, then create a temporary directory.
      if (!destinationDir) {
        await Directory(destination).create(recursive: true);
        await logger.file(LogTypeTag.info, 'Created $destination directory.');
      } else {
        if (destination.split('\\').length > 2) {
          bool checkDestination = await checkDir('$drive:\\fluttermatic\\',
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

      await logger.file(
          LogTypeTag.error, 'Extracting failed - Shell Exception: $_',
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
}
