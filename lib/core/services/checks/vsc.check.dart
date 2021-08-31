import 'dart:developer' as console;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/app/constants/enum.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:manager/core/libraries/models.dart';
import 'package:manager/meta/utils/bin/code.bin.dart';
import 'package:manager/meta/utils/shared_pref.dart';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell.dart';
import 'package:provider/provider.dart';
import 'package:pub_semver/src/version.dart';

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

      /// Make a fake delay of 1 second such that UI looks cool.
      await Future<dynamic>.delayed(const Duration(seconds: 1));
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

        /// Downloading VSCode.
        kDebugMode || kProfileMode
            ? await context.read<DownloadNotifier>().downloadFile(
                  'https://sample-videos.com/zip/50mb.zip',
                  'code.$archiveType',
                  dir.path + '\\tmp',
                )
            : await context.read<DownloadNotifier>().downloadFile(
                  platform == 'windows'
                      ? 'https://az764295.vo.msecnd.net/stable/$sha/VSCode-win32-x64-$tagName.zip'
                      : platform == 'mac'
                          ? api!.data!['vscode'][platform]['universal']
                          : api!.data!['vscode'][platform]['TarGZ'],
                  platform == 'linux' ? 'code.tar.gz' : 'code.zip',
                  dir.path + '\\tmp',
                );
        _progress = Progress.extracting;
        context.read<DownloadNotifier>().dProgress = 0;
        notifyListeners();

        /// Extract java from compressed file.
        bool vscExtracted = await unzip(
          dir.path + '\\tmp\\code.zip',
          'C:\\fluttermatic\\code',
        );
        if (vscExtracted) {
          await logger.file(
              LogTypeTag.info, 'VSCode extraction was successfull');
        } else {
          await logger.file(LogTypeTag.error, 'VSCode extraction failed.');
          _progress = Progress.failed;
          notifyListeners();
        }

        /// Appending path to env
        bool isVSCPathSet =
            await setPath('C:\\fluttermatic\\code\\bin', dir.path);
        if (isVSCPathSet) {
          await SharedPref()
              .prefs
              .setString('VSC_path', 'C:\\fluttermatic\\code\\bin');
          await logger.file(LogTypeTag.info, 'VSCode set to path');
          _progress = Progress.done;
          notifyListeners();
        } else {
          await logger.file(LogTypeTag.error, 'VSCode set to path failed');
          _progress = Progress.failed;
          notifyListeners();
        }
      } else if (!SharedPref().prefs.containsKey('VSC_path') ||
          !SharedPref().prefs.containsKey('VSC_version')) {
        /// Make a fake delay of 1 second such that UI looks cool.
        await Future<dynamic>.delayed(const Duration(seconds: 1));
        await logger.file(LogTypeTag.info, 'VS Code found at - $vscPath');
        await SharedPref().prefs.setString('VSC_path', vscPath);

        /// Make a fake delay of 1 second such that UI looks cool.
        await Future<dynamic>.delayed(const Duration(seconds: 1));
        vscVersion = await getVSCBinVersion();
        versions.vsCode = vscVersion.toString();
        await logger.file(
            LogTypeTag.info, 'VS Code version : ${versions.vsCode}');
        await SharedPref().prefs.setString('VSC_version', versions.vsCode!);
        _progress = Progress.done;
        notifyListeners();
      } else {
        await logger.file(
            LogTypeTag.info, 'Loading VS Code details from shared preferences');
        vscPath = SharedPref().prefs.getString('VSC_path');
        await logger.file(LogTypeTag.info, 'VS Code found at - $vscPath');
        versions.vsCode = SharedPref().prefs.getString('VSC_version');
        await logger.file(LogTypeTag.info, 'VS Code version : ${versions.git}');
        _progress = Progress.done;
        notifyListeners();
      }
    } on ShellException catch (shellException) {
      console.log(shellException.message);
      await logger.file(LogTypeTag.error, shellException.message);
      _progress = Progress.failed;
      notifyListeners();
    } catch (err) {
      console.log(err.toString());
      await logger.file(LogTypeTag.error, err.toString());
      _progress = Progress.failed;
      notifyListeners();
    }
  }
}
