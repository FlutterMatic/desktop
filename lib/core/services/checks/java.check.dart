import 'dart:developer' as console;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:manager/core/libraries/models.dart';
import 'package:manager/meta/utils/bin/java.bin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell.dart';
import 'package:provider/provider.dart';
import 'package:pub_semver/src/version.dart';

/// [JavaNotifier] class is a [ValueNotifier]
/// for java SDK checks.
class JavaNotifier extends ValueNotifier<String> {
  JavaNotifier([String value = 'Checking java']) : super(value);

  /// [javaVersion] value holds java version information
  Version? javaVersion;

  /// Check java exists in the system or not.
  Future<void> checkJava(BuildContext context, FluttermaticAPI? api) async {
    try {
      /// Make a fake delay of 1 second such that UI looks cool.
      await Future<dynamic>.delayed(const Duration(seconds: 1));

      /// The comppressed archive type.
      String? archiveType = Platform.isLinux ? 'tar.gz' : 'zip';

      /// Get the platform
      String? platform = Platform.isWindows
          ? 'windows'
          : Platform.isMacOS
              ? 'mac'
              : 'linux';

      /// Checking for Java path,
      /// returns path to java or null if it doesn't exist.
      String? javaPath = await which('java');

      /// Application supporting Directory
      Directory dir = await getApplicationSupportDirectory();

      /// Check if path is null, if so, we need to download it.
      if (javaPath == null) {
        value = 'Java not installed';
        await logger.file(
            LogTypeTag.WARNING, 'Java not installed in the system.');
        value = 'Downloading Java';
        await logger.file(LogTypeTag.INFO, 'Downloading Java');

        /// Check for temporary Directory to download files
        bool tmpDir = await checkDir(dir.path, subDirName: 'tmp');

        /// If tmpDir is false, then create a temporary directory.
        if (tmpDir == false) {
          await Directory('${dir.path}\\tmp').create();
          await logger.file(
              LogTypeTag.INFO, 'Created tmp directory while checking Java');
        }

        /// Downloading JDK.
        await context.read<DownloadNotifier>().downloadFile(
              api!.data!['java']['JDK'][platform],
              'jdk.$archiveType',
              dir.path + '\\tmp',
              progressBarColor: const Color(0xFFF8981D),
              value: 'Downloading JDK',
            );

        /// Extract java from compressed file.
        bool jdkExtracted = await unzip(
          dir.path + '\\tmp\\' + 'jdk.$archiveType',
          'C:\\fluttermatic\\',
          value: 'Extracting JDK',
        );
        jdkExtracted
            ? await logger.file(
                LogTypeTag.INFO, 'Java-DK extraction was successfull')
            : await logger.file(LogTypeTag.ERROR, 'Java-DK extraction failed.');

        /// Appending path to env
        bool isJDKPathSet =
            await setPath('C:\\fluttermatic\\java\\bin\\', appDir: dir.path);
        if (isJDKPathSet) {
          value = 'Flutter-SDK set to path';
          await logger.file(LogTypeTag.INFO, 'Flutter-SDK set to path');
        } else {
          value = 'Flutter-SDK set to path failed';
          await logger.file(LogTypeTag.ERROR, 'Flutter-SDK set to path failed');
        }

        /// Downloading JRE
        await context.read<DownloadNotifier>().downloadFile(
              api.data!['java']['JRE']['windows'],
              'jre.$archiveType',
              dir.path + '\\tmp',
              progressBarColor: const Color(0xFFF8981D),
              value: 'Downloading JRE',
            );

        /// Extract java from compressed file.
        bool jreExtracted = await unzip(
          dir.path + '\\tmp\\' + 'jre.$archiveType',
          'C:\\fluttermatic\\',
          value: 'Extracting JRE',
        );
        jreExtracted
            ? await logger.file(
                LogTypeTag.INFO, 'Java-DK extraction was successfull')
            : await logger.file(LogTypeTag.ERROR, 'Java-DK extraction failed.');

        /// Appending path to env
        bool isJREPathSet =
            await setPath('C:\\fluttermatic\\java\\bin\\', appDir: dir.path);
        if (isJREPathSet) {
          value = 'Flutter-SDK set to path';
          await logger.file(LogTypeTag.INFO, 'Flutter-SDK set to path');
        } else {
          value = 'Flutter-SDK set to path failed';
          await logger.file(LogTypeTag.ERROR, 'Flutter-SDK set to path failed');
        }
      }

      /// Else we need to get version information.
      else {
        /// Make a fake delay of 1 second such that UI looks cool.
        await Future<dynamic>.delayed(const Duration(seconds: 1));
        value = 'Java found';
        await logger.file(LogTypeTag.INFO, 'Java found at - $javaPath');

        /// Make a fake delay of 1 second such that UI looks cool.
        await Future<dynamic>.delayed(const Duration(seconds: 1));
        value = 'Fetching java version';
        javaVersion = await getJavaBinVersion();
        versions.java = javaVersion.toString();
        await logger.file(LogTypeTag.INFO, 'Java version : ${versions.java}');
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

class JavaChangeNotifier extends JavaNotifier {
  JavaChangeNotifier() : super('Checking Java');
}
