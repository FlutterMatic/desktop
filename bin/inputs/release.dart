import 'dart:io';

import '../utils/app_data.dart';
import '../outputs/prints.dart';
import '../utils/enum.dart';

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
      throw Exception('Release must be either ALPHA | BETA | STABLE');
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
  String release = userReleaseInput('Type of the Application release ( ALPHA | BETA | STABLE ) : ');
  switch (release.toLowerCase()) {
    case 'alpha':
      appData.releaseType = ReleaseType.alpha;
      break;
    case 'beta':
      appData.releaseType = ReleaseType.beta;
      break;
    case 'stable':
      appData.releaseType = ReleaseType.stable;
      break;
    default:
      printErrorln('❌ Release type must be either ALPHA | BETA | STABLE');
      releaseCollection();
  }
  printInfoln('App release type is : ${appData.releaseType.toString().split('.')[1].toUpperCase()}');
}

void releaseFix(){
  
}