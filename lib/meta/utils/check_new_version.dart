// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

// 📦 Package imports:
import 'package:http/http.dart' as http;

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/core/services/logs.dart';

Future<void> checkNewFlutterMaticVersion(List<dynamic> data) async {
  SendPort _port = data[0];
  String _path = data[1];
  String _platform = data[2];

  String _version = 'v' + appVersion + '-' + appBuild.toLowerCase();

  http.Response _result = await http.get(
      Uri.parse('https://api.github.com/repos/fluttermatic/desktop/releases'));

  if (_result.statusCode == 200) {
    String _latestVersion =
        (jsonDecode(_result.body) as List<dynamic>)[0]['tag_name'];

    if (_latestVersion.toLowerCase() != _version) {
      await logger.file(LogTypeTag.warning,
          'Found a new FlutterMatic version. Current version: $_version Latest version: $_latestVersion',
          logDir: Directory(_path));

      bool _isTargeted = false;

      // Finds the asset in the API that is for this platform. If there
      // is no asset for this release on this platform, then it means
      // that the release is not targeted for this platform and perhaps
      // it's only a fix for a specific platform.
      String _downloadUrl = (jsonDecode(_result.body) as List<dynamic>)
          .firstWhere((dynamic asset) {
        if ((asset as Map<String, dynamic>)['name'].toLowerCase() ==
            _platform) {
          _isTargeted = true;
          return true;
        }
        return false;
      })['browser_download_url'];

      if (_isTargeted) {
        _port.send(<dynamic>[true, _downloadUrl]);
        return;
      } else {
        await logger.file(LogTypeTag.info,
            'Release is not targeted. Skipping. Latest version: $_latestVersion Current version: $_version Platform OS: $_platform',
            logDir: Directory(_path));

        _port.send(<dynamic>[false, null]);
        return;
      }
    } else {
      await logger.file(LogTypeTag.info,
          'No new FlutterMatic version found. Current version: $_version',
          logDir: Directory(_path));

      _port.send(<dynamic>[false, null]);
      return;
    }
  } else {
    await logger.file(LogTypeTag.error,
        'Failed to check for updates. Response code: ${_result.statusCode}',
        logDir: Directory(_path));

    _port.send(<dynamic>[false, null]);
    return;
  }
}
