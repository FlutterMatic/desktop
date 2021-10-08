// 🎯 Dart imports:
import 'dart:async';
import 'dart:developer' as console;
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
import 'package:manager/app/constants/enum.dart';
import 'package:manager/core/api/flutter_sdk.api.dart';
import 'package:manager/core/libraries/api.dart';
import 'package:manager/core/libraries/models.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:manager/meta/utils/bin/flutter.bin.dart' as fb;
import 'package:manager/meta/utils/shared_pref.dart';

/// [FlutterNotifier] is a [ValueNotifier].
class FlutterNotifier extends ChangeNotifier {
  /// Get flutter version.
  Version? flutterVersion;
  Progress _progress = Progress.none;
  Progress get progress => _progress;

  /// Function checks whether Flutter-SDK exists in the system or not.
  Future<void> checkFlutter(BuildContext context, FlutterSDK? sdk) async {
    try {
      _progress = Progress.started;
      notifyListeners();
      await Future<dynamic>.delayed(const Duration(seconds: 1));

      /// stable/windows/flutter_windows_2.2.3-stable.zip
      String? archive = context.read<FlutterSDKNotifier>().sdk;

      /// The comppressed archive type.
      String? archiveType = Platform.isLinux ? 'tar.xz' : 'zip';

      /// Checking for flutter path,
      /// returns path to flutter or null if it doesn't exist.
      _progress = Progress.checking;
      notifyListeners();
      String? flutterPath = await which('flutter');

      /// Check if path is null, if so, we need to download it.
      if (flutterPath == null) {
        /// Application supporting Directory
        Directory dir = await getApplicationSupportDirectory();
        // value = 'Flutter not found';
        await logger.file(LogTypeTag.warning, 'Flutter-SDK not found');
        // value = 'Downloading flutter';
        await logger.file(LogTypeTag.info, 'Downloading Flutter-SDK');

        bool fZip = await checkFile(dir.path + '\\tmp', 'flutter.$archiveType');
        if (fZip) {
          await logger.file(LogTypeTag.info, 'Deleting old Flutter-SDK archive.');
          await File(dir.path + '\\tmp\\flutter.$archiveType').delete(recursive: true);
        }

        _progress = Progress.downloading;
        notifyListeners();

        /// Downloading flutter
        kDebugMode || kProfileMode
            ? await context.read<DownloadNotifier>().downloadFile(
                  'https://sample-videos.com/zip/50mb.zip',
                  'flutter.$archiveType',
                  dir.path + '\\tmp',
                )
            : await context.read<DownloadNotifier>().downloadFile(
                  sdk!.data!['base_url'] + '/' + archive,
                  'flutter.$archiveType',
                  dir.path + '\\tmp',
                );

        _progress = Progress.extracting;
        context.read<DownloadNotifier>().dProgress = 0;
        notifyListeners();

        /// Extraction
        bool extracted = await unzip(
          dir.path + '\\tmp\\' + 'flutter.$archiveType',
          'C:\\fluttermatic\\',
        );
        if (extracted) {
          // value = 'Extracted Flutter-SDK';
          await logger.file(LogTypeTag.info, 'Flutter-SDK extraction was successfull');
        } else {
          // value = 'Extracting Flutter-SDK failed';
          _progress = Progress.failed;
          notifyListeners();
          await logger.file(LogTypeTag.error, 'Flutter-SDK extraction failed.');
        }

        /// Appending path to env
        bool isPathSet = await setPath('C:\\fluttermatic\\flutter\\bin', dir.path);
        if (isPathSet) {
          await logger.file(LogTypeTag.info, 'Flutter-SDK set to path');
          await SharedPref().pref.setString('Flutter_path', 'C:\\fluttermatic\\flutter\\bin');
        } else {
          await logger.file(LogTypeTag.error, 'Flutter-SDK set to path failed');
        }
        _progress = Progress.done;
        notifyListeners();
      }

      /// Else we need to get version, channel information.
      else if (!SharedPref().pref.containsKey('Flutter_path') ||
          !SharedPref().pref.containsKey('Flutter_version') ||
          !SharedPref().pref.containsKey('Flutter_channel')) {
        await Future<dynamic>.delayed(const Duration(seconds: 1));
        await SharedPref().pref.setString('Flutter_path', flutterPath);
        // value = 'Flutter-SDK found';
        await logger.file(LogTypeTag.info, 'Flutter-SDK found at - $flutterPath');

        /// Sample output(for reference)
        /// $ flutter --version
        /// Flutter 1.7.8+hotfix.4 • channel stable • https://github.com/flutter/flutter.git
        /// Framework • revision 20e59316b8 (8 weeks ago) • 2019-07-18 20:04:33 -0700
        /// Engine • revision fee001c93f
        /// Tools • Dart 2.4.0
        await Future<dynamic>.delayed(const Duration(seconds: 1));
        // value = 'Fetching flutter version';
        flutterVersion = await fb.getFlutterVersion();
        versions.flutter = flutterVersion.toString();
        await logger.file(LogTypeTag.info, 'Flutter version : ${versions.flutter}');
        await SharedPref().pref.setString('Flutter_version', versions.flutter!);
        await Future<dynamic>.delayed(const Duration(seconds: 2));
        versions.channel = await fb.getFlutterBinChannel();
        await logger.file(LogTypeTag.info, 'Flutter channel : ${versions.channel}');
        await SharedPref().pref.setString('Flutter_channel', versions.channel!);
        _progress = Progress.done;
        notifyListeners();
      } else {
        await logger.file(LogTypeTag.info, 'Loading flutter details from shared preferences');
        flutterPath = SharedPref().pref.getString('Flutter_path');
        await logger.file(LogTypeTag.info, 'Flutter-SDK found at - $flutterPath');
        versions.flutter = SharedPref().pref.getString('Flutter_version');
        await logger.file(LogTypeTag.info, 'Flutter version : ${versions.flutter}');
        versions.channel = SharedPref().pref.getString('Flutter_vhannel');
        await logger.file(LogTypeTag.info, 'Flutter channel : ${versions.channel}');
        _progress = Progress.done;
        notifyListeners();
      }
    } on ShellException catch (shellException) {
      console.log(shellException.message);
      _progress = Progress.failed;
      notifyListeners();
      await logger.file(LogTypeTag.error, shellException.message);
    } catch (err) {
      console.log(err.toString());
      _progress = Progress.failed;
      notifyListeners();
      await logger.file(LogTypeTag.error, err.toString());
    }
  }
}
