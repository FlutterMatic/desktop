// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:fluttermatic/app/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermatic/bin/adb.dart';
import 'package:fluttermatic/core/notifiers/models/state/checks/adb.dart';
import 'package:fluttermatic/core/notifiers/out.dart';

// 📦 Package imports:
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell.dart';

// 🌎 Project imports:
import 'package:fluttermatic/core/models/fluttermatic.dart';
import 'package:fluttermatic/core/services/logs.dart';

class ADBNotifier extends StateNotifier<ADBState> {
  final Reader read;

  ADBNotifier(this.read) : super(ADBState.initial());

  Future<void> checkADB(BuildContext context, FlutterMaticAPI? api) async {
    try {
      /// Application supporting Directory
      Directory dir = await getApplicationSupportDirectory();

      String drive = read(spaceStateController).drive;

      String? adbPath = await which('adb');

      if (adbPath == null) {
        await logger.file(
            LogTypeTag.warning, 'ADB not installed in the system.');
        await logger.file(LogTypeTag.info, 'Downloading Platform-tools');

        /// Downloading ADB.
        await read(downloadStateController.notifier).downloadFile(
            api!.data!['adb'][platform], 'adb.zip', '${dir.path}\\tmp');

        /// Extract java from compressed file.
        bool adbExtracted = await read(fileStateNotifier.notifier)
            .unzip('${dir.path}\\tmp\\adb.zip', '$drive:\\fluttermatic\\');

        if (adbExtracted) {
          await logger.file(LogTypeTag.info, 'ADB extraction was successful');
        } else {
          await logger.file(LogTypeTag.error, 'ADB extraction failed.');
        }

        /// Appending path to env
        bool isADBPathSet = await read(fileStateNotifier.notifier)
            .setPath('$drive:\\fluttermatic\\platform-tools', dir.path);

        if (isADBPathSet) {
          await logger.file(LogTypeTag.info, 'Flutter-SDK set to path');
        } else {
          await logger.file(LogTypeTag.error, 'Flutter-SDK set to path failed');
        }
      } else {
        await logger.file(LogTypeTag.info, 'ADB found at - $adbPath');

        state = state.copyWith(
          adbVersion: await getADBBinVersion(),
        );

        await logger.file(LogTypeTag.info, 'ADB version: ${state.adbVersion}');
      }
    } on ShellException catch (shellException, s) {
      await logger.file(LogTypeTag.error, shellException.message,
          stackTraces: s);
    } catch (_, s) {
      await logger.file(LogTypeTag.error, _.toString(), stackTraces: s);
    }
  }
}
