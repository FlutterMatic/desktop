// 🎯 Dart imports:
import 'dart:async';
import 'dart:io';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class CheckServicesState {
  final bool loading;
  final String flutterError;
  final String gitError;
  final String studioError;
  final String dartError;
  final String javaError;
  final String codeError;

  const CheckServicesState({
    this.loading = true,
    this.flutterError = '',
    this.gitError = '',
    this.studioError = '',
    this.dartError = '',
    this.javaError = '',
    this.codeError = '',
  });

  factory CheckServicesState.initial() => const CheckServicesState();

  CheckServicesState copyWith({
    bool? loading,
    String? flutterError,
    String? gitError,
    String? studioError,
    String? dartError,
    String? javaError,
    String? codeError,
  }) {
    return CheckServicesState(
      loading: loading ?? this.loading,
      flutterError: flutterError ?? this.flutterError,
      gitError: gitError ?? this.gitError,
      studioError: studioError ?? this.studioError,
      dartError: dartError ?? this.dartError,
      javaError: javaError ?? this.javaError,
      codeError: codeError ?? this.codeError,
    );
  }
}

class CheckServicesNotifier extends StateNotifier<CheckServicesState> {
  final Ref ref;

  CheckServicesNotifier(this.ref) : super(CheckServicesState.initial());

  /// Getters/setters for the last fetched values.
  ServiceCheckResponse? _flutter;
  ServiceCheckResponse? get flutter => _flutter;

  ServiceCheckResponse? _dart;
  ServiceCheckResponse? get dart => _dart;

  ServiceCheckResponse? _git;
  ServiceCheckResponse? get git => _git;

  ServiceCheckResponse? _adb;
  ServiceCheckResponse? get studio => _adb;

  ServiceCheckResponse? _vsCode;
  ServiceCheckResponse? get vsCode => _vsCode;

  ServiceCheckResponse? _java;
  ServiceCheckResponse? get java => _java;

  // Last fetched time
  DateTime? _lastFetched;

  /// The timeout duration which is 30 minutes.
  static const Duration _timeout = Duration(minutes: 30);

  /// An init function which calls all the check functions.
  Future<void> init(String logPath) async {
    if (_lastFetched != null &&
        DateTime.now().difference(_lastFetched!) < _timeout) {
      await logger.file(LogTypeTag.info,
          'Services already checked within timeout frame of ${_timeout.inMinutes} minutes.');

      return;
    }

    state = state.copyWith(loading: true);

    Directory path = Directory(logPath);

    try {
      await _checkFlutter(path);
    } catch (e) {
      await logger.file(LogTypeTag.error, 'Error while checking Flutter: $e');
      state = state.copyWith(
          flutterError: 'Something went wrong while checking Flutter.');
    }

    try {
      await _checkDart(path);
    } catch (e) {
      await logger.file(LogTypeTag.error, 'Error while checking Dart: $e');
      state = state.copyWith(
          dartError: 'Something went wrong while checking Dart.');
    }

    try {
      await _checkGit(path);
    } catch (e) {
      await logger.file(LogTypeTag.error, 'Error while checking Git: $e');
      state =
          state.copyWith(gitError: 'Something went wrong while checking Git.');
    }

    try {
      await _checkJava(path);
    } catch (e) {
      await logger.file(LogTypeTag.error, 'Error while checking Java: $e');
      state = state.copyWith(
          javaError: 'Something went wrong while checking Java.');
    }

    try {
      await _checkADBridge(path);
    } catch (e) {
      await logger.file(LogTypeTag.error, 'Error while checking ADB: $e');
      state = state.copyWith(
          studioError: 'Something went wrong while checking ADB.');
    }

    try {
      await _checkVSCode(path);
    } catch (e) {
      await logger.file(LogTypeTag.error, 'Error while checking VS Code: $e');
      state = state.copyWith(
          codeError: 'Something went wrong while checking VS Code.');
    }

    _lastFetched = DateTime.now();

    state = state.copyWith(loading: false);

    await logger.file(
        LogTypeTag.info, 'Services checked with the following status:');
    await logger.file(LogTypeTag.info, 'Flutter: ${_flutter?.version}');
    await logger.file(LogTypeTag.info, 'Dart: ${_dart?.version}');
    await logger.file(LogTypeTag.info, 'Git: ${_git?.version}');
    await logger.file(LogTypeTag.info, 'Java: ${_java?.version}');
    await logger.file(LogTypeTag.info, 'ADB: ${_adb?.version}');
    await logger.file(LogTypeTag.info, 'VS Code: ${_vsCode?.version}');
  }

  /// Function checks whether Dart exists in the system or not.
  ///
  /// Sample response:
  /// Dart SDK version: 2.15.1 (stable) (Tue Dec 14 13:32:21 2021 +0100) on "windows_x64"
  Future<void> _checkDart(Directory logPath) async {
    try {
      String? dart = await which('dart');

      if (dart == null) {
        await logger.file(LogTypeTag.warning, 'Dart not found on device.',
            logDir: logPath);

        _dart = ServiceCheckResponse(version: null, channel: null);
      }

      Version? version;
      String? channel;

      List<ProcessResult> result = [];

      try {
        result = await shell.run('dart --version');
      } catch (e, s) {
        await logger.file(
            LogTypeTag.error, 'CheckServices Failed to get Dart version.',
            error: e, stackTrace: s, logDir: logPath);

        _dart = ServiceCheckResponse(version: null, channel: null);
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

      _dart = ServiceCheckResponse(
        version: version,
        channel: channel,
      );
    } catch (e, s) {
      await logger.file(
          LogTypeTag.error, 'Failed to fetch Dart information on system.',
          error: e, stackTrace: s, logDir: logPath);

      _dart = ServiceCheckResponse(version: null, channel: null);

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
  Future<void> _checkFlutter(Directory logPath) async {
    try {
      String? flutter = await which('flutter');

      if (flutter == null) {
        await logger.file(LogTypeTag.warning, 'Flutter not found on system.',
            logDir: logPath);

        _flutter = ServiceCheckResponse(version: null, channel: null);
      }

      FlutterBinInfo? info = await getFlutterBinInfo();

      await logger.file(
          LogTypeTag.info, 'Flutter found on system: ${info?.version}',
          logDir: logPath);

      _flutter = ServiceCheckResponse(
        version: info?.version,
        channel: info?.channel,
      );
    } catch (e, s) {
      await logger.file(
          LogTypeTag.error, 'Failed to fetch Flutter information on system.',
          error: e, stackTrace: s, logDir: logPath);

      _flutter = ServiceCheckResponse(version: null, channel: null);

      rethrow;
    }
  }

  /// Function checks whether Android Studio exists in the system or not.
  /// Sample response:
  /// Android Debug Bridge version 1.0.41
  /// Version 31.0.3-7562133
  /// Installed as C:\Users\ziyad\AppData\Local\Android\Sdk\platform-tools\adb.exe
  Future<void> _checkADBridge(Directory logPath) async {
    try {
      String? adb = await which('adb');

      if (adb == null) {
        await logger.file(LogTypeTag.warning, 'ADB not found on system.',
            logDir: logPath);

        _adb = ServiceCheckResponse(version: null, channel: null);
      }

      ADBBinInfo? info = await getADBBinInfo();

      await logger.file(
          LogTypeTag.info, 'ADB found on system: ${info?.adbVersion}',
          logDir: logPath);

      _adb = ServiceCheckResponse(
        version: info?.adbVersion,
        channel: null,
      );
    } catch (e, s) {
      await logger.file(LogTypeTag.error,
          'Failed to fetch Android Studio information on system.',
          error: e, stackTrace: s, logDir: logPath);

      _adb = ServiceCheckResponse(version: null, channel: null);

      rethrow;
    }
  }

  /// Function checks whether VS Code exists in the system or not.
  /// Sample response:
  /// 1.63.2
  /// 899d46d82c4c95423fb7e10e68eba52050e30ba3
  /// x64
  Future<void> _checkVSCode(Directory logPath) async {
    try {
      String? vscode = await which('code');

      if (vscode == null) {
        await logger.file(LogTypeTag.warning, 'VSCode not found on system.',
            logDir: logPath);

        _vsCode = ServiceCheckResponse(version: null, channel: null);
      }

      VSCBinInfo? info = await getVSCBinInfo();

      await logger.file(
          LogTypeTag.info, 'VSCode found on system: ${info?.vscVersion}',
          logDir: logPath);

      _vsCode = ServiceCheckResponse(
        version: info?.vscVersion,
        channel: null,
      );
    } catch (e, s) {
      await logger.file(
          LogTypeTag.error, 'Failed to fetch VSCOde information on system.',
          error: e, stackTrace: s, logDir: logPath);

      _vsCode = ServiceCheckResponse(version: null, channel: null);

      rethrow;
    }
  }

  /// Function checks whether Git exists in the system or not.
  /// Sample response:
  /// git version 2.22.0.windows.1
  Future<void> _checkGit(Directory logPath) async {
    try {
      String? git = await which('git');

      if (git == null) {
        await logger.file(LogTypeTag.warning, 'Git not found on device.',
            logDir: logPath);

        _git = ServiceCheckResponse(version: null, channel: null);
      }

      GitBinInfo? info = await getGitBinInfo();

      await logger.file(
          LogTypeTag.info, 'Git found on system: ${info?.gitVersion}',
          logDir: logPath);

      _git = ServiceCheckResponse(
        version: info?.gitVersion,
        channel: null,
      );
    } catch (e, s) {
      await logger.file(
          LogTypeTag.error, 'Failed to fetch Git information on system.',
          error: e, stackTrace: s, logDir: logPath);

      _git = ServiceCheckResponse(version: null, channel: null);

      rethrow;
    }
  }

  /// Function checks whether Java exists in the system or not.
  /// Sample response:
  /// java 16 2021-03-16
  /// Java(TM) SE Runtime Environment (build 16+36-2231)
  /// Java HotSpot(TM) 64-Bit Server VM (build 16+36-2231, mixed mode, sharing)
  Future<void> _checkJava(Directory logPath) async {
    try {
      String? java = await which('java');

      if (java == null) {
        await logger.file(LogTypeTag.warning, 'Java not found on device.',
            logDir: logPath);

        _java = ServiceCheckResponse(version: null, channel: null);
      }

      JavaBinInfo? info = await getJavaBinInfo();

      if (info == null) {
        await logger.file(LogTypeTag.warning, 'Java not found on device.',
            logDir: logPath);

        _java = ServiceCheckResponse(version: null, channel: null);
      }

      await logger.file(
          LogTypeTag.info, 'Java found on system: ${info?.javaVersion}',
          logDir: logPath);

      _java = ServiceCheckResponse(
        version: info?.javaVersion,
        channel: null,
      );
    } catch (e, s) {
      await logger.file(
          LogTypeTag.error, 'Failed to fetch Java information on system.',
          error: e, stackTrace: s, logDir: logPath);

      _java = ServiceCheckResponse(version: null, channel: null);

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
