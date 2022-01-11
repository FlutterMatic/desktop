// 🎯 Dart imports:
import 'dart:developer' as console;
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
import 'package:manager/core/libraries/models.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:manager/meta/utils/bin/tools/adb.bin.dart';

/// [ADBNotifier] class is a [ChangeNotifier]
/// for ADB checks.
class ADBNotifier extends ChangeNotifier {
  /// [adbVersion] value holds ADB version information
  Version? adbVersion;

  Future<void> checkADB(BuildContext context, FluttermaticAPI? api) async {
    /// Application supporting Directory
    Directory dir = await getApplicationSupportDirectory();
    try {
      /// Make a fake delay of 1 second such that UI looks cool.
      await Future<dynamic>.delayed(const Duration(seconds: 1));
      String? adbPath = await which('adb');
      if (adbPath == null) {
        await logger.file(
            LogTypeTag.warning, 'ADB not installed in the system.');
        await logger.file(LogTypeTag.info, 'Downloading Platform-tools');

        /// Downloading ADB.
        await context.read<DownloadNotifier>().downloadFile(
              api!.data!['adb'][platform],
              'adb.zip',
              dir.path + '\\tmp',
            );

        /// Extract java from compressed file.
        bool adbExtracted = await unzip(
          dir.path + '\\tmp\\' + 'adb.zip',
          'C:\\fluttermatic\\',
        );
        if (adbExtracted) {
          await logger.file(LogTypeTag.info, 'ADB extraction was successful');
        } else {
          await logger.file(LogTypeTag.error, 'ADB extraction failed.');
        }

        /// Appending path to env
        bool isADBPathSet =
            await setPath('C:\\fluttermatic\\platform-tools', dir.path);
        if (isADBPathSet) {
          await logger.file(LogTypeTag.info, 'Flutter-SDK set to path');
        } else {
          await logger.file(LogTypeTag.error, 'Flutter-SDK set to path failed');
        }
      } else {
        /// Make a fake delay of 1 second such that UI looks cool.
        await Future<dynamic>.delayed(const Duration(seconds: 1));
        await logger.file(LogTypeTag.info, 'ADB found at - $adbPath');

        /// Make a fake delay of 1 second such that UI looks cool.
        await Future<dynamic>.delayed(const Duration(seconds: 1));
        adbVersion = await getADBBinVersion();
        versions.adb = adbVersion.toString();
        await logger.file(LogTypeTag.info, 'ADB version : ${versions.adb}');
      }
    } on ShellException catch (shellException) {
      console.log(shellException.message);
      await logger.file(LogTypeTag.error, shellException.message);
    } catch (err) {
      console.log(err.toString());
      await logger.file(LogTypeTag.error, err.toString());
    }
  }
}
