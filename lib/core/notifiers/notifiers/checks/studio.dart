// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/app/enum.dart';
import 'package:fluttermatic/app/shared_pref.dart';
import 'package:fluttermatic/core/notifiers/models/state/api/fm_api.dart';
import 'package:fluttermatic/core/notifiers/models/state/checks/studio.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/meta/utils/general/shared_pref.dart';

// 📦 Package imports:
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell.dart';
import 'package:pub_semver/src/version.dart';

// 🌎 Project imports:
import 'package:fluttermatic/core/models/fluttermatic.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/bin/studio.dart';

class AndroidStudioNotifier extends StateNotifier<AndroidStudioState> {
  final Reader read;

  AndroidStudioNotifier(this.read) : super(AndroidStudioState.initial());

  Directory? jetBrainStudioDir;

  Future<void> checkAStudio() async {
    String drive = read(spaceStateController).drive;

    state = state.copyWith(
      progress: Progress.started,
    );

    /// The compressed archive type.
    String? archiveType = Platform.isLinux ? 'tar.gz' : 'zip';

    try {
      FlutterMaticAPIState fmAPIState = read(fmAPIStateNotifier);

      state = state.copyWith(
        progress: Progress.checking,
      );

      String? studioPath = await which('studio');
      Directory tempDir = await getTemporaryDirectory();
      Directory applicationDir = await getApplicationSupportDirectory();

      /// Check if studio path is null.
      if (studioPath == null) {
        Directory? jetBrainsPath =
            Directory(tempDir.path.replaceAll('Temp', 'JetBrains'));

        /// Check in Program Files Directory

        bool checkPF = await checkProgramFiles();

        if (!checkPF && await jetBrainsPath.exists()) {
          bool checkJB = await checkJetBrains(
              '${jetBrainsPath.path}\\Toolbox\\apps\\AndroidStudio',
              appDir: applicationDir.path);

          if (!checkJB) {
            /// Check for AndroidStudio Directory to extract Android studio files
            bool studioDir = await read(fileStateNotifier.notifier).checkDir(
                '$drive:\\fluttermatic\\',
                subDirName: 'AndroidStudio');

            bool flutterMaticDir = await read(fileStateNotifier.notifier)
                .checkDir('$drive:\\', subDirName: 'fluttermatic');

            if (!studioDir) {
              if (!flutterMaticDir) {
                await Directory('$drive:\\fluttermatic')
                    .create(recursive: true);
              }
              await Directory('$drive:\\fluttermatic\\AndroidStudio')
                  .create(recursive: true);
              await logger.file(LogTypeTag.info,
                  'Created Android studio directory in fluttermatic folder.');
            }

            state = state.copyWith(
              progress: Progress.downloading,
            );

            await installAndroidStudio(
              api: fmAPIState.apiMap,
              appDir: applicationDir.path,
              archiveType: archiveType,
            );
          }
        }

        state = state.copyWith(
          progress: Progress.done,
        );
      } else if (!SharedPref().pref.containsKey(SPConst.aStudioPath) ||
          !SharedPref().pref.containsKey(SPConst.aStudioVersion)) {
        await SharedPref().pref.setString(SPConst.aStudioPath, studioPath);
        await logger.file(LogTypeTag.info,
            'Android Studio found at: ${studioPath.trim()}'.trim());

        /// Fetch the version of Android Studio.
        state = state.copyWith(
          studioVersion: await getAStudioBinVersion(),
        );

        await logger.file(LogTypeTag.info,
            'Android Studio version: ${state.studioVersion.toString()}');

        await SharedPref()
            .pref
            .setString(SPConst.aStudioVersion, state.studioVersion.toString());

        state = state.copyWith(
          progress: Progress.done,
        );
      } else {
        await logger.file(LogTypeTag.info,
            'Loading Android Studio details from shared preferences');
        studioPath = SharedPref().pref.getString(SPConst.aStudioPath);
        await logger.file(
          LogTypeTag.info,
          'Android Studio found at: ${studioPath!.trim()}'
              .trim()
              .replaceAll('"', ''),
        );

        state = state.copyWith(
          studioVersion: Version.parse(
              SharedPref().pref.getString(SPConst.aStudioVersion)!),
        );

        await logger.file(LogTypeTag.info,
            'Studio version: ${state.studioVersion.toString()}');

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

  /// This function will check if the Android Studio
  /// is installed in the Program Files directory.
  Future<bool> checkProgramFiles() async {
    String drive = read(spaceStateController).drive;

    await logger.file(LogTypeTag.info, 'Checking Program Files');
    Directory programFilesDir = Directory('$drive:\\Program Files\\Android');
    try {
      if (await programFilesDir.exists()) {
        await logger.file(LogTypeTag.info, 'Program Files Directory Exists');
        await logger.file(
            LogTypeTag.info, 'Checking in Program Files for Android studio');
        String? studio64PFPath = await read(fileStateNotifier.notifier)
            .searchFile('$drive:\\Program Files\\Android\\', 'studio64.exe');
        if (studio64PFPath != null) {
          await logger.file(
              LogTypeTag.info, 'Studio64.exe found in Program Files');
          await SharedPref()
              .pref
              .setString(SPConst.aStudioPath, studio64PFPath);
          await read(fileStateNotifier.notifier).setPath(studio64PFPath);
          return true;
        } else {
          await logger.file(LogTypeTag.info,
              'Studio64.exe not found in Program Files folder');
          return false;
        }
      } else {
        return false;
      }
    } on FileSystemException catch (_, s) {
      await logger.file(
          LogTypeTag.error, 'Extracting failed - File System Exception',
          stackTraces: s);
      await logger.file(LogTypeTag.error, _.message.toString(), stackTraces: s);
      return false;
    } catch (_, s) {
      await logger.file(LogTypeTag.error, _.toString(), stackTraces: s);
      return false;
    }
  }

  /// This function will check if the Android Studio
  /// is installed in the JetBrains directory.
  Future<bool> checkJetBrains(String jetBrainsDir, {String? appDir}) async {
    await logger.file(LogTypeTag.info, 'Checking JetBrains');

    Directory dir = Directory(jetBrainsDir);

    if (await dir.exists()) {
      await logger.file(LogTypeTag.info, 'JetBrains Directory Exists');
      await logger.file(
          LogTypeTag.info, 'Checking in JetBrains for Android studio');
      String? studio64JBPath = await read(fileStateNotifier.notifier)
          .searchFile(jetBrainsDir, 'studio64.exe');
      if (studio64JBPath != null) {
        state = state.copyWith(
          studioPath: studio64JBPath,
        );

        await logger.file(LogTypeTag.info, 'Studio64.exe found in JetBrains');
        await read(fileStateNotifier.notifier).setPath(studio64JBPath, appDir);
        await SharedPref()
            .pref
            .setString(SPConst.aStudioPath, state.studioPath!);
        return true;
      } else {
        await logger.file(
            LogTypeTag.info, 'Studio64.exe not found in JetBrains folder');
        return false;
      }
    } else {
      return false;
    }
  }

  /// Install the Android Studio.
  Future<void> installAndroidStudio({
    FlutterMaticAPI? api,
    required String appDir,
    String? archiveType,
  }) async {
    String drive = read(spaceStateController).drive;

    /// Downloading Android studio.
    if (kDebugMode || kProfileMode) {
      await read(downloadStateController.notifier).downloadFile(
          'https://sample-videos.com/zip/50mb.zip',
          'studio.$archiveType',
          '$appDir\\tmp');
    } else {
      await read(downloadStateController.notifier).downloadFile(
          api!.data!['android_studio'][platform]
              [archiveType!.replaceAll('.', '')],
          'studio.$archiveType',
          '$appDir\\tmp');
    }

    state = state.copyWith(
      progress: Progress.extracting,
    );

    read(downloadStateController.notifier).resetState();

    /// Extract Android studio from compressed file.
    bool studioExtracted = await read(fileStateNotifier.notifier)
        .unzip('$appDir\\tmp\\studio.zip', '$drive:\\fluttermatic\\');

    if (studioExtracted) {
      await logger.file(
          LogTypeTag.info, 'Android studio extraction was successful');
      if (await read(fileStateNotifier.notifier)
          .checkDir('$drive:\\fluttermatic\\', subDirName: 'android-studio')) {
        Directory renameDir =
            Directory('$drive:\\fluttermatic\\android-studio');

        if (await renameDir.exists()) {
          await renameDir.rename('$drive:\\fluttermatic\\AndroidStudio');
          await logger.file(
              LogTypeTag.info, 'Renamed android-studio to AndroidStudio');
        }

        /// Appending path to env
        bool isASPathSet = await read(fileStateNotifier.notifier)
            .setPath('$drive:\\fluttermatic\\AndroidStudio\\bin', appDir);

        if (isASPathSet) {
          await SharedPref().pref.setString(
              'Studio_path', '$drive:\\fluttermatic\\AndroidStudio\\bin');
          await logger.file(LogTypeTag.info, 'Android studio set to path');
        } else {
          state = state.copyWith(
            progress: Progress.failed,
          );

          await logger.file(
              LogTypeTag.info, 'Android studio set to path failed');
        }
      } else {
        state = state.copyWith(
          progress: Progress.failed,
        );
        await logger.file(LogTypeTag.error, 'Android studio renaming failed.');
      }
    } else {
      state = state.copyWith(
        progress: Progress.failed,
      );
      await logger.file(LogTypeTag.error, 'Android studio extraction failed.');
    }
  }
}
