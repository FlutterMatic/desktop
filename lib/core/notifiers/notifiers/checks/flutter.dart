// 🎯 Dart imports:
import 'dart:async';
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermatic/app/enum.dart';
import 'package:fluttermatic/app/shared_pref.dart';
import 'package:fluttermatic/core/notifiers/models/state/api/flutter_sdk.dart';
import 'package:fluttermatic/core/notifiers/models/state/checks/flutter.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/meta/utils/general/shared_pref.dart';

// 📦 Package imports:
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell.dart';

// 🌎 Project imports:
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/bin/flutter.dart';

class FlutterNotifier extends StateNotifier<FlutterState> {
  final Reader read;

  FlutterNotifier(this.read) : super(FlutterState.initial());

  /// Function checks whether Flutter-SDK exists in the system or not.
  Future<void> checkFlutter() async {
    try {
      FlutterSDKState flutterSdkState = read(flutterSdkAPIStateNotifier);

      String drive = read(spaceStateController).drive;

      state = state.copyWith(
        progress: Progress.started,
      );

      /// stable/windows/flutter_windows_2.2.3-stable.zip
      String? archive = read(flutterSdkAPIStateNotifier).sdk;

      /// The compressed archive type.
      String? archiveType = Platform.isLinux ? 'tar.xz' : 'zip';

      /// Checking for flutter path, returns path to flutter or null if
      /// it doesn't exist.
      state = state.copyWith(
        progress: Progress.checking,
      );

      String? flutterPath = await which('flutter');

      /// Check if path is null, if so, we need to download it.
      if (flutterPath == null) {
        /// Application supporting Directory
        Directory dir = await getApplicationSupportDirectory();
        await logger.file(LogTypeTag.warning, 'Flutter-SDK not found');
        await logger.file(LogTypeTag.info, 'Downloading Flutter-SDK');

        bool fZip = await read(fileStateNotifier.notifier)
            .fileExists('${dir.path}\\tmp', 'flutter.$archiveType');

        if (fZip) {
          await logger.file(
              LogTypeTag.info, 'Deleting old Flutter-SDK archive.');
          await File('${dir.path}\\tmp\\flutter.$archiveType')
              .delete(recursive: true);
        }

        state = state.copyWith(
          progress: Progress.downloading,
        );

        /// Downloading flutter
        if (kDebugMode || kProfileMode) {
          await read(downloadStateController.notifier).downloadFile(
              'https://sample-videos.com/zip/50mb.zip',
              'flutter.$archiveType',
              '${dir.path}\\tmp');
        } else {
          await read(downloadStateController.notifier).downloadFile(
              flutterSdkState.sdkMap.data!['base_url'] + '/' + archive,
              'flutter.$archiveType',
              '${dir.path}\\tmp');
        }

        state = state.copyWith(
          progress: Progress.extracting,
        );

        read(downloadStateController.notifier).resetState();

        /// Extraction
        bool extracted = await read(fileStateNotifier.notifier).unzip(
            '${dir.path}\\tmp\\flutter.$archiveType',
            '$drive:\\fluttermatic\\');

        if (extracted) {
          // value = 'Extracted Flutter-SDK';
          await logger.file(
              LogTypeTag.info, 'Flutter-SDK extraction was successful');
        } else {
          state = state.copyWith(
            progress: Progress.failed,
          );

          await logger.file(LogTypeTag.error, 'Flutter-SDK extraction failed.');
        }

        /// Appending path to env
        bool isPathSet = await read(fileStateNotifier.notifier)
            .setPath('$drive:\\fluttermatic\\flutter\\bin', dir.path);

        if (isPathSet) {
          await logger.file(LogTypeTag.info, 'Flutter-SDK set to path');
          await SharedPref().pref.setString(
              SPConst.flutterPath, '$drive:\\fluttermatic\\flutter\\bin');
        } else {
          await logger.file(LogTypeTag.error, 'Flutter-SDK set to path failed');
        }

        state = state.copyWith(
          progress: Progress.done,
        );
      }

      /// Else we need to get version, channel information.
      else if (!SharedPref().pref.containsKey(SPConst.flutterPath) ||
          !SharedPref().pref.containsKey(SPConst.flutterVersion) ||
          !SharedPref().pref.containsKey(SPConst.flutterChannel)) {
        await SharedPref().pref.setString(SPConst.flutterPath, flutterPath);
        await logger.file(
            LogTypeTag.info, 'Flutter-SDK found at: $flutterPath');

        /// Sample output(for reference)
        /// $ flutter --version
        /// Flutter 1.7.8+hotfix.4 • channel stable • https://github.com/flutter/flutter.git
        /// Framework • revision 20e59316b8 (8 weeks ago) • 2019-07-18 20:04:33 -0700
        /// Engine • revision fee001c93f
        /// Tools • Dart 2.4.0
        state = state.copyWith(flutterVersion: await getFlutterVersion());

        await logger.file(
            LogTypeTag.info, 'Flutter version: ${state.flutterVersion}');
        await SharedPref().pref.setString(
            SPConst.flutterVersion, state.flutterVersion!.toString());

        state = state.copyWith(channel: await getFlutterBinChannel());

        await logger.file(LogTypeTag.info, 'Flutter channel: ${state.channel}');

        await SharedPref()
            .pref
            .setString(SPConst.flutterChannel, state.channel);

        state = state.copyWith(
          progress: Progress.done,
        );
      } else {
        await logger.file(
            LogTypeTag.info, 'Loading flutter details from shared preferences');
        flutterPath = SharedPref().pref.getString(SPConst.flutterPath);
        await logger.file(
            LogTypeTag.info, 'Flutter-SDK found at: $flutterPath');
        await logger.file(LogTypeTag.info,
            'Flutter version: ${state.flutterVersion.toString()}');
        await logger.file(LogTypeTag.info, 'Flutter channel: ${state.channel}');

        state = state.copyWith(
          progress: Progress.done,
        );
      }
    } on ShellException catch (_, s) {
      state = state.copyWith(
        progress: Progress.failed,
      );

      await logger.file(LogTypeTag.error, _.message, stackTraces: s);
    } catch (_, s) {
      state = state.copyWith(
        progress: Progress.failed,
      );

      await logger.file(LogTypeTag.error, _.toString(), stackTraces: s);
    }
  }
}
