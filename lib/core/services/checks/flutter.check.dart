// 🎯 Dart imports:
import 'dart:async';
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
import 'package:fluttermatic/app/constants/enum.dart';
import 'package:fluttermatic/app/constants/shared_pref.dart';
import 'package:fluttermatic/core/api/flutter_sdk.api.dart';
import 'package:fluttermatic/core/models/flutter_sdk.model.dart';
import 'package:fluttermatic/core/models/version.model.dart';
import 'package:fluttermatic/core/notifiers/download.notifier.dart';
import 'package:fluttermatic/core/notifiers/space.notifier.dart';
import 'package:fluttermatic/core/services/check_file.dart';
import 'package:fluttermatic/core/services/extraction.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/core/services/set_path.dart';
import 'package:fluttermatic/meta/utils/bin/tools/flutter.bin.dart' as fb;
import 'package:fluttermatic/meta/utils/shared_pref.dart';

/// [FlutterNotifier] is a [ValueNotifier].
class FlutterNotifier extends ChangeNotifier {
  /// Get flutter version.
  Version? flutterVersion;
  Progress _progress = Progress.none;
  String channel = '...';
  Progress get progress => _progress;

  /// Function checks whether Flutter-SDK exists in the system or not.
  Future<void> checkFlutter(BuildContext context, FlutterSDK? sdk) async {
    try {
      String _drive = context.read<SpaceCheck>().drive;

      _progress = Progress.started;
      notifyListeners();

      /// stable/windows/flutter_windows_2.2.3-stable.zip
      String? _archive = context.read<FlutterSDKNotifier>().sdk;

      /// The compressed archive type.
      String? _archiveType = Platform.isLinux ? 'tar.xz' : 'zip';

      /// Checking for flutter path,
      /// returns path to flutter or null if it doesn't exist.
      _progress = Progress.checking;
      notifyListeners();
      String? _flutterPath = await which('flutter');

      /// Check if path is null, if so, we need to download it.
      if (_flutterPath == null) {
        /// Application supporting Directory
        Directory _dir = await getApplicationSupportDirectory();
        await logger.file(LogTypeTag.warning, 'Flutter-SDK not found');
        await logger.file(LogTypeTag.info, 'Downloading Flutter-SDK');

        bool _fZip =
            await checkFile(_dir.path + '\\tmp', 'flutter.$_archiveType');

        if (_fZip) {
          await logger.file(
              LogTypeTag.info, 'Deleting old Flutter-SDK archive.');
          await File(_dir.path + '\\tmp\\flutter.$_archiveType')
              .delete(recursive: true);
        }

        _progress = Progress.downloading;
        notifyListeners();

        /// Downloading flutter
        if (kDebugMode || kProfileMode) {
          await context.read<DownloadNotifier>().downloadFile(
              'https://sample-videos.com/zip/50mb.zip',
              'flutter.$_archiveType',
              _dir.path + '\\tmp');
        } else {
          await context.read<DownloadNotifier>().downloadFile(
              sdk!.data!['base_url'] + '/' + _archive,
              'flutter.$_archiveType',
              _dir.path + '\\tmp');
        }

        _progress = Progress.extracting;
        context.read<DownloadNotifier>().dProgress = 0;
        notifyListeners();

        /// Extraction
        bool _extracted = await unzip(
            context,
            _dir.path + '\\tmp\\' + 'flutter.$_archiveType',
            '$_drive:\\fluttermatic\\');

        if (_extracted) {
          // value = 'Extracted Flutter-SDK';
          await logger.file(
              LogTypeTag.info, 'Flutter-SDK extraction was successful');
        } else {
          // value = 'Extracting Flutter-SDK failed';
          _progress = Progress.failed;
          notifyListeners();
          await logger.file(LogTypeTag.error, 'Flutter-SDK extraction failed.');
        }

        /// Appending path to env
        bool _isPathSet =
            await setPath('$_drive:\\fluttermatic\\flutter\\bin', _dir.path);

        if (_isPathSet) {
          await logger.file(LogTypeTag.info, 'Flutter-SDK set to path');
          await SharedPref().pref.setString(
              SPConst.flutterPath, '$_drive:\\fluttermatic\\flutter\\bin');
        } else {
          await logger.file(LogTypeTag.error, 'Flutter-SDK set to path failed');
        }
        _progress = Progress.done;
        notifyListeners();
      }

      /// Else we need to get version, channel information.
      else if (!SharedPref().pref.containsKey(SPConst.flutterPath) ||
          !SharedPref().pref.containsKey(SPConst.flutterVersion) ||
          !SharedPref().pref.containsKey(SPConst.flutterChannel)) {
        await SharedPref().pref.setString(SPConst.flutterPath, _flutterPath);
        await logger.file(
            LogTypeTag.info, 'Flutter-SDK found at: $_flutterPath');

        /// Sample output(for reference)
        /// $ flutter --version
        /// Flutter 1.7.8+hotfix.4 • channel stable • https://github.com/flutter/flutter.git
        /// Framework • revision 20e59316b8 (8 weeks ago) • 2019-07-18 20:04:33 -0700
        /// Engine • revision fee001c93f
        /// Tools • Dart 2.4.0
        flutterVersion = await fb.getFlutterVersion();
        versions.flutter = flutterVersion.toString();
        await logger.file(
            LogTypeTag.info, 'Flutter version: ${versions.flutter}');
        await SharedPref()
            .pref
            .setString(SPConst.flutterVersion, versions.flutter!);
        versions.channel = await fb.getFlutterBinChannel();
        await logger.file(
            LogTypeTag.info, 'Flutter channel: ${versions.channel}');
        channel = versions.channel!;
        notifyListeners();
        await SharedPref()
            .pref
            .setString(SPConst.flutterChannel, versions.channel!);
        _progress = Progress.done;
        notifyListeners();
      } else {
        await logger.file(
            LogTypeTag.info, 'Loading flutter details from shared preferences');
        _flutterPath = SharedPref().pref.getString(SPConst.flutterPath);
        await logger.file(
            LogTypeTag.info, 'Flutter-SDK found at: $_flutterPath');
        versions.flutter = SharedPref().pref.getString(SPConst.flutterVersion);
        await logger.file(
            LogTypeTag.info, 'Flutter version: ${versions.flutter}');
        versions.channel = SharedPref().pref.getString(SPConst.flutterChannel);
        await logger.file(
            LogTypeTag.info, 'Flutter channel: ${versions.channel}');
        _progress = Progress.done;
        notifyListeners();
      }
    } on ShellException catch (_, s) {
      _progress = Progress.failed;
      notifyListeners();
      await logger.file(LogTypeTag.error, _.message, stackTraces: s);
    } catch (_, s) {
      _progress = Progress.failed;
      notifyListeners();
      await logger.file(LogTypeTag.error, _.toString(), stackTraces: s);
    }
  }
}
