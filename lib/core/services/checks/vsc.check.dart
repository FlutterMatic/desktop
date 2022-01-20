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
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/app/constants/enum.dart';
import 'package:fluttermatic/app/constants/shared_pref.dart';
import 'package:fluttermatic/core/libraries/models.dart';
import 'package:fluttermatic/core/libraries/notifiers.dart';
import 'package:fluttermatic/core/libraries/services.dart';
import 'package:fluttermatic/meta/utils/bin/tools/code.bin.dart';
import 'package:fluttermatic/meta/utils/shared_pref.dart';

/// [VSCodeNotifier] class is a [ChangeNotifier]
/// for VS Code checks.
class VSCodeNotifier extends ChangeNotifier {
  /// [vscVersion] value holds VS Code version information
  Version? vscVersion;
  Progress _progress = Progress.none;
  Progress get progress => _progress;

  Future<void> checkVSCode(BuildContext context, FluttermaticAPI? api) async {
    Directory dir = await getApplicationSupportDirectory();
    String archiveType = platform == 'linux' ? 'tar.gz' : 'zip';
    try {
      _progress = Progress.started;
      notifyListeners();

      _progress = Progress.checking;
      notifyListeners();
      String? vscPath = await which('code');
      if (vscPath == null) {
        await logger.file(
            LogTypeTag.warning, 'VS Code not installed in the system.');
        await logger.file(LogTypeTag.info, 'Downloading VS Code');

        /// Check for code Directory to extract files
        bool codeDir = await checkDir('C:\\fluttermatic\\', subDirName: 'code');

        /// If tmpDir is false, then create a temporary directory.
        if (!codeDir) {
          await Directory('C:\\fluttermatic\\code').create(recursive: true);
          await logger.file(LogTypeTag.info,
              'Created code directory for extracting vscode files');
        }

        _progress = Progress.downloading;
        notifyListeners();

        /// Downloading VSCode. In debug mode, it will download a fake video
        /// file that is 50mb (for testing purposes).
        if (kDebugMode || kProfileMode) {
          await context.read<DownloadNotifier>().downloadFile(
              'https://sample-videos.com/zip/50mb.zip',
              'code.$archiveType',
              dir.path + '\\tmp');
        } else {
          await context.read<DownloadNotifier>().downloadFile(
              platform == 'windows'
                  ? 'https://az764295.vo.msecnd.net/stable/$sha/VSCode-win32-x64-$tagName.zip'
                  : platform == 'mac'
                      ? api!.data!['vscode'][platform]['universal']
                      : api!.data!['vscode'][platform]['TarGZ'],
              platform == 'linux' ? 'code.tar.gz' : 'code.zip',
              dir.path + '\\tmp');
        }

        _progress = Progress.extracting;
        context.read<DownloadNotifier>().dProgress = 0;
        notifyListeners();

        /// Extract java from compressed file.
        bool _vscExtracted =
            await unzip(dir.path + '\\tmp\\code.zip', 'C:\\fluttermatic\\code');

        if (_vscExtracted) {
          await logger.file(
              LogTypeTag.info, 'VSCode extraction was successful');
        } else {
          await logger.file(LogTypeTag.error, 'VSCode extraction failed.');
          _progress = Progress.failed;
          notifyListeners();
        }

        /// Appending path to env
        bool _isVSCPathSet =
            await setPath('C:\\fluttermatic\\code\\bin', dir.path);

        if (_isVSCPathSet) {
          await SharedPref()
              .pref
              .setString(SPConst.vscPath, 'C:\\fluttermatic\\code\\bin');
          await logger.file(LogTypeTag.info, 'VSCode set to path');
          _progress = Progress.done;
          notifyListeners();
        } else {
          await logger.file(LogTypeTag.error, 'VSCode set to path failed');
          _progress = Progress.failed;
          notifyListeners();
        }
      } else if (!SharedPref().pref.containsKey(SPConst.vscPath) ||
          !SharedPref().pref.containsKey(SPConst.vscVersion)) {
        await logger.file(LogTypeTag.info, 'VS Code found at: $vscPath');
        await SharedPref().pref.setString(SPConst.vscPath, vscPath);

        vscVersion = await getVSCBinVersion();
        versions.vsCode = vscVersion.toString();
        await logger.file(
            LogTypeTag.info, 'VS Code version: ${versions.vsCode}');
        await SharedPref().pref.setString(SPConst.vscVersion, versions.vsCode!);
        _progress = Progress.done;
        notifyListeners();
      } else {
        await logger.file(
            LogTypeTag.info, 'Loading VS Code details from shared preferences');
        vscPath = SharedPref().pref.getString(SPConst.vscPath);
        await logger.file(LogTypeTag.info, 'VS Code found at: $vscPath');
        versions.vsCode = SharedPref().pref.getString(SPConst.vscVersion);
        await logger.file(
            LogTypeTag.info, 'VS Code version: ${versions.vsCode}');
        _progress = Progress.done;
        notifyListeners();
      }
    } on ShellException catch (_, s) {
      await logger.file(LogTypeTag.error, _.message, stackTraces: s);
      _progress = Progress.failed;
      notifyListeners();
    } catch (_, s) {
      await logger.file(LogTypeTag.error, _.toString(), stackTraces: s);
      _progress = Progress.failed;
      notifyListeners();
    }
  }
}
