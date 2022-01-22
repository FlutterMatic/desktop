// Dart imports:
import 'dart:io';

// Project imports:
import '../utils.dart';

class Version {
  final int major;
  final int minor;
  final int patch;
  final ReleaseType releaseType;

  const Version({
    required this.major,
    required this.minor,
    required this.patch,
    required this.releaseType,
  });

  /// Will parse the version from a string to a [Version] object.
  factory Version.fromString(String version) {
    List<String> _versionNumbers = version.split('.');

    return Version(
      major: int.parse(_versionNumbers[0]),
      minor: int.parse(_versionNumbers[1]),
      patch: int.parse(_versionNumbers[2].split('-').first),
      releaseType: getReleaseType(_versionNumbers[2].split('-')[1]),
    );
  }

  /// Will validate the string to make sure it's a valid version. If it is, then
  /// it means you can request to parse [Version.fromString].
  static bool isValidVersion(String version) {
    List<String> _versionNumbers = version.split('.');

    if (!version.contains('-')) {
      return false;
    }

    if (_versionNumbers.length != 3) {
      return false;
    }

    for (String number in _versionNumbers) {
      if (number.contains('-')) {
        List<String> _numbers = number.split('-');

        if (_numbers.length != 2) {
          return false;
        }

        if (int.tryParse(_numbers[0]) == null) {
          return false;
        }

        switch (_numbers[1].toLowerCase()) {
          case 'alpha':
            break;
          case 'beta':
            break;
          case 'stable':
            break;
          default:
            return false;
        }

        continue;
      }

      if (int.tryParse(number) == null) {
        return false;
      }
    }

    return true;
  }

  static ReleaseType getReleaseType(String releaseType) {
    switch (releaseType.toLowerCase()) {
      case 'alpha':
        return ReleaseType.alpha;
      case 'beta':
        return ReleaseType.beta;
      case 'stable':
        return ReleaseType.stable;
      default:
        print(errorPen('Release type is not valid.'));
        exit(1);
    }
  }

  /// Converts the version to a string. This overrides the toString() method to
  /// make it properly formatted as a version string.
  @override
  String toString() {
    return '$major.$minor.$patch-${releaseType.name}';
  }

  /// Will return if the version provided is greater than the current version.
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

enum ReleaseType { alpha, beta, stable }
