import 'dart:developer' as console;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:manager/core/libraries/models.dart';
import 'package:manager/meta/utils/bin/code.bin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell.dart';
import 'package:provider/provider.dart';
// ignore: implementation_imports
import 'package:pub_semver/src/version.dart';

/// [VSCodeNotifier] class is a [ValueNotifier]
/// for VS Code checks.
class VSCodeNotifier extends ValueNotifier<String> {
  VSCodeNotifier([String value = 'Checking VS Code']) : super(value);

  /// [vscVersion] value holds VS Code version information
  Version? vscVersion;
  Future<void> checkVSCode(BuildContext context, FluttermaticAPI? api) async {
    Directory dir = await getApplicationSupportDirectory();

    try {
      /// Make a fake delay of 1 second such that UI looks cool.
      await Future<dynamic>.delayed(const Duration(seconds: 1));
      String? vscPath = await which('code');
      if (vscPath == null) {
        value = 'VS Code not installed';
        await logger.file(
            LogTypeTag.WARNING, 'VS Code not installed in the system.');
        value = 'Downloading VS Code';
        await logger.file(LogTypeTag.INFO, 'Downloading VS Code');

        /// Check for temporary Directory to download files
        bool tmpDir = await checkDir(dir.path, subDirName: 'tmp');

        /// Check for code Directory to extract files
        bool codeDir = await checkDir('C:\\fluttermatic\\', subDirName: 'code');

        /// If tmpDir is false, then create a temporary directory.
        if (!tmpDir) {
          await Directory('${dir.path}\\tmp').create();
          await logger.file(
              LogTypeTag.INFO, 'Created tmp directory while checking VSCode');
        }

        /// If tmpDir is false, then create a temporary directory.
        if (!codeDir) {
          await Directory('C:\\fluttermatic\\code').create();
          await logger.file(LogTypeTag.INFO,
              'Created code directory for extracting vscode files');
        }

        /// Downloading JDK.
        await context.read<DownloadNotifier>().downloadFile(
              platform == 'windows'
                  ? 'https://az764295.vo.msecnd.net/stable/$sha/VSCode-win32-x64-$tagName.zip'
                  : platform == 'mac'
                      ? api!.data!['vscode'][platform]['universal']
                      : api!.data!['vscode'][platform]['TarGZ'],
              platform == 'linux' ? 'code.tar.gz' : 'code.zip',
              dir.path + '\\tmp',
              progressBarColor: const Color(0xFF209EF0),
            );
        value = 'Extracting VSCode';

        /// Extract java from compressed file.
        bool vscExtracted = await unzip(
          dir.path + '\\tmp\\code.zip',
          'C:\\fluttermatic\\code',
        );
        if (vscExtracted) {
          value = 'Extracted VSCode';
          await logger.file(
              LogTypeTag.INFO, 'VSCode extraction was successfull');
        } else {
          value = 'Extracting VSCode failed';
          await logger.file(LogTypeTag.ERROR, 'VSCode extraction failed.');
        }

        value = 'Extracting VSCode done';

        /// Appending path to env
        bool isVSCPathSet =
            await setPath('C:\\fluttermatic\\code\\bin\\', dir.path);
        if (isVSCPathSet) {
          value = 'VSCode set to path';
          await logger.file(LogTypeTag.INFO, 'VSCode set to path');
        } else {
          value = 'VSCode set to path failed';
          await logger.file(LogTypeTag.ERROR, 'VSCode set to path failed');
        }
      } else {
        /// Make a fake delay of 1 second such that UI looks cool.
        await Future<dynamic>.delayed(const Duration(seconds: 1));
        value = 'VS Code found';
        await logger.file(LogTypeTag.INFO, 'VS Code found at - $vscPath');

        /// Make a fake delay of 1 second such that UI looks cool.
        await Future<dynamic>.delayed(const Duration(seconds: 1));
        value = 'Fetching VS Code version';
        vscVersion = await getVSCBinVersion();
        versions.vsCode = vscVersion.toString();
        await logger.file(
            LogTypeTag.INFO, 'VS Code version : ${versions.vsCode}');
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

class VSCodeChangeNotifier extends VSCodeNotifier {
  VSCodeChangeNotifier() : super('Checking VS Code');
}
