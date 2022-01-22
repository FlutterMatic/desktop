// Dart imports:
import 'dart:io';

// Project imports:
import '../script.dart';
import '../utils.dart';
import 'version.dart';

Future<void> confirmChangelogExists(Version version) async {
  // Make sure that the changelog exists for this version.
  File _changelog = File('$fluttermaticDesktopPath/CHANGELOG.md');

  if (!await _changelog.exists()) {
    print(errorPen('Changelog does not exist.'));
    exit(1);
  }

  // Make sure that the changelog has the version number.
  List<String> _changelogContent = await _changelog.readAsLines();

  bool _foundVersion = false;

  String _expected =
      '### v${version.major}.${version.minor}.${version.patch} - ${version.releaseType.name.toUpperCase()}';

  for (String _line in _changelogContent) {
    if (_line.trim() == _expected) {
      _foundVersion = true;
      break;
    }
  }

  if (!_foundVersion) {
    print(errorPen(
        'Changelog does not contain the version number. Please add the changes to the changelog and make sure it\'s in the format of $_expected'));
    exit(1);
  }
}
