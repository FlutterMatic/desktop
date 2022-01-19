// 🎯 Dart imports:
import 'dart:async';
import 'dart:io';

// 📦 Package imports:
import 'package:pub_semver/src/version.dart';

// 🌎 Project imports:
import 'package:manager/app/constants/constants.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:manager/core/models/check_response.model.dart';

class CheckServices {
  /// Function checks whether Dart exists in the system or not.
  ///
  /// Sample response:
  /// Dart SDK version: 2.15.1 (stable) (Tue Dec 14 13:32:21 2021 +0100) on "windows_x64"
  static Future<ServiceCheckResponse> checkDart() async {
    try {
      Version? _version;
      String? _channel;

      List<ProcessResult> _result = await shell.run('dart --version');

      if (_result.last.stdout.toString().contains('Dart SDK version')) {
        _version = Version.parse(_result.last.stdout.toString().split(' ')[3]);
        _channel = _result.last.stdout
            .toString()
            .split(' ')[4]
            .toString()
            .replaceAll('(', '')
            .replaceAll(')', '')
            .trim();
        await logger.file(LogTypeTag.info, 'Dart version: $_version');
        await logger.file(LogTypeTag.info, 'Dart channel: $_channel');
      }

      return ServiceCheckResponse(
        version: _version,
        channel: _channel,
      );
    } catch (_, s) {
      await logger.file(
          LogTypeTag.error, 'Failed to fetch dart information on system: $_',
          stackTraces: s);
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
  static Future<ServiceCheckResponse> checkFlutter() async {
    try {
      Version? _version;
      String? _channel;

      List<ProcessResult> _result = await shell.run('flutter --version');

      if (_result.first.stdout.toString().startsWith('Flutter')) {
        _version = Version.parse(_result.first.stdout.toString().split(' ')[1]);
        _channel = _result.first.stdout
            .toString()
            .split(' ')[4]
            .toString()
            .replaceAll('(', '')
            .replaceAll(')', '')
            .trim();
        await logger.file(LogTypeTag.info, 'Flutter version: $_version');
        await logger.file(LogTypeTag.info, 'Flutter channel: $_channel');
      }

      return ServiceCheckResponse(
        version: _version,
        channel: _channel,
      );
    } catch (_, s) {
      await logger.file(
          LogTypeTag.error, 'Failed to fetch flutter information on system: $_',
          stackTraces: s);
      rethrow;
    }
  }
}
