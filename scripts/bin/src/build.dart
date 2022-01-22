// Dart imports:
import 'dart:convert';
import 'dart:io';

// Project imports:
import '../script.dart';
import '../utils.dart';
import 'build_utils/build.dart';
import 'build_utils/move_build.dart';
import 'version.dart';

Future<void> buildAppWithMode(BuildMode mode) async {
  // Asks for the new version we are building for.
  print('\n📝  What version are we building for and its release?\n');

  String? _version = stdin.readLineSync();

  if (_version == null) {
    print(errorPen('Please provide a version number and release.'));
    exit(1);
  }

  // Makes sure that the version is valid.
  if (!Version.isValidVersion(_version)) {
    print(errorPen(
        'Version number is invalid. Make sure it\'s something like x.y.z-alpha'));
    exit(1);
  }

  // Makes sure that the changelog contains the information about this release.
  await confirmChangelogExists(Version.fromString(_version));

  // Updates the .vscode/launch.json file with the new version and release type.
  await updateLaunchJson(Version.fromString(_version));

  // Change the pubspec.yaml file to the new version.
  await changePubspecVersion(_version.trim());

  print(infoPen('Building... This might take a while.'));

  // Build the app in release mode.
  await buildWithMode(mode, Platform.operatingSystem);

  // Capitalize the first letter of the mode.
  String _mode =
      mode.name.substring(0, 1).toUpperCase() + mode.name.substring(1);

  String _out =
      '$fluttermaticDesktopPath\\build\\${Platform.operatingSystem}\\runner\\$_mode';

  // Now it should take the build and put it into the final_builds folder.
  await moveBuildOutput(
      _out, '$fluttermaticDesktopPath\\final_builds\\${mode.name}');
}

Future<void> updateLaunchJson(Version version) async {
  File _file = File('$fluttermaticDesktopPath\\.vscode\\launch.json');

  List<String> _lines = await _file.readAsLines();

  // Remove the comments from the [_lines].
  _lines =
      _lines.where((String line) => !line.trim().startsWith('//')).toList();

  Map<String, dynamic> _contents = jsonDecode(_lines.join(''));

  List<String> _args = (_contents['configurations'][0]['args'] as List<dynamic>)
      .map((dynamic e) => e.toString())
      .toList();

  List<String> _newArgs = <String>[];

  bool _foundReleaseType = false;
  bool _foundCurrentVersion = false;

  String _dartDefine = '--dart-define';
  String _releaseType = 'RELEASE_TYPE=${version.releaseType.name}';
  String _currentVersion =
      'CURRENT_VERSION=${version.major}.${version.minor}.${version.patch}-${version.releaseType.name}';

  for (String arg in _args) {
    if (arg == _dartDefine) {
      continue;
    }
    if (arg.startsWith('RELEASE_TYPE=')) {
      _foundReleaseType = true;
      _newArgs.add(_dartDefine);
      _newArgs.add(_releaseType);
    } else if (arg.startsWith('CURRENT_VERSION=')) {
      _foundCurrentVersion = true;
      _newArgs.add(_dartDefine);
      _newArgs.add(_currentVersion);
    } else {
      _newArgs.add(arg);
    }
  }

  if (!_foundReleaseType) {
    _newArgs.add(_dartDefine);
    _newArgs.add(_releaseType);
  }

  if (!_foundCurrentVersion) {
    _newArgs.add(_dartDefine);
    _newArgs.add(_currentVersion);
  }

  _contents['configurations'][0]['args'] = _newArgs;

  await _file.writeAsString(jsonEncode(_contents));
}

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
