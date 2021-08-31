import 'dart:io';
import 'package:pub_semver/pub_semver.dart';
import '../utils/app_data.dart';
import '../outputs/prints.dart';

/// Funtion that returns an integer from the user input.
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
      if (0 < value && value > 10) {
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

void versionCollection() {
  int major = userVersionInput('Enter the major number in version (*.*.*) : ');
  int minor = userVersionInput('Enter the major number in version ($major.*.*) : ');
  int patch = userVersionInput('Enter the major number in version ($major.$minor.*) : ');
  if (major + minor + patch == 0) {
    printErrorln(Exception('❌ Version cannot be $major.$minor.$patch').toString());
    versionCollection();
  } else {
    appData.version = Version(major, minor, patch);
    printInfoln('Version of the app is : ${appData.version}');
  }
}
