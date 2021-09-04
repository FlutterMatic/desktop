import 'dart:io';
import '../utils/app_data.dart';
import '../outputs/prints.dart';

/// Function that returns a String value from the user input.
/// This function is used for Application Release management.
///
/// **EG:**
/// ```dart
/// String release = userReleaseInput('Enter the release type : ');
/// print('Release type is ${release.toUpperCase()}');
/// ```
///
/// **OUTPUT:**
///
/// ```txt
/// Enter the release type : alpha
/// Release type is ALPHA
/// ```
String userReleaseInput(String? question) {
  try {
    stdout.write(question);
    String _release = stdin.readLineSync()!.toUpperCase();
    if (_release is int || !<String>['alpha', 'beta', 'stable'].contains(_release.toLowerCase().trim())) {
      throw Exception('Release must be either alpha, beta, or stable');
    } else {
      return _release.trim();
    }
  } on FormatException catch (fe) {
    printErrorln('❌ Format Exception : ${fe.message}');
    print('Try again');
    return userReleaseInput(question);
  } catch (e) {
    printErrorln(e.toString());
    print('Try again');
    return userReleaseInput(question);
  }
}

void releaseCollection() {
  String release = userReleaseInput('Type of the Application release (alpha, beta, or stable) : ');
  appData.releaseType = release.toUpperCase();
  printInfoln('App release type is : ${appData.releaseType}');
}
