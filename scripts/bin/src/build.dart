// Dart imports:
import 'dart:io';

// Project imports:
import '../script.dart';
import '../utils.dart';
import 'build_utils/build.dart';
import 'build_utils/move_build.dart';

Future<void> buildAppWithMode(BuildMode mode) async {
  // Asks for the new version we are building for.
  print('\n📝  What version are we building for?\n');

  String? _version = stdin.readLineSync();

  if (_version == null) {
    print(errorPen('Please provide a version number.'));
    exit(1);
  }

  // Makes sure that the version is valid.
  if (!isValidVersion(_version)) {
    print(errorPen(
        'Version number is invalid. Make sure it\'s something like x.y.z'));
    exit(1);
  }

  await confirmChangelogExists(_version);

  // Change the pubspec.yaml file to the new version.
  await changePubspecVersion(_version.trim());

  print(infoPen('Building...'));

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

Future<void> confirmChangelogExists(String version) async {
  // Make sure that the changelog exists for this version.
  File _changelog = File('$fluttermaticDesktopPath/CHANGELOG.md');

  if (!await _changelog.exists()) {
    print(errorPen('Changelog does not exist.'));
    exit(1);
  }

  // Make sure that the changelog has the version number.
  List<String> _changelogContent = await _changelog.readAsLines();

  bool _foundVersion = false;

  for (String _line in _changelogContent) {
    if (_line.startsWith('### Version $version')) {
      _foundVersion = true;
      break;
    }
  }

  if (!_foundVersion) {
    print(errorPen(
        'Changelog does not contain the version number. Please add the changes to the changelog and make sure it\'s in the format of ### Version x.y.z'));
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

bool isValidVersion(String version) {
  List<String> _versionNumbers = version.split('.');

  if (_versionNumbers.length != 3) {
    return false;
  }

  for (String number in _versionNumbers) {
    if (int.tryParse(number) == null) {
      return false;
    }
  }

  return true;
}

class Version {
  final int major;
  final int minor;
  final int patch;

  const Version({
    required this.major,
    required this.minor,
    required this.patch,
  });

  factory Version.fromString(String version) {
    List<String> _versionNumbers = version.split('.');

    return Version(
      major: int.parse(_versionNumbers[0]),
      minor: int.parse(_versionNumbers[1]),
      patch: int.parse(_versionNumbers[2]),
    );
  }

  @override
  String toString() {
    return '$major.$minor.$patch';
  }

  bool isGreaterThan(Version version) {
    // Check if the major version is greater.
    if (major > version.major) {
      return true;
    } else if (major < version.major) {
      return false;
    }
    // Check if the minor version is greater.
    else if (minor > version.minor) {
      return true;
    } else if (minor < version.minor) {
      return false;
    }
    // Check if the patch version is greater.
    else if (patch > version.patch) {
      return true;
    } else if (patch < version.patch) {
      return false;
    }

    // If nothing is greater, then they are equal.
    return true;
  }
}
