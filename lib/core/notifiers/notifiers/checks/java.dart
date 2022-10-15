// 🎯 Dart imports:
import 'dart:io';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell.dart';
import 'package:pub_semver/pub_semver.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/app/enum.dart';
import 'package:fluttermatic/app/shared_pref.dart';
import 'package:fluttermatic/bin/java.dart';
import 'package:fluttermatic/core/notifiers/models/state/api/flutter_sdk.dart';
import 'package:fluttermatic/core/notifiers/models/state/checks/java.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/general/shared_pref.dart';

class JavaNotifier extends StateNotifier<JavaState> {
  final Ref ref;

  JavaNotifier(this.ref) : super(JavaState.initial());

  Java _sw = Java.jdk;
  Java get sw => _sw;

  /// Check java exists in the system or not.
  Future<void> checkJava() async {
    try {
      FlutterSDKState flutterSdkState = ref.watch(flutterSdkAPIStateNotifier);

      String drive = ref.watch(spaceStateController).drive;

      state = state.copyWith(
        progress: Progress.started,
      );

      /// The compressed archive type.
      String? archiveType = Platform.isLinux ? 'tar.gz' : 'zip';

      state = state.copyWith(
        progress: Progress.checking,
      );

      /// Application supporting Directory
      Directory dir = await getApplicationSupportDirectory();

      /// Checking for Java path,
      /// returns path to java or null if it doesn't exist.
      String? javaPath = await which('java');

      /// Check if path is null, if so, we need to download it.
      if (javaPath == null) {
        await logger.file(
            LogTypeTag.warning, 'Java not installed in the system.');

        state = state.copyWith(
          progress: Progress.downloading,
        );

        bool javaDir = await ref
            .watch(fileStateNotifier.notifier)
            .checkDir('$drive:\\fluttermatic\\', subDirName: 'Java');

        if (!javaDir) {
          await Directory('$drive:\\fluttermatic\\Java')
              .create(recursive: true);
        }

        await logger.file(LogTypeTag.info, 'Downloading Java');

        /// Downloading JDK.
        await ref.watch(downloadStateController.notifier).downloadFile(
            flutterSdkState.sdkMap.data!['java']['JDK'][platform],
            'jdk.$archiveType',
            '${dir.path}\\tmp');

        state = state.copyWith(
          progress: Progress.extracting,
        );

        ref.watch(downloadStateController.notifier).resetState();

        /// Extract java from compressed file.
        bool jdkExtracted = await ref.watch(fileStateNotifier.notifier).unzip(
            '${dir.path}\\tmp\\jdk.$archiveType',
            '$drive:\\fluttermatic\\Java\\');

        if (jdkExtracted) {
          await logger.file(LogTypeTag.info, 'JDK extraction was successful');
          await for (FileSystemEntity e
              in Directory('$drive:\\fluttermatic\\Java\\')
                  .list(recursive: true)) {
            if (e.path.split('\\')[3].startsWith('openlogic') &&
                e.path.contains('openjdk-8u2')) {
              try {
                await e.rename('$drive:\\fluttermatic\\Java\\jdk');
                await logger.file(
                    LogTypeTag.info, 'Extracted folder rename successful');
              } on FileSystemException catch (fileSystemException, s) {
                await logger.file(
                    LogTypeTag.error, 'Extracted folder rename failed',
                    stackTrace: s);
              } catch (e, s) {
                await logger.file(
                    LogTypeTag.error, 'Extracted folder rename failed',
                    stackTrace: s);
              }
            }
          }
        } else {
          state = state.copyWith(
            progress: Progress.failed,
          );

          await logger.file(LogTypeTag.error, 'JDK extraction failed.');
        }

        /// Appending path to env
        bool isJDKPathSet = await ref
            .watch(fileStateNotifier.notifier)
            .setPath('$drive:\\fluttermatic\\Java\\jdk\\bin', dir.path);

        if (isJDKPathSet) {
          await logger.file(LogTypeTag.info, 'JDK set to path');
        } else {
          state = state.copyWith(
            progress: Progress.failed,
          );

          await logger.file(LogTypeTag.error, 'JDK set to path failed');
        }

        _sw = Java.jre;

        state = state.copyWith(
          progress: Progress.downloading,
        );

        ref.watch(downloadStateController.notifier).resetState();

        /// Downloading JRE
        await ref.watch(downloadStateController.notifier).downloadFile(
            flutterSdkState.sdkMap.data!['java']['JRE'][platform],
            'jre.$archiveType',
            '${dir.path}\\tmp');

        state = state.copyWith(
          progress: Progress.extracting,
        );

        ref.watch(downloadStateController.notifier).resetState();

        /// Extract java from compressed file.
        bool jreExtracted = await ref.watch(fileStateNotifier.notifier).unzip(
            '${dir.path}\\tmp\\jre.$archiveType',
            '$drive:\\fluttermatic\\Java\\');

        if (jreExtracted) {
          await logger.file(LogTypeTag.info, 'JDK extraction was successful');
          await for (FileSystemEntity e
              in Directory('$drive:\\fluttermatic\\Java\\')
                  .list(recursive: true)) {
            if (e.path.split('\\')[3].startsWith('openlogic') &&
                e.path.contains('openjdk-jre-8u2')) {
              try {
                await e.rename('$drive:\\fluttermatic\\Java\\jre');
                await logger.file(
                    LogTypeTag.info, 'Extracted folder rename successful');
              } on FileSystemException catch (e, s) {
                await logger.file(
                    LogTypeTag.error, 'Extracted folder rename failed',
                    error: e, stackTrace: s);
              } catch (e, s) {
                await logger.file(
                    LogTypeTag.error, 'Extracted folder rename failed.',
                    error: e, stackTrace: s);
              }
            }
          }
        } else {
          state = state.copyWith(
            progress: Progress.failed,
          );

          await logger.file(LogTypeTag.error, 'JDK extraction failed.');
        }

        /// Appending path to env
        bool isJREPathSet = await ref
            .watch(fileStateNotifier.notifier)
            .setPath('$drive:\\fluttermatic\\Java\\jre\\bin', dir.path);

        if (isJREPathSet) {
          await logger.file(LogTypeTag.info, 'JRE set to path');
          state = state.copyWith(
            progress: Progress.done,
          );
        } else {
          state = state.copyWith(
            progress: Progress.failed,
          );
          await logger.file(LogTypeTag.error, 'JRE set to path failed');
        }
      }

      /// Else we need to get version information.
      else if (!SharedPref().pref.containsKey(SPConst.javaPath) ||
          !SharedPref().pref.containsKey(SPConst.javaVersion)) {
        await logger.file(LogTypeTag.info, 'Java found at: $javaPath');
        await SharedPref().pref.setString(SPConst.javaPath, javaPath);

        state = state.copyWith(
          javaVersion: await getJavaBinVersion(),
        );

        await logger.file(
            LogTypeTag.info, 'Java version: ${state.javaVersion.toString()}');
        await SharedPref()
            .pref
            .setString(SPConst.javaVersion, state.javaVersion.toString());

        state = state.copyWith(
          progress: Progress.done,
        );
      } else {
        await logger.file(
            LogTypeTag.info, 'Loading Java details from shared preferences');
        javaPath = SharedPref().pref.getString(SPConst.javaPath);
        await logger.file(LogTypeTag.info, 'Java found at: $javaPath');

        if (SharedPref().pref.getString(SPConst.javaVersion) != null) {
          state = state.copyWith(
            javaVersion: Version.parse(
                SharedPref().pref.getString(SPConst.javaVersion)!),
          );
        }

        await logger.file(
            LogTypeTag.info, 'Java version: ${state.javaVersion}');

        state = state.copyWith(
          progress: Progress.done,
        );
      }
    } on ShellException catch (e, s) {
      state = state.copyWith(
        progress: Progress.failed,
      );

      await logger.file(LogTypeTag.error, e.message, stackTrace: s);
    } catch (e, s) {
      state = state.copyWith(
        progress: Progress.failed,
      );

      await logger.file(LogTypeTag.error, e.toString(), stackTrace: s);
    }
  }
}
