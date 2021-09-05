import 'dart:developer' as console;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/app/constants/enum.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:manager/core/libraries/models.dart';
import 'package:manager/meta/utils/bin/java.bin.dart';
import 'package:manager/meta/utils/shared_pref.dart';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell.dart';
import 'package:provider/provider.dart';
import 'package:pub_semver/src/version.dart';

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
      Directory dir = await getApplicationSupportDirectory();

      /// Checking for Java path,
      /// returns path to java or null if it doesn't exist.
      String? javaPath = await which('java');

      /// Check if path is null, if so, we need to download it.
      if (javaPath == null) {
        await logger.file(
            LogTypeTag.warning, 'Java not installed in the system.');
        _progress = Progress.downloading;
        notifyListeners();
        bool javaDir = await checkDir('C:\\fluttermatic\\', subDirName: 'Java');
        if (!javaDir) {
          await Directory('C:\\fluttermatic\\Java').create(recursive: true);
        }
        await logger.file(LogTypeTag.info, 'Downloading Java');

        /// Downloading JDK.
        await context.read<DownloadNotifier>().downloadFile(
              api!.data!['java']['JDK'][platform],
              'jdk.$archiveType',
              dir.path + '\\tmp',
            );

        _progress = Progress.extracting;
        context.read<DownloadNotifier>().dProgress = 0;
        notifyListeners();

        /// Extract java from compressed file.
        bool jdkExtracted = await unzip(
          dir.path + '\\tmp\\' + 'jdk.$archiveType',
          'C:\\fluttermatic\\Java\\',
        );

        if (jdkExtracted) {
          await logger.file(LogTypeTag.info, 'JDK extraction was successful');
          await for (FileSystemEntity e
              in Directory('C:\\fluttermatic\\Java\\').list(recursive: true)) {
            if (e.path.split('\\')[3].startsWith('openlogic') &&
                e.path.contains('openjdk-8u2')) {
              try {
                await e.rename('C:\\fluttermatic\\Java\\jdk');
                await logger.file(
                    LogTypeTag.info, 'Extracted folder rename successfull');
              } on FileSystemException catch (fileSystemException) {
                console.log(fileSystemException.message);
                await logger.file(
                    LogTypeTag.error, 'Extracted folder rename failed');
              } catch (e) {
                console.log(e.toString());
                await logger.file(
                    LogTypeTag.error, 'Extracted folder rename failed');
              }
            }
          }
        } else {
          _progress = Progress.failed;
          notifyListeners();
          await logger.file(LogTypeTag.error, 'JDK extraction failed.');
        }

        /// Appending path to env
        bool isJDKPathSet =
            await setPath('C:\\fluttermatic\\Java\\jdk\\bin', dir.path);
        if (isJDKPathSet) {
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
              dir.path + '\\tmp',
            );

        _progress = Progress.extracting;
        context.read<DownloadNotifier>().dProgress = 0;
        notifyListeners();

        /// Extract java from compressed file.
        bool jreExtracted = await unzip(
          dir.path + '\\tmp\\' + 'jre.$archiveType',
          'C:\\fluttermatic\\Java\\',
        );
        if (jreExtracted) {
          await logger.file(LogTypeTag.info, 'JDK extraction was successful');
          await for (FileSystemEntity e
              in Directory('C:\\fluttermatic\\Java\\').list(recursive: true)) {
            if (e.path.split('\\')[3].startsWith('openlogic') &&
                e.path.contains('openjdk-jre-8u2')) {
              try {
                await e.rename('C:\\fluttermatic\\Java\\jre');
                await logger.file(
                    LogTypeTag.info, 'Extracted folder rename successfull');
              } on FileSystemException catch (fileSystemException) {
                console.log(fileSystemException.message);
                await logger.file(
                    LogTypeTag.error, 'Extracted folder rename failed');
              } catch (e) {
                console.log(e.toString());
                await logger.file(
                    LogTypeTag.error, 'Extracted folder rename failed');
              }
            }
          }
        } else {
          _progress = Progress.failed;
          notifyListeners();
          await logger.file(LogTypeTag.error, 'JDK extraction failed.');
        }

        /// Appending path to env
        bool isJREPathSet =
            await setPath('C:\\fluttermatic\\Java\\jre\\bin', dir.path);
        if (isJREPathSet) {
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
      else if (!SharedPref().pref.containsKey('Java_path') ||
          !SharedPref().pref.containsKey('Java_version')) {
        /// Make a fake delay of 1 second such that UI looks cool.
        await Future<dynamic>.delayed(const Duration(seconds: 1));
        await logger.file(LogTypeTag.info, 'Java found at - $javaPath');
        await SharedPref().pref.setString('Java_path', javaPath);

        /// Make a fake delay of 1 second such that UI looks cool.
        await Future<dynamic>.delayed(const Duration(seconds: 1));
        javaVersion = await getJavaBinVersion();
        versions.java = javaVersion.toString();
        await logger.file(LogTypeTag.info, 'Java version : ${versions.java}');
        await SharedPref().pref.setString('Java_version', versions.java!);
        _progress = Progress.done;
        notifyListeners();
      } else {
        await logger.file(
            LogTypeTag.info, 'Loading Java details from shared preferences');
        javaPath = SharedPref().pref.getString('Java_path');
        await logger.file(LogTypeTag.info, 'Java found at - $javaPath');
        versions.java = SharedPref().pref.getString('Java_version');
        await logger.file(LogTypeTag.info, 'Java version : ${versions.java}');
        _progress = Progress.done;
        notifyListeners();
      }
    } on ShellException catch (shellException) {
      _progress = Progress.failed;
      notifyListeners();
      console.log(shellException.message);
      await logger.file(LogTypeTag.error, shellException.message);
    } catch (err) {
      _progress = Progress.failed;
      notifyListeners();
      console.log(err.toString());
      await logger.file(LogTypeTag.error, err.toString());
    }
  }
}
