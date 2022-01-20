// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
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
import 'package:manager/meta/utils/bin/tools/studio.bin.dart';
import 'package:manager/meta/utils/shared_pref.dart';

/// [AndroidStudioNotifier] class is a [ChangeNotifier]
/// for Android Studio checks.
class AndroidStudioNotifier extends ChangeNotifier {
  /// [studioVersion] value holds Android Studio version information
  Version? studioVersion;
  Directory? jetBrainStudioDir;
  Progress _progress = Progress.none;
  Progress get progress => _progress;

  Future<void> checkAStudio(BuildContext context, FluttermaticAPI? api) async {
    _progress = Progress.started;
    notifyListeners();

    /// The compressed archive type.
    String? archiveType = Platform.isLinux ? 'tar.gz' : 'zip';

    try {
      _progress = Progress.checking;
      notifyListeners();

      String? studioPath = await which('studio');
      Directory tempDir = await getTemporaryDirectory();
      Directory applicationDir = await getApplicationSupportDirectory();

      /// Check if studio path is null.
      if (studioPath == null) {
        Directory? _jetBrainsPath =
            Directory(tempDir.path.replaceAll('Temp', 'JetBrains'));

        /// Check in Program Files Directory
        bool _checkPF = await checkProgramFiles();

        if (!_checkPF && await _jetBrainsPath.exists()) {
          bool _checkJB = await checkJetBrains(
              _jetBrainsPath.path + '\\Toolbox\\apps\\AndroidStudio',
              appDir: applicationDir.path);

          if (!_checkJB) {
            /// Check for AndroidStudio Directory to extract Android studio files
            bool studioDir = await checkDir('C:\\fluttermatic\\',
                subDirName: 'AndroidStudio');

            bool _flutterMaticDir =
                await checkDir('C:\\', subDirName: 'fluttermatic');

            if (!studioDir) {
              if (!_flutterMaticDir) {
                await Directory('C:\\fluttermatic').create(recursive: true);
              }
              await Directory('C:\\fluttermatic\\AndroidStudio')
                  .create(recursive: true);
              await logger.file(LogTypeTag.info,
                  'Created Android studio directory in fluttermatic folder.');
            }

            _progress = Progress.downloading;
            notifyListeners();

            await installAndroidStudio(
              context,
              api: api,
              appDir: applicationDir.path,
              archiveType: archiveType,
            );
          }
        }
        _progress = Progress.done;
        notifyListeners();
      } else if (!SharedPref().pref.containsKey(SPConst.aStudioPath) ||
          !SharedPref().pref.containsKey(SPConst.aStudioVersion)) {
        await SharedPref().pref.setString(SPConst.aStudioPath, studioPath);
        await logger.file(LogTypeTag.info,
            'Android Studio found at: ${studioPath.trim()}'.trim());

        /// Fetch the version of Android Studio.
        studioVersion = await getAStudioBinVersion();
        versions.studio = studioVersion.toString();
        await logger.file(
            LogTypeTag.info, 'Android Studio version: ${versions.studio}');
        await SharedPref()
            .pref
            .setString(SPConst.aStudioVersion, versions.studio!);
        _progress = Progress.done;
        notifyListeners();
      } else {
        await logger.file(LogTypeTag.info,
            'Loading Android Studio details from shared preferences');
        studioPath = SharedPref().pref.getString(SPConst.aStudioPath);
        await logger.file(
            LogTypeTag.info,
            'Android Studio found at: ${studioPath!.trim()}'
                .trim()
                .replaceAll('"', ''));
        versions.studio = SharedPref().pref.getString(SPConst.aStudioVersion);
        await logger.file(
            LogTypeTag.info, 'Studio version: ${versions.studio}');
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

  /// This function will check if the Android Studio
  /// is installed in the Program Files directory.
  Future<bool> checkProgramFiles() async {
    await logger.file(LogTypeTag.info, 'Checking Program Files');
    Directory _programFilesDir = Directory('C:\\Program Files\\Android');
    try {
      if (await _programFilesDir.exists()) {
        await logger.file(LogTypeTag.info, 'Program Files Directory Exists');
        await logger.file(
            LogTypeTag.info, 'Checking in Program Files for Android studio');
        String? studio64PFPath =
            await getFilePath('C:\\Program Files\\Android\\', 'studio64.exe');
        if (studio64PFPath != null) {
          await logger.file(
              LogTypeTag.info, 'Studio64.exe found in Program Files');
          await SharedPref()
              .pref
              .setString(SPConst.aStudioPath, studio64PFPath);
          await setPath(studio64PFPath);
          return true;
        } else {
          await logger.file(LogTypeTag.info,
              'Studio64.exe not found in Program Files folder');
          return false;
        }
      } else {
        return false;
      }
    } on FileSystemException catch (fileException, s) {
      await logger.file(
          LogTypeTag.error, 'Extracting failed - File System Exception',
          stackTraces: null);
      await logger.file(LogTypeTag.error, fileException.message.toString(),
          stackTraces: s);
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
    Directory _jetBrainsDir = Directory(jetBrainsDir);
    if (await _jetBrainsDir.exists()) {
      await logger.file(LogTypeTag.info, 'JetBrains Directory Exists');
      await logger.file(
          LogTypeTag.info, 'Checking in JetBrains for Android studio');
      String? _studio64JBPath = await getFilePath(jetBrainsDir, 'studio64.exe');
      if (_studio64JBPath != null) {
        paths.studio = _studio64JBPath;
        await logger.file(LogTypeTag.info, 'Studio64.exe found in JetBrains');
        await setPath(_studio64JBPath, appDir);
        await SharedPref().pref.setString(SPConst.aStudioPath, paths.studio!);
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
  Future<void> installAndroidStudio(
    BuildContext context, {
    FluttermaticAPI? api,
    required String appDir,
    String? archiveType,
  }) async {
    /// Downloading Android studio.
    if (kDebugMode || kProfileMode) {
      await context.read<DownloadNotifier>().downloadFile(
          'https://sample-videos.com/zip/50mb.zip',
          'studio.$archiveType',
          appDir + '\\tmp');
    } else {
      await context.read<DownloadNotifier>().downloadFile(
          api!.data!['android_studio'][platform]
              [archiveType!.replaceAll('.', '')],
          'studio.$archiveType',
          appDir + '\\tmp');
    }

    _progress = Progress.extracting;
    context.read<DownloadNotifier>().dProgress = 0;
    notifyListeners();

    /// Extract Android studio from compressed file.
    bool _studioExtracted =
        await unzip(appDir + '\\tmp\\studio.zip', 'C:\\fluttermatic\\');

    if (_studioExtracted) {
      await logger.file(
          LogTypeTag.info, 'Android studio extraction was successful');
      if (await checkDir('C:\\fluttermatic\\', subDirName: 'android-studio')) {
        Directory _renameDir = Directory('C:\\fluttermatic\\android-studio');

        if (await _renameDir.exists()) {
          await _renameDir.rename('C:\\fluttermatic\\AndroidStudio');
          await logger.file(
              LogTypeTag.info, 'Renamed android-studio to AndroidStudio');
        }

        /// Appending path to env
        bool _isASPathSet =
            await setPath('C:\\fluttermatic\\AndroidStudio\\bin', appDir);

        if (_isASPathSet) {
          await SharedPref()
              .pref
              .setString('Studio_path', 'C:\\fluttermatic\\AndroidStudio\\bin');
          await logger.file(LogTypeTag.info, 'Android studio set to path');
        } else {
          _progress = Progress.failed;
          notifyListeners();

          await logger.file(
              LogTypeTag.info, 'Android studio set to path failed');
        }
      } else {
        _progress = Progress.failed;
        notifyListeners();
        await logger.file(LogTypeTag.error, 'Android studio renaming failed.');
      }
    } else {
      _progress = Progress.failed;
      notifyListeners();
      await logger.file(LogTypeTag.error, 'Android studio extraction failed.');
    }
  }
}
