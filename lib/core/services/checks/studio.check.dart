import 'dart:io';
import 'package:flutter/material.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:manager/core/libraries/models.dart';
import 'package:manager/meta/utils/bin/studio.bin.dart';
import 'package:process_run/shell.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
// ignore: implementation_imports
import 'package:pub_semver/src/version.dart';

/// [AndroidStudioNotifier] class is a [ChangeNotifier]
/// for Android Studio checks.
class AndroidStudioNotifier extends ChangeNotifier {
  /// [studioVersion] value holds Android Studio version information
  Version? studioVersion;
  Directory? jetBrainStudioDir;
  Future<void> checkAStudio(BuildContext context, FluttermaticAPI? api) async {
    try {
      /// Make a fake delay of 1 second such that UI looks cool.
      await Future<dynamic>.delayed(const Duration(seconds: 1));
      String? studioPath = whichSync('studio');
      Directory tempDir = await getTemporaryDirectory();
      Directory applicationDir = await getApplicationSupportDirectory();
      Directory? jetbrainsDir =
          Directory(tempDir.path.replaceAll('Temp', 'JetBrains'));
      Directory? programFilesDir = Directory('C:\\Program Files\\Android');

      /// Check if studio path is null.
      if (studioPath == null) {
        /// Check in Program Files Directory
        if (await programFilesDir.exists()) {
          bool checkPF = await checkProgramFiles();
          if (!checkPF) {
            if (await jetbrainsDir.exists()) {
              bool checkJB = await checkJetBrains(
                  jetbrainsDir.path + '\\Toolbox\\apps\\AndroidStudio',
                  appDir: applicationDir.path);

              /// If !checkJB, then check Download Android Studio.
              if (!checkJB) {
                /// Check for git Directory to extract Git files
                bool studioDir = await checkDir('C:\\fluttermatic\\',
                    subDirName: 'Android Studio');
                if (!studioDir) {
                  await Directory('C:\\fluttermatic\\Android Studio').create();
                  await logger.file(LogTypeTag.INFO,
                      'Created Android studio directory in fluttermatic folder.');
                  await installAndroidStudio(
                    context,
                    api: api,
                    appDir: applicationDir.path,
                  );
                }
              }
            }
          }
        } else if (await jetbrainsDir.exists()) {
          bool checkJB = await checkJetBrains(
              jetbrainsDir.path + 'Toolbox\\apps\\AndroidStudio',
              appDir: applicationDir.path);
          if (!checkJB) {
            /// Check for git Directory to extract Git files
            bool studioDir = await checkDir('C:\\fluttermatic\\',
                subDirName: 'Android Studio');
            if (!studioDir) {
              await Directory('C:\\fluttermatic\\Android Studio').create();
              await logger.file(LogTypeTag.INFO,
                  'Created Android studio directory in fluttermatic folder.');
            }
            await installAndroidStudio(
              context,
              api: api,
              appDir: applicationDir.path,
            );
          }
        } else {
          await logger.file(LogTypeTag.INFO, 'Android Studio not installed');

          /// Check for git Directory to extract Git files
          bool studioDir = await checkDir('C:\\fluttermatic\\',
              subDirName: 'Android Studio');
          if (!studioDir) {
            await Directory('C:\\fluttermatic\\Android Studio').create();
            await logger.file(LogTypeTag.INFO,
                'Created Android studio directory in fluttermatic folder.');
          }
          await installAndroidStudio(
            context,
            api: api,
            appDir: applicationDir.path,
          );
        }
      } else {
        /// Fetch the version of Android Studio.
        studioVersion = await getAStudioBinVersion();
        versions.studio = studioVersion.toString();
        await logger.file(
            LogTypeTag.INFO, 'Android Studio version : ${versions.studio}');
      }
    } on ShellException catch (shellException) {
      await logger.file(LogTypeTag.ERROR, shellException.message);
    } catch (err) {
      await logger.file(LogTypeTag.ERROR, err.toString());
    }
  }
}

/// This function will check if the Android Studio
/// is installed in the Program Files directory.
Future<bool> checkProgramFiles() async {
  await logger.file(LogTypeTag.INFO, 'Checking Program Files');
  Directory? programFilesDir = Directory('C:\\Program Files\\Android');
  if (await programFilesDir.exists()) {
    await logger.file(LogTypeTag.INFO, 'Program Files Directory Exists');
    await logger.file(
        LogTypeTag.INFO, 'Checking in Program Files for Android studio');
    String? studio64PFPath =
        await getFilePath('C:\\Program Files\\Android\\', 'studio64.exe');
    if (studio64PFPath != null) {
      await logger.file(LogTypeTag.INFO, 'Studio64.exe found in Program Files');
      await Future<dynamic>.delayed(const Duration(seconds: 1));
      await setPath(studio64PFPath);
      return true;
    } else {
      await logger.file(
          LogTypeTag.INFO, 'Studio64.exe not found in Program Files folder');
      return false;
    }
  } else {
    return false;
  }
}

/// This function will check if the Android Studio
/// is installed in the Jetbrains directory.
Future<bool> checkJetBrains(String? jetbrainsDir, {String? appDir}) async {
  await logger.file(LogTypeTag.INFO, 'Checking JetBrains');
  Directory? jetBrainsDir = Directory(jetbrainsDir!);
  if (await jetBrainsDir.exists()) {
    await logger.file(LogTypeTag.INFO, 'JetBrains Directory Exists');
    await logger.file(
        LogTypeTag.INFO, 'Checking in JetBrains for Android studio');
    String? studio64JBPath = await getFilePath(jetbrainsDir, 'studio64.exe');
    if (studio64JBPath != null) {
      await logger.file(LogTypeTag.INFO, 'Studio64.exe found in Jetbrains');
      await Future<dynamic>.delayed(const Duration(seconds: 1));
      await setPath(studio64JBPath, appDir);
      return true;
    } else {
      await logger.file(
          LogTypeTag.INFO, 'Studio64.exe not found in Jetbrains folder');
      return false;
    }
  } else {
    return false;
  }
}

/// Install the Android Studio.
Future<void> installAndroidStudio(BuildContext context,
    {String? value, FluttermaticAPI? api, required String appDir}) async {
  /// Downloading Android studio.
  await context.read<DownloadNotifier>().downloadFile(
        platform == 'linux'
            ? api!.data!['android studio']['linux']['TarGZ']
            : api!.data!['android studio'][platform]['zip'],
        platform == 'linux' ? 'studio.tar.gz' : 'studio.zip',
        appDir + '\\tmp',
        progressBarColor: const Color(0xFF4285F4),
      );
  await Future<dynamic>.delayed(const Duration(seconds: 1));
  value = 'Extracting Android Studio';

  /// Extract Android studio from compressed file.
  bool studioExtracted = await unzip(
    appDir + '\\tmp\\studio.zip',
    'C:\\fluttermatic\\',
  );
  if (studioExtracted) {
    await Future<dynamic>.delayed(const Duration(seconds: 1));
    value = 'Extracted Android Studio';
    await logger.file(
        LogTypeTag.INFO, 'Android studio extraction was successfull');
  } else {
    await Future<dynamic>.delayed(const Duration(seconds: 1));
    value = 'Extraction failed';
    await logger.file(LogTypeTag.ERROR, 'Android studio extraction failed.');
  }
  await Directory('C:\\fluttermatic\\android-studio').rename('Android Studio');

  /// Appending path to env
  bool isASPathSet =
      await setPath('C:\\fluttermatic\\Android Studio\\bin\\', appDir);
  if (isASPathSet) {
    await Future<dynamic>.delayed(const Duration(seconds: 1));
    value = 'Android studio set to path';
    await logger.file(LogTypeTag.INFO, 'Android studio set to path');
  }
}
