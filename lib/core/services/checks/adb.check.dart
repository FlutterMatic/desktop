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
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/core/libraries/models.dart';
import 'package:fluttermatic/core/libraries/notifiers.dart';
import 'package:fluttermatic/core/libraries/services.dart';
import 'package:fluttermatic/meta/utils/bin/tools/adb.bin.dart';

/// [ADBNotifier] class is a [ChangeNotifier]
/// for ADB checks.
class ADBNotifier extends ChangeNotifier {
  /// [adbVersion] value holds ADB version information
  Version? adbVersion;

  Future<void> checkADB(BuildContext context, FluttermaticAPI? api) async {
    /// Application supporting Directory
    Directory _dir = await getApplicationSupportDirectory();
    try {
      String? _adbPath = await which('adb');

      if (_adbPath == null) {
        await logger.file(
            LogTypeTag.warning, 'ADB not installed in the system.');
        await logger.file(LogTypeTag.info, 'Downloading Platform-tools');

        /// Downloading ADB.
        await context.read<DownloadNotifier>().downloadFile(
            api!.data!['adb'][platform], 'adb.zip', _dir.path + '\\tmp');

        /// Extract java from compressed file.
        bool _adbExtracted = await unzip(
            _dir.path + '\\tmp\\' + 'adb.zip', 'C:\\fluttermatic\\');

        if (_adbExtracted) {
          await logger.file(LogTypeTag.info, 'ADB extraction was successful');
        } else {
          await logger.file(LogTypeTag.error, 'ADB extraction failed.');
        }

        /// Appending path to env
        bool _isADBPathSet =
            await setPath('C:\\fluttermatic\\platform-tools', _dir.path);

        if (_isADBPathSet) {
          await logger.file(LogTypeTag.info, 'Flutter-SDK set to path');
        } else {
          await logger.file(LogTypeTag.error, 'Flutter-SDK set to path failed');
        }
      } else {
        await logger.file(LogTypeTag.info, 'ADB found at - $_adbPath');

        adbVersion = await getADBBinVersion();
        versions.adb = adbVersion.toString();
        await logger.file(LogTypeTag.info, 'ADB version : ${versions.adb}');
      }
    } on ShellException catch (shellException, s) {
      await logger.file(LogTypeTag.error, shellException.message,
          stackTraces: s);
    } catch (_, s) {
      await logger.file(LogTypeTag.error, _.toString(), stackTraces: s);
    }
  }
}
