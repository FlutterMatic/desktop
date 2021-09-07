import 'dart:io';
import 'package:pub_semver/pub_semver.dart';
import '../utils/app_data.dart';
import '../outputs/prints.dart';

/// Function that returns an integer from the user input.
/// This function is used for version management.
///
/// **EG:**
/// ```dart
/// int number = userVersionInput('Enter an integer : ');
/// print('Number : $number');
/// ```
///
/// **OUTPUT:**
///
/// ```txt
/// Enter an integer : 1
/// Number : 1
/// ```
int userVersionInput(String? question) {
  try {
    stdout.write(question);
    String? input = stdin.readLineSync();
    if (input != null && input.isNotEmpty) {
      int value = int.parse(input);
      if (0 <= value && value > 10) {
        throw const FormatException('The value must be between 0 and 9.');
      }
      return value;
    } else {
      throw Exception('❌ Input cannot be null');
    }
  } on FormatException catch (fe) {
    printError('❌ Format Exception : ${fe.message}');
    println('Try again');
    return userVersionInput(question);
  } catch (e) {
    printErrorln(e.toString());
    println('Try again');
    return userVersionInput(question);
  }
}

Future<void> versionCollection() async {
  int major = userVersionInput('Enter the major number in version (*.*.*) : ');
  int minor = userVersionInput('Enter the major number in version ($major.*.*) : ');
  int patch = userVersionInput('Enter the major number in version ($major.$minor.*) : ');
  if (major + minor + patch == 0) {
    printErrorln(Exception('❌ Version cannot be $major.$minor.$patch').toString());
    await versionCollection();
  } else {
    appData.version = Version(major, minor, patch);
    if (appData.version!.compareTo(await checkPubspecVersion()) < 0) {
      printWarning('🧡 Version is not up to date');
      printWarning('🧡 Current version : ${appData.version}');
      printWarning('🧡 Update the version in pubspec.yaml');
      exit(1);
    } else if (appData.version!.compareTo(await checkPubspecVersion()) > 0) {
      printSuccess('💚 Version is valid.');
      return;
    }
  }
}

Future<Version> checkPubspecVersion() async {
  String? pubVersion;
  int? pubMajor;
  int? pubMinor;
  int? pubPatch;
  try {
    String? pubspecContent = await File('./pubspec.yaml').readAsString();
    for (String ver in pubspecContent.split('\n')) {
      if (ver.startsWith('version: ') == true) {
        pubVersion = ver.split(': ')[1].trim();
      }
    }
    if (pubVersion != null) {
      pubMajor = int.parse(pubVersion.split('.')[0].trim());
      pubMinor = int.parse(pubVersion.split('.')[1].trim());
      pubPatch = int.parse(pubVersion.split('.')[2].trim());
    }
    return Version(pubMajor!, pubMinor!, pubPatch!);
  } catch (e) {
    printErrorln(e.toString());
    return Version(0, 0, 0);
  }
}
