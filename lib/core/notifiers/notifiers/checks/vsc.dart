// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell.dart';
import 'package:pub_semver/src/version.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/app/enum.dart';
import 'package:fluttermatic/app/shared_pref.dart';
import 'package:fluttermatic/bin/code.dart';
import 'package:fluttermatic/core/notifiers/models/state/api/flutter_sdk.dart';
import 'package:fluttermatic/core/notifiers/models/state/api/vscode_api.dart';
import 'package:fluttermatic/core/notifiers/models/state/checks/vsc.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/general/shared_pref.dart';

class VSCodeNotifier extends StateNotifier<VSCState> {
  final Reader read;

  VSCodeNotifier(this.read) : super(VSCState.initial());

  Future<void> checkVSCode() async {
    Directory dir = await getApplicationSupportDirectory();
    String archiveType = platform == 'linux' ? 'tar.gz' : 'zip';

    try {
      FlutterSDKState flutterSdkState = read(flutterSdkAPIStateNotifier);

      String drive = read(spaceStateController).drive;

      state = state.copyWith(
        progress: Progress.checking,
      );

      String? vscPath = await which('code');
      if (vscPath == null) {
        await logger.file(
            LogTypeTag.warning, 'VS Code not installed in the system.');
        await logger.file(LogTypeTag.info, 'Downloading VS Code');

        /// Check for code Directory to extract files
        bool codeDir = await read(fileStateNotifier.notifier)
            .checkDir('$drive:\\fluttermatic\\', subDirName: 'code');

        /// If tmpDir is false, then create a temporary directory.
        if (!codeDir) {
          await Directory('$drive:\\fluttermatic\\code')
              .create(recursive: true);
          await logger.file(LogTypeTag.info,
              'Created code directory for extracting vscode files');
        }

        state = state.copyWith(
          progress: Progress.downloading,
        );

        /// Downloading VSCode. In debug mode, it will download a fake video
        /// file that is 50mb (for testing purposes).
        if (kDebugMode || kProfileMode) {
          await read(downloadStateController.notifier).downloadFile(
              'https://sample-videos.com/zip/50mb.zip',
              'code.$archiveType',
              '${dir.path}\\tmp');
        } else {
          VSCodeAPIState vscState = read(vsCodeAPIStateNotifier);

          await read(downloadStateController.notifier).downloadFile(
              platform == 'windows'
                  ? 'https://az764295.vo.msecnd.net/stable/${vscState.sha}/VSCode-win32-x64-${vscState.tagName}.zip'
                  : platform == 'mac'
                      ? flutterSdkState.sdkMap.data!['vscode'][platform]
                          ['universal']
                      : flutterSdkState.sdkMap.data!['vscode'][platform]
                          ['TarGZ'],
              platform == 'linux' ? 'code.tar.gz' : 'code.zip',
              '${dir.path}\\tmp');
        }

        state = state.copyWith(
          progress: Progress.extracting,
        );

        read(downloadStateController.notifier).resetState();

        /// Extract java from compressed file.
        bool vscExtracted = await read(fileStateNotifier.notifier)
            .unzip('${dir.path}\\tmp\\code.zip', '$drive:\\fluttermatic\\code');

        if (vscExtracted) {
          await logger.file(
              LogTypeTag.info, 'VSCode extraction was successful');
        } else {
          await logger.file(LogTypeTag.error, 'VSCode extraction failed.');

          state = state.copyWith(
            progress: Progress.failed,
          );
        }

        /// Appending path to env
        bool isVSCPathSet = await read(fileStateNotifier.notifier)
            .setPath('$drive:\\fluttermatic\\code\\bin', dir.path);

        if (isVSCPathSet) {
          await SharedPref()
              .pref
              .setString(SPConst.vscPath, '$drive:\\fluttermatic\\code\\bin');
          await logger.file(LogTypeTag.info, 'VSCode set to path');

          state = state.copyWith(
            progress: Progress.done,
          );
        } else {
          await logger.file(LogTypeTag.error, 'VSCode set to path failed');

          state = state.copyWith(
            progress: Progress.failed,
          );
        }
      } else if (!SharedPref().pref.containsKey(SPConst.vscPath) ||
          !SharedPref().pref.containsKey(SPConst.vscVersion)) {
        await logger.file(LogTypeTag.info, 'VS Code found at: $vscPath');
        await SharedPref().pref.setString(SPConst.vscPath, vscPath);

        state = state.copyWith(
          vscVersion: await getVSCBinVersion(),
        );

        await logger.file(
            LogTypeTag.info, 'VS Code version: ${state.vscVersion.toString()}');
        await SharedPref()
            .pref
            .setString(SPConst.vscVersion, state.vscVersion.toString());

        state = state.copyWith(
          progress: Progress.done,
        );
      } else {
        await logger.file(
            LogTypeTag.info, 'Loading VS Code details from shared preferences');
        vscPath = SharedPref().pref.getString(SPConst.vscPath);
        await logger.file(LogTypeTag.info, 'VS Code found at: $vscPath');

        state = state.copyWith(
          vscVersion:
              Version.parse(SharedPref().pref.getString(SPConst.vscVersion)!),
        );

        await logger.file(
            LogTypeTag.info, 'VS Code version: ${state.vscVersion.toString()}');

        state = state.copyWith(
          progress: Progress.done,
        );
      }
    } on ShellException catch (_, s) {
      await logger.file(LogTypeTag.error, _.message, stackTraces: s);
      state = state.copyWith(
        progress: Progress.failed,
      );
    } catch (_, s) {
      await logger.file(LogTypeTag.error, _.toString(), stackTraces: s);
      state = state.copyWith(
        progress: Progress.failed,
      );
    }
  }
}
