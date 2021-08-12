import 'dart:developer' as console;
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:manager/app/constants/constants.dart';
import 'package:manager/core/libraries/notifiers.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:manager/core/libraries/models.dart';
import 'package:manager/meta/utils/bin/java.bin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell.dart';
import 'package:provider/provider.dart';
// ignore: implementation_imports
import 'package:pub_semver/src/version.dart';

/// [JavaNotifier] class is a [ValueNotifier]
/// for java SDK checks.
class JavaNotifier extends ChangeNotifier {
  /// [javaVersion] value holds java version information
  Version? javaVersion;

  /// Check java exists in the system or not.
  Future<void> checkJava(BuildContext context, FluttermaticAPI? api) async {
    try {
      /// Make a fake delay of 1 second such that UI looks cool.
      await Future<dynamic>.delayed(const Duration(seconds: 1));

      /// The compressed archive type.
      String? archiveType = Platform.isLinux ? 'tar.gz' : 'zip';

      /// Checking for Java path,
      /// returns path to java or null if it doesn't exist.
      String? javaPath = await which('java');

      /// Application supporting Directory
      Directory dir = await getApplicationSupportDirectory();

      /// Check if path is null, if so, we need to download it.
      if (javaPath == null) {
        await logger.file(
            LogTypeTag.WARNING, 'Java not installed in the system.');
        await logger.file(LogTypeTag.INFO, 'Downloading Java');

        /// Downloading JDK.
        await context.read<DownloadNotifier>().downloadFile(
              api!.data!['java']['JDK'][platform],
              'jdk.$archiveType',
              dir.path + '\\tmp',
              progressBarColor: const Color(0xFFF8981D),
            );

        /// Extract java from compressed file.
        bool jdkExtracted = await unzip(
          dir.path + '\\tmp\\' + 'jdk.$archiveType',
          'C:\\fluttermatic\\',
        );
        if (jdkExtracted) {
          await logger.file(
              LogTypeTag.INFO, 'Java-DK extraction was successful');
        } else {
          await logger.file(LogTypeTag.ERROR, 'Java-DK extraction failed.');
        }

        /// Appending path to env
        bool isJDKPathSet =
            await setPath('C:\\fluttermatic\\java\\bin\\', dir.path);
        if (isJDKPathSet) {
          await logger.file(LogTypeTag.INFO, 'Java-DK set to path');
        } else {
          await logger.file(LogTypeTag.ERROR, 'Java-DK set to path failed');
        }

        /// Downloading JRE
        await context.read<DownloadNotifier>().downloadFile(
              api.data!['java']['JRE'][platform],
              'jre.$archiveType',
              dir.path + '\\tmp',
              progressBarColor: const Color(0xFF1565C0),
            );

        // value = 'Extracting JRE';

        /// Extract java from compressed file.
        bool jreExtracted = await unzip(
          dir.path + '\\tmp\\' + 'jre.$archiveType',
          'C:\\fluttermatic\\',
        );
        if (jreExtracted) {
          await logger.file(
              LogTypeTag.INFO, 'Java-DK extraction was successful');
        } else {
          await logger.file(LogTypeTag.ERROR, 'Java-DK extraction failed.');
        }

        /// Appending path to env
        bool isJREPathSet =
            await setPath('C:\\fluttermatic\\java\\bin\\', dir.path);
        if (isJREPathSet) {
          await logger.file(LogTypeTag.INFO, 'Java-RE set to path');
        } else {
          await logger.file(LogTypeTag.ERROR, 'Java-RE set to path failed');
        }
      }

      /// Else we need to get version information.
      else {
        /// Make a fake delay of 1 second such that UI looks cool.
        await Future<dynamic>.delayed(const Duration(seconds: 1));
        await logger.file(LogTypeTag.INFO, 'Java found at - $javaPath');

        /// Make a fake delay of 1 second such that UI looks cool.
        await Future<dynamic>.delayed(const Duration(seconds: 1));
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
