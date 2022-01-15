// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell.dart';
import 'package:provider/provider.dart';
import 'package:pub_semver/src/version.dart';

// 🌎 Project imports:
import 'package:manager/app/constants/constants.dart';
import 'package:manager/app/constants/enum.dart';
import 'package:manager/app/constants/shared_pref.dart';
import 'package:manager/core/libraries/models.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:manager/meta/utils/bin/tools/java.bin.dart';
import 'package:manager/meta/utils/shared_pref.dart';

/// [JavaNotifier] class is a [ValueNotifier]
/// for java SDK checks.
class JavaNotifier extends ChangeNotifier {
  /// [javaVersion] value holds java version information
  Version? javaVersion;
  Progress _progress = Progress.none;
  Progress get progress => _progress;
  Java _sw = Java.jdk;
  Java get sw => _sw;

  /// Check java exists in the system or not.
  Future<void> checkJava(BuildContext context, FluttermaticAPI? api) async {
    try {
      _progress = Progress.started;
      notifyListeners();

      /// Make a fake delay of 1 second such that UI looks cool.
      await Future<dynamic>.delayed(const Duration(seconds: 1));

      /// The compressed archive type.
      String? archiveType = Platform.isLinux ? 'tar.gz' : 'zip';
      _progress = Progress.checking;
      notifyListeners();

      /// Application supporting Directory
      Directory _dir = await getApplicationSupportDirectory();

      /// Checking for Java path,
      /// returns path to java or null if it doesn't exist.
      String? _javaPath = await which('java');

      /// Check if path is null, if so, we need to download it.
      if (_javaPath == null) {
        await logger.file(
            LogTypeTag.warning, 'Java not installed in the system.');
        _progress = Progress.downloading;
        notifyListeners();

        bool _javaDir =
            await checkDir('C:\\fluttermatic\\', subDirName: 'Java');

        if (!_javaDir) {
          await Directory('C:\\fluttermatic\\Java').create(recursive: true);
        }

        await logger.file(LogTypeTag.info, 'Downloading Java');

        /// Downloading JDK.
        await context.read<DownloadNotifier>().downloadFile(
              api!.data!['java']['JDK'][platform],
              'jdk.$archiveType',
              _dir.path + '\\tmp',
            );

        _progress = Progress.extracting;
        context.read<DownloadNotifier>().dProgress = 0;
        notifyListeners();

        /// Extract java from compressed file.
        bool _jdkExtracted = await unzip(
            _dir.path + '\\tmp\\' + 'jdk.$archiveType',
            'C:\\fluttermatic\\Java\\');

        if (_jdkExtracted) {
          await logger.file(LogTypeTag.info, 'JDK extraction was successful');
          await for (FileSystemEntity e
              in Directory('C:\\fluttermatic\\Java\\').list(recursive: true)) {
            if (e.path.split('\\')[3].startsWith('openlogic') &&
                e.path.contains('openjdk-8u2')) {
              try {
                await e.rename('C:\\fluttermatic\\Java\\jdk');
                await logger.file(
                    LogTypeTag.info, 'Extracted folder rename successful');
              } on FileSystemException catch (fileSystemException, s) {
                await logger.file(
                    LogTypeTag.error, 'Extracted folder rename failed',
                    stackTraces: s);
              } catch (_, s) {
                await logger.file(
                    LogTypeTag.error, 'Extracted folder rename failed',
                    stackTraces: s);
              }
            }
          }
        } else {
          _progress = Progress.failed;
          notifyListeners();
          await logger.file(LogTypeTag.error, 'JDK extraction failed.');
        }

        /// Appending path to env
        bool _isJDKPathSet =
            await setPath('C:\\fluttermatic\\Java\\jdk\\bin', _dir.path);

        if (_isJDKPathSet) {
          await logger.file(LogTypeTag.info, 'JDK set to path');
        } else {
          _progress = Progress.failed;
          notifyListeners();
          await logger.file(LogTypeTag.error, 'JDK set to path failed');
        }

        _sw = Java.jre;
        _progress = Progress.downloading;
        context.read<DownloadNotifier>().dProgress = 0;
        notifyListeners();

        /// Downloading JRE
        await context.read<DownloadNotifier>().downloadFile(
              api.data!['java']['JRE'][platform],
              'jre.$archiveType',
              _dir.path + '\\tmp',
            );

        _progress = Progress.extracting;
        context.read<DownloadNotifier>().dProgress = 0;
        notifyListeners();

        /// Extract java from compressed file.
        bool _jreExtracted = await unzip(
          _dir.path + '\\tmp\\' + 'jre.$archiveType',
          'C:\\fluttermatic\\Java\\',
        );

        if (_jreExtracted) {
          await logger.file(LogTypeTag.info, 'JDK extraction was successful');
          await for (FileSystemEntity e
              in Directory('C:\\fluttermatic\\Java\\').list(recursive: true)) {
            if (e.path.split('\\')[3].startsWith('openlogic') &&
                e.path.contains('openjdk-jre-8u2')) {
              try {
                await e.rename('C:\\fluttermatic\\Java\\jre');
                await logger.file(
                    LogTypeTag.info, 'Extracted folder rename successful');
              } on FileSystemException catch (fileSystemException, s) {
                await logger.file(
                    LogTypeTag.error, 'Extracted folder rename failed',
                    stackTraces: s);
              } catch (_, s) {
                await logger.file(
                    LogTypeTag.error, 'Extracted folder rename failed',
                    stackTraces: s);
              }
            }
          }
        } else {
          _progress = Progress.failed;
          notifyListeners();
          await logger.file(LogTypeTag.error, 'JDK extraction failed.');
        }

        /// Appending path to env
        bool _isJREPathSet =
            await setPath('C:\\fluttermatic\\Java\\jre\\bin', _dir.path);

        if (_isJREPathSet) {
          await logger.file(LogTypeTag.info, 'JRE set to path');
          _progress = Progress.done;
          notifyListeners();
        } else {
          _progress = Progress.failed;
          notifyListeners();
          await logger.file(LogTypeTag.error, 'JRE set to path failed');
        }
      }

      /// Else we need to get version information.
      else if (!SharedPref().pref.containsKey(SPConst.javaPath) ||
          !SharedPref().pref.containsKey(SPConst.javaVersion)) {
        /// Make a fake delay of 1 second such that UI looks cool.
        await Future<dynamic>.delayed(const Duration(seconds: 1));
        await logger.file(LogTypeTag.info, 'Java found at - $_javaPath');
        await SharedPref().pref.setString(SPConst.javaPath, _javaPath);

        /// Make a fake delay of 1 second such that UI looks cool.
        await Future<dynamic>.delayed(const Duration(seconds: 1));
        javaVersion = await getJavaBinVersion();
        versions.java = javaVersion.toString();
        await logger.file(LogTypeTag.info, 'Java version : ${versions.java}');
        await SharedPref().pref.setString(SPConst.javaVersion, versions.java!);
        _progress = Progress.done;
        notifyListeners();
      } else {
        await logger.file(
            LogTypeTag.info, 'Loading Java details from shared preferences');
        _javaPath = SharedPref().pref.getString(SPConst.javaPath);
        await logger.file(LogTypeTag.info, 'Java found at - $_javaPath');
        versions.java = SharedPref().pref.getString(SPConst.javaVersion);
        await logger.file(LogTypeTag.info, 'Java version : ${versions.java}');
        _progress = Progress.done;
        notifyListeners();
      }
    } on ShellException catch (shellException, s) {
      _progress = Progress.failed;
      notifyListeners();
      await logger.file(LogTypeTag.error, shellException.message,
          stackTraces: s);
    } catch (_, s) {
      _progress = Progress.failed;
      notifyListeners();
      await logger.file(LogTypeTag.error, _.toString(), stackTraces: s);
    }
  }
}
