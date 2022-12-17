// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io';

// 📦 Package imports:
import 'package:http/http.dart' as http;

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/core/services/logs.dart';

// TODO: Use to notify user if there is a new released version available.
Future<bool> hasNewFlutterMaticVersion() async {
  String platform = Platform.operatingSystem;

  String version = 'v$appVersion-${appBuild.toLowerCase()}';

  http.Response result = await http.get(
      Uri.parse('https://api.github.com/repos/fluttermatic/desktop/releases'));

  if (result.statusCode == 200) {
    String latestVersion =
        (jsonDecode(result.body) as List<dynamic>)[0]['tag_name'];

    if (latestVersion.toLowerCase() != version) {
      await logger.file(LogTypeTag.warning,
          'Found a new FlutterMatic version. Current version: $version Latest version: $latestVersion. Checking if targeted update.');

      bool isTargeted = false;

      // Finds the asset in the API that is for this platform. If there
      // is no asset for this release on this platform, then it means
      // that the release is not targeted for this platform and perhaps
      // it's only a fix for a specific platform.
      (jsonDecode(result.body) as List<dynamic>).firstWhere((dynamic asset) {
        if (((asset as Map<String, dynamic>)['name'].toString())
                .toLowerCase() ==
            platform) {
          isTargeted = true;
          return true;
        }

        return false;
      })['browser_download_url'];

      if (isTargeted) {
        await logger.file(LogTypeTag.info,
            'Release is targeted to this platform. Latest version: $latestVersion Current version: $version Platform OS: $platform');

        return true;
      } else {
        await logger.file(LogTypeTag.info,
            'Release is not targeted. Skipping. Latest version: $latestVersion Current version: $version Platform OS: $platform');

        return false;
      }
    } else {
      await logger.file(LogTypeTag.info,
          'No new FlutterMatic version found. Current version: $version');

      return false;
    }
  } else {
    await logger.file(LogTypeTag.error,
        'Failed to check for updates. Response code: ${result.statusCode}');

    return false;
  }
}
