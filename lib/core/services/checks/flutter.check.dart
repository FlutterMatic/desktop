import 'dart:developer' as console;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:manager/core/api/flutter_sdk.api.dart';
import 'package:manager/core/libraries/api.dart';
import 'package:manager/core/libraries/models.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:manager/meta/utils/shared_pref.dart';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell.dart';
import 'package:provider/provider.dart';
// ignore: implementation_imports
// ignore: implementation_imports
import 'package:pub_semver/src/version.dart';

/// [FlutterNotifier] is a [ValueNotifier].
class FlutterNotifier extends ValueNotifier<String> {
  FlutterNotifier([String value = 'Checking flutter']) : super(value);

  /// Get flutter version.
  Version? flutterVersion;

  /// Function checks whether Flutter-SDK exists in the system or not.
  Future<void> checkFlutter(BuildContext context, FlutterSDK? sdk) async {
    try {
      await Future<dynamic>.delayed(const Duration(seconds: 1));

      /// stable/windows/flutter_windows_2.2.3-stable.zip
      String? archive = context.read<FlutterSDKNotifier>().sdk;

      /// The comppressed archive type.
      String? archiveType = Platform.isLinux ? 'tar.xz' : 'zip';

      /// Checking for flutter path,
      /// returns path to flutter or null if it doesn't exist.
      String? flutterPath = await which('flutter');

      /// Check if path is null, if so, we need to download it.
      if (flutterPath == null) {
        /// Application supporting Directory
        Directory dir = await getApplicationSupportDirectory();
        value = 'Flutter not found';
        await logger.file(LogTypeTag.WARNING, 'Flutter-SDK not found');
        value = 'Downloading flutter';
        await logger.file(LogTypeTag.INFO, 'Downloading Flutter-SDK');

        /// Check for temporary Directory to download files
        bool tmpDir = await checkDir(dir.path, subDirName: 'tmp');

        /// If tmpDir is false, then create a temporary directory.
        if (!tmpDir) {
          await Directory('${dir.path}\\tmp').create();
          await logger.file(
              LogTypeTag.INFO, 'Created tmp directory while checking Flutter');
        }

        /// Downloading flutter
        await context.read<DownloadNotifier>().downloadFile(
              sdk!.data!['base_url'] + '/' + archive,
              'flutter.$archiveType',
              dir.path + '\\tmp',
              progressBarColor: Colors.lightBlueAccent,
            );

        value = 'Extracting Flutter-SDK';

        /// Extraction
        bool extracted = await unzip(
          dir.path + '\\tmp\\' + 'flutter.$archiveType',
          'C:\\fluttermatic\\',
        );
        if (extracted) {
          value = 'Extracted Flutter-SDK';
          await logger.file(
              LogTypeTag.INFO, 'Flutter-SDK extraction was successfull');
        } else {
          value = 'Extracting Flutter-SDK failed';
          await logger.file(LogTypeTag.ERROR, 'Flutter-SDK extraction failed.');
        }

        /// Appending path to env
        bool isPathSet =
            await setPath('C:\\fluttermatic\\flutter\\bin\\', dir.path);
        if (isPathSet) {
          value = 'Flutter-SDK set to path';
          await logger.file(LogTypeTag.INFO, 'Flutter-SDK set to path');
        } else {
          value = 'Flutter-SDK set to path failed';
          await logger.file(LogTypeTag.ERROR, 'Flutter-SDK set to path failed');
        }
      }

      /// Else we need to get version, channel information.
      else {
        await Future<dynamic>.delayed(const Duration(seconds: 1));
        if (SharedPref().prefs.getString('flutter path') == null) {
          await SharedPref().prefs.setString('flutter path', flutterPath);
        }
        value = 'Flutter-SDK found';
        await logger.file(
            LogTypeTag.INFO, 'Flutter-SDK found at - $flutterPath');

        /// Sample output(for reference)
        /// $ flutter --version
        /// Flutter 1.7.8+hotfix.4 • channel stable • https://github.com/flutter/flutter.git
        /// Framework • revision 20e59316b8 (8 weeks ago) • 2019-07-18 20:04:33 -0700
        /// Engine • revision fee001c93f
        /// Tools • Dart 2.4.0
        await Future<dynamic>.delayed(const Duration(seconds: 1));
        value = 'Fetching flutter version';
        flutterVersion = await getFlutterBinVersion();
        versions.flutter = flutterVersion.toString();
        await logger.file(
            LogTypeTag.INFO, 'Flutter version : ${versions.flutter}');
        value = 'Fetching flutter channel';
        await Future<dynamic>.delayed(const Duration(seconds: 2));
        versions.channel = await getFlutterBinChannel();
        await logger.file(
            LogTypeTag.INFO, 'Flutter channel : ${versions.channel}');
      }
    } on ShellException catch (shellException) {
      console.log(shellException.message);
      await logger.file(LogTypeTag.ERROR, shellException.message);
    } catch (err) {
      console.log(err.toString());
      await logger.file(LogTypeTag.ERROR, err.toString());
    }
  }
}

class FlutterChangeNotifier extends FlutterNotifier {
  FlutterChangeNotifier() : super('Checking Flutter');
}
