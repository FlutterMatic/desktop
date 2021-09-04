import 'dart:io';

import '../utils/app_data.dart';
import '../outputs/prints.dart';
import '../utils/enum.dart';

/// Function that returns a String value from the user input.
/// This function is used for Application Build management.
///
/// **EG:**
/// ```dart
/// String build = userBuildInput('Enter the flutter build type : ');
/// print('Build type is ${build.toUpperCase()}');
/// ```
///
/// **OUTPUT:**
///
/// ```txt
/// Enter the flutter build type : profile
/// Build type is PROFILE
/// ```
String userBuildInput(String? question) {
  try {
    stdout.write(question);
    String? _build = stdin.readLineSync()!;
    if (_build is int || !<String>['release', 'profile', 'debug'].contains(_build.toLowerCase().trim())) {
      throw Exception('❌ Input must be either RELEASE | PROFILE | DEBUG');
    }
    return _build.trim();
  } on FormatException catch (fe) {
    printErrorln('❌ Format Exception : ${fe.message}');
    print('Try again');
    return userBuildInput(question);
  } catch (e) {
    printErrorln(e.toString());
    print('Try again');
    return userBuildInput(question);
  }
}

void buildCollection() {
  String build = userBuildInput('Type of the flutter build ( RELEASE | PROFILE | DEBUG ) : ');
  switch (build.toLowerCase()) {
    case 'release':
      appData.buildMode = BuildType.release;
      break;
    case 'profile':
      appData.buildMode = BuildType.profile;
      break;
    case 'debug':
      appData.buildMode = BuildType.debug;
      break;
    default:
      printErrorln('❌ Invalid build type');
      print('Try again');
      buildCollection();
  }
  printInfoln('App build type is : ${appData.buildMode.toString().split('.')[1].toUpperCase()}');
  if (appData.buildMode == BuildType.debug) {
    printWarningln('✖️ Looks like you choose it by mistake. Building app in debug mode is useless here.');
    buildCollection();
  }
  // if (appData.buildMode == 'RELEASE') {
  // TODO: Add release build and write the code here.
  // }
}
