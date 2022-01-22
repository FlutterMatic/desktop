// Dart imports:
import 'dart:io';

// Project imports:
import '../script.dart';
import '../utils.dart';
import 'version.dart';

Future<void> changePubspecVersion(String version) async {
  File _pubspec = File('$fluttermaticDesktopPath\\pubspec.yaml');

  List<String> _content = await _pubspec.readAsLines();

  Version? _currentVersion;

  for (int i = 0; i < _content.length; i++) {
    if (_content[i].startsWith('version:')) {
      _currentVersion = Version.fromString(_content[i].split(':')[1].trim());

      // Make sure that the new version is greater than the current one.
      if (_currentVersion.isGreaterThan(Version.fromString(version))) {
        print(errorPen(
            'New version is not greater than the current one. Current: ${_currentVersion.toString()} New: $version'));
        exit(1);
      }

      _content[i] = 'version: $version';
    }
  }

  if (_currentVersion == null) {
    print(errorPen('Could not find the current version.'));
    exit(1);
  }

  await _pubspec.writeAsString(_content.join('\n'));

  print(greenPen('Version updated to $version'));
}
