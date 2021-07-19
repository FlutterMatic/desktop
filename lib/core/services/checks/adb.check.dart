import 'dart:developer' as console;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/core/libraries/models.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:manager/meta/utils/bin/adb.bin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:process_run/shell.dart';
import 'package:pub_semver/src/version.dart';

/// [ADBNotifier] class is a [ValueNotifier]
/// for ADB checks.
class ADBNotifier extends ValueNotifier<String> {
  ADBNotifier([String value = 'Checking ADB files']) : super(value);

  /// [adbVersion] value holds ADB version information
  Version? adbVersion;

  /// Get the platform
  String? platform = Platform.isWindows
      ? 'windows'
      : Platform.isMacOS
          ? 'mac'
          : 'linux';

  Future<void> checkADB(BuildContext context, FluttermaticAPI? api) async {
    /// Application supporting Directory
    Directory dir = await getApplicationSupportDirectory();
    try {
      /// Make a fake delay of 1 second such that UI looks cool.
      await Future<dynamic>.delayed(const Duration(seconds: 1));
      String? adbPath = await which('adb');
      if (adbPath == null) {
        value = 'ADB not installed';
        await logger.file(
            LogTypeTag.WARNING, 'ADB not installed in the system.');
        value = 'Downloading Platform-tools';
        await logger.file(LogTypeTag.INFO, 'Downloading Platform-tools');

        /// Check for temporary Directory to download files
        bool tmpDir = await checkDir(dir.path, subDirName: 'tmp');

        /// If tmpDir is false, then create a temporary directory.
        if (tmpDir == false) {
          await Directory('${dir.path}\\tmp').create();
          await logger.file(
              LogTypeTag.INFO, 'Created tmp directory while checking ADB');
        }

        /// Downloading ADB.
        await context.read<DownloadNotifier>().downloadFile(
              api!.data!['adb'][platform],
              'adb.zip',
              dir.path + '\\tmp',
              progressBarColor: const Color(0xFFA4CA39),
            );

        /// Extract java from compressed file.
        bool adbExtracted = await unzip(
          dir.path + '\\tmp\\' + 'adb.zip',
          'C:\\fluttermatic\\',
          value: 'Extracting ADB',
        );
        adbExtracted
            ? await logger.file(
                LogTypeTag.INFO, 'ADB extraction was successfull')
            : await logger.file(LogTypeTag.ERROR, 'ADB extraction failed.');

        /// Appending path to env
        bool isADBPathSet = await setPath('C:\\fluttermatic\\platform-tools\\',
            appDir: dir.path);
        if (isADBPathSet) {
          value = 'Flutter-SDK set to path';
          await logger.file(LogTypeTag.INFO, 'Flutter-SDK set to path');
        } else {
          value = 'Flutter-SDK set to path failed';
          await logger.file(LogTypeTag.ERROR, 'Flutter-SDK set to path failed');
        }
      } else {
        /// Make a fake delay of 1 second such that UI looks cool.
        await Future<dynamic>.delayed(const Duration(seconds: 1));
        value = 'ADB found';
        await logger.file(LogTypeTag.INFO, 'ADB found at - $adbPath');

        /// Make a fake delay of 1 second such that UI looks cool.
        await Future<dynamic>.delayed(const Duration(seconds: 1));
        value = 'Fetching ADB version';
        adbVersion = await getADBBinVersion();
        versions.adb = adbVersion.toString();
        await logger.file(LogTypeTag.INFO, 'ADB version : ${versions.adb}');
      }
    } on ShellException catch (shellException) {
      console.log(shellException.message);
      await logger.file(LogTypeTag.ERROR, shellException.message);
    } catch (err) {
      console.log(err.toString());
      await logger.file(LogTypeTag.ERROR, err.toString());
    }
  }
}

class ADBChangeNotifier extends ADBNotifier {
  ADBChangeNotifier() : super('Checking ADB files');
}
