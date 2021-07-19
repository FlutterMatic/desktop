import 'dart:io';
import 'package:flutter/material.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:manager/core/libraries/models.dart';
import 'package:manager/meta/utils/bin/studio.bin.dart';
import 'package:process_run/shell.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pub_semver/src/version.dart';

/// [AndroidStudioNotifier] class is a [ValueNotifier]
/// for Android Studio checks.
class AndroidStudioNotifier extends ValueNotifier<String> {
  AndroidStudioNotifier([String value = 'Checking Android Studio'])
      : super(value);

  /// [studioVersion] value holds Android Studio version information
  Version? studioVersion;
  Directory? jetBrainStudioDir;
  Future<void> checkAStudio(BuildContext context, FluttermaticAPI? api) async {
    try {
      /// Make a fake delay of 1 second such that UI looks cool.
      await Future<dynamic>.delayed(const Duration(seconds: 1));
      String? studioPath = await which('studio64');
      Directory tempDir = await getTemporaryDirectory();
      Directory? jetbrainsDir =
          Directory(tempDir.path.replaceAll('Temp', 'JetBrains'));
      if (studioPath == null) {
        // C:\Program Files\Android\Android Studio\bin
        await logger.file(
            LogTypeTag.WARNING, 'Android Studio not found in the path.');
        Directory studioDir = Directory('C:\\Program\ Files\\Android\\');
        jetBrainStudioDir =
            Directory('${jetbrainsDir.path}\\Toolbox\\apps\\AndroidStudio');
        if (await studioDir.exists()) {
          if (await File('${studioDir.path}bin\\studio64.exe').exists()) {
            await Future<dynamic>.delayed(const Duration(seconds: 1));
            value = 'Android Studio found';
            await logger.file(
                LogTypeTag.INFO, 'Android studio found in Prgoram Files.');
            await Future<dynamic>.delayed(const Duration(seconds: 1));
            value = 'Fetching Android Studio version';
          } else {
            await logger.file(LogTypeTag.WARNING,
                'Android studio not found in Prgoram Files.');
          }
        }
        if (await jetbrainsDir.exists()) {
          if (await jetBrainStudioDir!.exists()) {
            await Future<dynamic>.delayed(const Duration(seconds: 1));
            value = 'Android Studio found';
            await logger.file(LogTypeTag.INFO,
                'Android Studio directory found in JetBrains.');
            await Future<dynamic>.delayed(const Duration(seconds: 1));
            value = 'Fetching Android Studio version';
          } else {
            await Future<dynamic>.delayed(const Duration(seconds: 1));
            value = 'Android Studio not found';
            await logger.file(LogTypeTag.WARNING,
                'Android Studio directory not found in JetBrains.');
          }
        } else {
          await Future<dynamic>.delayed(const Duration(seconds: 1));
          value = 'Android Studio not installed';
          await logger.file(LogTypeTag.ERROR, 'Android Studio not installed.');
        }
      } else {
        /// Make a fake delay of 1 second such that UI looks cool.
        await Future<dynamic>.delayed(const Duration(seconds: 1));
        value = 'Android Studio found';
        await logger.file(
            LogTypeTag.INFO, 'Android Studio found at - $studioPath');

        /// Make a fake delay of 1 second such that UI looks cool.
        await Future<dynamic>.delayed(const Duration(seconds: 1));
        value = 'Fetching Android Studio version';
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

class AndroidStudioChangeNotifier extends AndroidStudioNotifier {
  AndroidStudioChangeNotifier() : super('Checking Android Studio');
}
