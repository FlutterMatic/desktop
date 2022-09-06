// 🎯 Dart imports:
import 'dart:async';
import 'dart:io';

// 📦 Package imports:
import 'package:process_run/shell.dart';
import 'package:pub_semver/src/version.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/bin/adb.dart';
import 'package:fluttermatic/bin/code.dart';
import 'package:fluttermatic/bin/flutter.dart';
import 'package:fluttermatic/bin/git.dart';
import 'package:fluttermatic/bin/java.dart';
import 'package:fluttermatic/core/services/logs.dart';

class CheckServices {
  /// Function checks whether Dart exists in the system or not.
  ///
  /// Sample response:
  /// Dart SDK version: 2.15.1 (stable) (Tue Dec 14 13:32:21 2021 +0100) on "windows_x64"
  static Future<ServiceCheckResponse> checkDart([Directory? logPath]) async {
    try {
      String? dart = await which('dart');

      if (dart == null) {
        await logger.file(LogTypeTag.warning, 'Dart not found on device.',
            logDir: logPath);
        return ServiceCheckResponse(
          version: null,
          channel: null,
        );
      }

      Version? version;
      String? channel;

      List<ProcessResult> result;

      try {
        result = await shell.run('dart --version');
      } catch (_, s) {
        await logger.file(
            LogTypeTag.error, 'CheckServices Failed to get Dart version: $_',
            stackTraces: s, logDir: logPath);
        return ServiceCheckResponse(
          channel: channel,
          version: version,
        );
      }

      if (result.last.stdout.toString().contains('Dart SDK version')) {
        version = Version.parse(result.last.stdout.toString().split(' ')[3]);
        channel = result.last.stdout
            .toString()
            .split(' ')[4]
            .toString()
            .replaceAll('(', '')
            .replaceAll(')', '')
            .trim();
        await logger.file(LogTypeTag.info, 'Dart version: $version',
            logDir: logPath);
        await logger.file(LogTypeTag.info, 'Dart channel: $channel',
            logDir: logPath);
      }

      return ServiceCheckResponse(
        version: version,
        channel: channel,
      );
    } catch (_, s) {
      await logger.file(
          LogTypeTag.error, 'Failed to fetch dart information on system: $_',
          stackTraces: s, logDir: logPath);
      rethrow;
    }
  }

  /// Function checks whether Flutter exists in the system or not.
  ///
  /// Sample response:
  /// Flutter 2.8.1 • channel stable • https://github.com/flutter/flutter.git
  /// Framework • revision 77d935af4d (5 weeks ago) • 2021-12-16 08:37:33 -0800
  /// Engine • revision 890a5fca2e
  /// Tools • Dart 2.15.1
  static Future<ServiceCheckResponse> checkFlutter([Directory? logPath]) async {
    try {
      String? flutter = await which('flutter');

      if (flutter == null) {
        await logger.file(LogTypeTag.warning, 'Flutter not found on system.',
            logDir: logPath);
        return ServiceCheckResponse(
          version: null,
          channel: null,
        );
      }

      FlutterBinInfo? info = await getFlutterBinInfo();
      await logger.file(
          LogTypeTag.info, 'Flutter found on system: ${info?.version}',
          logDir: logPath);

      return ServiceCheckResponse(
        version: info?.version,
        channel: info?.channel,
      );
    } catch (_, s) {
      await logger.file(
          LogTypeTag.error, 'Failed to fetch flutter information on system: $_',
          stackTraces: s, logDir: logPath);
      rethrow;
    }
  }

  /// Function checks whether Android Studio exists in the system or not.
  /// Sample response:
  /// Android Debug Bridge version 1.0.41
  /// Version 31.0.3-7562133
  /// Installed as C:\Users\ziyad\AppData\Local\Android\Sdk\platform-tools\adb.exe
  static Future<ServiceCheckResponse> checkADBridge(
      [Directory? logPath]) async {
    try {
      String? adb = await which('adb');

      if (adb == null) {
        await logger.file(LogTypeTag.warning, 'ADB not found on system.',
            logDir: logPath);
        return ServiceCheckResponse(
          version: null,
          channel: null,
        );
      }

      ADBBinInfo? info = await getADBBinInfo();
      await logger.file(
          LogTypeTag.info, 'ADB found on system: ${info?.adbVersion}',
          logDir: logPath);

      return ServiceCheckResponse(
        version: info?.adbVersion,
        channel: null,
      );
    } catch (_, s) {
      await logger.file(LogTypeTag.error,
          'Failed to fetch android studio information on system: $_',
          stackTraces: s, logDir: logPath);
      rethrow;
    }
  }

  /// Function checks whether VS Code exists in the system or not.
  /// Sample response:
  /// 1.63.2
  /// 899d46d82c4c95423fb7e10e68eba52050e30ba3
  /// x64
  static Future<ServiceCheckResponse> checkVSCode([Directory? logPath]) async {
    try {
      String? vscode = await which('code');

      if (vscode == null) {
        await logger.file(LogTypeTag.warning, 'VSCode not found on system.',
            logDir: logPath);
        return ServiceCheckResponse(
          version: null,
          channel: null,
        );
      }

      VSCBinInfo? info = await getVSCBinInfo();
      await logger.file(
          LogTypeTag.info, 'VSCode found on system: ${info?.vscVersion}',
          logDir: logPath);

      return ServiceCheckResponse(
        version: info?.vscVersion,
        channel: null,
      );
    } catch (_, s) {
      await logger.file(
          LogTypeTag.error, 'Failed to fetch vscode information on system: $_',
          stackTraces: s, logDir: logPath);
      rethrow;
    }
  }

  /// Function checks whether Git exists in the system or not.
  /// Sample response:
  /// git version 2.22.0.windows.1
  static Future<ServiceCheckResponse> checkGit([Directory? logPath]) async {
    try {
      String? git = await which('git');

      if (git == null) {
        await logger.file(LogTypeTag.warning, 'Git not found on device.',
            logDir: logPath);
        return ServiceCheckResponse(
          version: null,
          channel: null,
        );
      }

      GitBinInfo? info = await getGitBinInfo();
      await logger.file(
          LogTypeTag.info, 'Git found on system: ${info?.gitVersion}',
          logDir: logPath);

      return ServiceCheckResponse(
        version: info?.gitVersion,
        channel: null,
      );
    } catch (_, s) {
      await logger.file(
          LogTypeTag.error, 'Failed to fetch git information on system: $_',
          stackTraces: s, logDir: logPath);
      rethrow;
    }
  }

  /// Function checks whether Java exists in the system or not.
  /// Sample response:
  /// java 16 2021-03-16
  /// Java(TM) SE Runtime Environment (build 16+36-2231)
  /// Java HotSpot(TM) 64-Bit Server VM (build 16+36-2231, mixed mode, sharing)
  static Future<ServiceCheckResponse> checkJava([Directory? logPath]) async {
    try {
      String? java = await which('java');

      if (java == null) {
        await logger.file(LogTypeTag.warning, 'Java not found on device.',
            logDir: logPath);
        return ServiceCheckResponse(
          version: null,
          channel: null,
        );
      }

      JavaBinInfo? info = await getJavaBinInfo();

      if (info == null) {
        return ServiceCheckResponse(
          version: null,
          channel: null,
        );
      }

      await logger.file(
          LogTypeTag.info, 'Java found on system: ${info.javaVersion}',
          logDir: logPath);

      return ServiceCheckResponse(
        version: info.javaVersion,
        channel: null,
      );
    } catch (_, s) {
      await logger.file(
          LogTypeTag.error, 'Failed to fetch java information on system: $_',
          stackTraces: s, logDir: logPath);
      rethrow;
    }
  }
}

class ServiceCheckResponse {
  final Version? version;
  final String? channel;

  ServiceCheckResponse({
    required this.version,
    required this.channel,
  });
}
