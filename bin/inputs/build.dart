import 'dart:io';

import '../utils/app_data.dart';
import '../outputs/prints.dart';

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
      throw Exception('Input must be either RELEASE | PROFILE | DEBUG');
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
  appData.buildMode = build.toUpperCase();
  printInfoln('App build type is : ${appData.buildMode}');
  if (appData.buildMode == 'DEBUG') {
    printWarningln('✖️ Looks like you choose it by mistake. Building app in debug mode is useless.');
    buildCollection();
  }
}
