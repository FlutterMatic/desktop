// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

// 📦 Package imports:
import 'package:http/http.dart' as http;

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/core/services/logs.dart';

Future<void> checkNewFlutterMaticVersion(List<dynamic> data) async {
  SendPort port = data[0];
  String path = data[1];
  String platform = data[2];

  String version = 'v$appVersion-${appBuild.toLowerCase()}';

  http.Response result = await http.get(
      Uri.parse('https://api.github.com/repos/fluttermatic/desktop/releases'));

  if (result.statusCode == 200) {
    String latestVersion =
        (jsonDecode(result.body) as List<dynamic>)[0]['tag_name'];

    if (latestVersion.toLowerCase() != version) {
      await logger.file(LogTypeTag.warning,
          'Found a new FlutterMatic version. Current version: $version Latest version: $latestVersion',
          logDir: Directory(path));

      bool isTargeted = false;

      // Finds the asset in the API that is for this platform. If there
      // is no asset for this release on this platform, then it means
      // that the release is not targeted for this platform and perhaps
      // it's only a fix for a specific platform.
      String downloadUrl = (jsonDecode(result.body) as List<dynamic>)
          .firstWhere((dynamic asset) {
        if ((asset as Map<String, dynamic>)['name'].toLowerCase() == platform) {
          isTargeted = true;
          return true;
        }
        return false;
      })['browser_download_url'];

      if (isTargeted) {
        port.send(<dynamic>[true, downloadUrl]);
        return;
      } else {
        await logger.file(LogTypeTag.info,
            'Release is not targeted. Skipping. Latest version: $latestVersion Current version: $version Platform OS: $platform',
            logDir: Directory(path));

        port.send(<dynamic>[false, null]);
        return;
      }
    } else {
      await logger.file(LogTypeTag.info,
          'No new FlutterMatic version found. Current version: $version',
          logDir: Directory(path));

      port.send(<dynamic>[false, null]);
      return;
    }
  } else {
    await logger.file(LogTypeTag.error,
        'Failed to check for updates. Response code: ${result.statusCode}',
        logDir: Directory(path));

    port.send(<dynamic>[false, null]);
    return;
  }
}
