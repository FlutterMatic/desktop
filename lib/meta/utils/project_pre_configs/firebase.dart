// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/core/notifiers/models/payloads/actions/flutter.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/project_pre_configs/response.dart';

class FirebasePreConfig {
  /// Will add all the necessary firebase services to the app for Android.
  /// Provide the project path and the Firebase Google Services JSON parsed
  /// as [Map<String, dynamic>]
  static Future<PreConfigResponse> addAndroid({
    required String projectPath,
    required Map<String, dynamic> googleServicesJSON,
    required NewFlutterProjectInfo project,
  }) async {
    try {
      projectPath = '$projectPath\\${project.projectName}';
      String orgName = googleServicesJSON['client'][0]['client_info']
          ['android_client_info']['package_name'];

      if (orgName != project.orgName || orgName.split('.').length != 3) {
        PreConfigResponse(
            success: false,
            error:
                'Firebase Android org name does not match the project org name. They have to match. Please upload a new google-services.json file that matches the org name.');
      }

      // Will add the google-services.json to the android/app folder
      await File.fromUri(
              Uri.file('$projectPath\\android\\app\\google-services.json'))
          .writeAsString(jsonEncode(googleServicesJSON));

      // Will add the google-services plugin to the android/build.gradle file
      // Example:
      //   ...
      //   dependencies {
      //   // ... adds the following line:
      //   classpath 'com.google.gms:google-services:4.3.10'  // Google Services plugin
      // }
      //   ...
      List<String> buildGradle =
          await File.fromUri(Uri.file('$projectPath\\android\\build.gradle'))
              .readAsLines();

      List<String> newBuildGradle = <String>[];

      for (int i = 0; i < buildGradle.length; i++) {
        newBuildGradle.add(buildGradle[i]);

        if (buildGradle[i].trim().startsWith('dependencies {')) {
          newBuildGradle.add(
              '${' ' * 8}classpath \'com.google.gms:google-services:4.3.10\'  // Google Services plugin');
        }
      }

      // Will now write the new build.gradle file (project-level)
      await File.fromUri(Uri.file('$projectPath\\android\\build.gradle'))
          .writeAsString(newBuildGradle.join('\n'));

      // Will now add to the build.gradle file (module-level) the following
      // plugin:
      // apply plugin: 'com.google.gms.google-services'  // Google Services plugin
      List<String> moduleBuildGradle = await File.fromUri(
              Uri.file('$projectPath\\android\\app\\build.gradle'))
          .readAsLines();

      List<String> newModuleBuildGradle = <String>[];

      bool addedPlugin = false;

      for (int i = 0; i < moduleBuildGradle.length; i++) {
        newModuleBuildGradle.add(moduleBuildGradle[i]);

        if (moduleBuildGradle[i].startsWith('apply plugin:') && !addedPlugin) {
          newModuleBuildGradle.add(
              'apply plugin: \'com.google.gms.google-services\'  // Google Services plugin');
          addedPlugin = true;
        }
      }

      // Will now write the new build.gradle file (module-level)
      await File.fromUri(Uri.file('$projectPath\\android\\app\\build.gradle'))
          .writeAsString(newModuleBuildGradle.join('\n'));

      try {
        // Will now add packages to the pubspec.yaml file for the app to work
        // with Firebase.
        await shell.cd(projectPath).run('flutter pub add firebase_core');
      } catch (_) {} // Will ignore if the pub add fails.

      return PreConfigResponse(success: true, error: null);
    } catch (e, s) {
      await logger.file(
          LogTypeTag.error, 'Failed to add Android Firebase pre config.',
          error: e, stackTrace: s);

      return PreConfigResponse(
          success: false, error: 'Failed to add Android Firebase pre config.');
    }
  }

  /// Will add all the necessary firebase services to the app for iOS.
  /// Provide the project path and the Firebase Google Services PLIST parsed
  /// as [List<String>]
  static Future<PreConfigResponse> addIOS({
    required String projectPath,
    required List<String> googleServicesPlist,
    required NewFlutterProjectInfo project,
  }) async {
    try {
      projectPath = '$projectPath\\${project.projectName}';
      String? orgName;

      for (int i = 0; i < googleServicesPlist.length; i++) {
        if (googleServicesPlist[i].trim() == '<key>BUNDLE_ID</key>') {
          orgName = googleServicesPlist[i + 1]
              .split('<string>')[1]
              .split('</string>')
              .first;
          break;
        }
      }

      if (orgName != project.orgName || orgName?.split('.').length != 3) {
        PreConfigResponse(
            success: false,
            error:
                'Firebase iOS org name does not match the project org name. They have to match. Please upload a new google-services.plist file that matches the org name.');
      }

      // Will add the google-services.plist to the ios/Runner folder
      await File.fromUri(
              Uri.file('$projectPath\\ios\\Runner\\google-services.plist'))
          .writeAsString(googleServicesPlist.join('\n'));

      try {
        // Will now add packages to the pubspec.yaml file for the app to work
        // with Firebase.
        await shell.cd(projectPath).run('flutter pub add firebase_core');
      } catch (_) {} // Will ignore if the pub add fails.

      return PreConfigResponse(success: true, error: null);
    } catch (e, s) {
      await logger.file(
          LogTypeTag.error, 'Failed to add iOS Firebase pre config.',
          error: e, stackTrace: s);

      return PreConfigResponse(
          success: false, error: 'Failed to add iOS Firebase pre config.');
    }
  }

  /// Will add all the necessary firebase services to the app for Web.
  /// Provide the project path and the Firebase Config as [List<String>].
  static Future<PreConfigResponse> addWeb({
    required String projectPath,
    required List<String> firebaseConfig,
    required NewFlutterProjectInfo project,
  }) async {
    try {
      projectPath = '$projectPath\\${project.projectName}';
      String scriptUrl =
          'https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js';
      // Example of firebaseConfig:
      // // Import the functions you need from the SDKs you need
      // import { initializeApp } from "firebase/app";
      // import { getAnalytics } from "firebase/analytics";

      // // Your web app's Firebase configuration
      // const firebaseConfig = {
      //   apiKey: "[...]",
      //   authDomain: "[...].firebaseapp.com",
      //   projectId: "[...]",
      //   storageBucket: "[...].appspot.com",
      //   messagingSenderId: "[...]",
      //   appId: "1:[...]:web:[...]",
      //   measurementId: "G-[...]"
      // };

      // // Initialize Firebase
      // const app = initializeApp(firebaseConfig);
      // const analytics = getAnalytics(app);

      // Will get the web/index.html file and add the following to it:

      // ```dart
      // <script src="${_scriptUrl}"></script>
      //
      // <script>
      // // Your web app's Firebase configuration
      // const firebaseConfig = {
      //   apiKey: "[...]",
      //   authDomain: "[...].firebaseapp.com",
      //   projectId: "[...]",
      //   storageBucket: "[...].appspot.com",
      //   messagingSenderId: "[...]",
      //   appId: "1:[...]:web:[...]",
      //   measurementId: "G-[...]"
      // };
      //
      // // Initialize Firebase
      // firebase.initializeApp(firebaseConfig);
      // </script>
      // ```

      // Read the web/index.html file
      List<String> webIndex =
          await File.fromUri(Uri.file('$projectPath\\web\\index.html'))
              .readAsLines();

      int lastScriptTagIndex =
          webIndex.lastIndexWhere((String s) => s.trim() == '</script>');

      List<String> newWebIndex = <String>[];

      for (int i = 0; i < webIndex.length; i++) {
        if (i == lastScriptTagIndex + 1) {
          newWebIndex.add('');
          newWebIndex.add(
              '<!-- The Firebase services that is used in this web app -->');
          newWebIndex.add('<script src="$scriptUrl"></script>');
          newWebIndex.add('');
          newWebIndex.add('<!-- Firebase web app configuration -->');
          newWebIndex.add('<script>');

          List<String> requiredKeys = <String>[
            'apiKey',
            'authDomain',
            'projectId',
            'storageBucket',
            'messagingSenderId',
            'appId',
            'measurementId'
          ];

          List<String> configParams = <String>[];

          for (int j = 0; j < requiredKeys.length; j++) {
            for (int k = 0; k < firebaseConfig.length; k++) {
              if (firebaseConfig[k].trim().startsWith(requiredKeys[j])) {
                configParams.add(
                    '${requiredKeys[j]}: ${firebaseConfig[k].split(':').sublist(1).join(':')}');
                break;
              }
            }
          }

          newWebIndex.add('var firebaseConfig = {');
          newWebIndex.add(configParams.join('\n'));
          newWebIndex.add('};');
          newWebIndex.add('// Initialize Firebase');
          newWebIndex.add('firebase.initializeApp(firebaseConfig);');
          newWebIndex.add('</script>\n');
        } else {
          newWebIndex.add(webIndex[i]);
        }
      }

      // Will now add the firebase config to the web/index.html file
      await File.fromUri(Uri.file('$projectPath\\web\\index.html'))
          .writeAsString(newWebIndex.join('\n'));

      try {
        // Will now add packages to the pubspec.yaml file for the app to work
        // with Firebase.
        await shell.cd(projectPath).run('flutter pub add firebase_core');
      } catch (_) {} // Will ignore if the pub add fails.

      return PreConfigResponse(success: true, error: null);
    } catch (e, s) {
      await logger.file(
          LogTypeTag.error, 'Failed to add Web Firebase pre config.',
          error: e, stackTrace: s);

      return PreConfigResponse(
          success: false, error: 'Failed to add Web Firebase pre config.');
    }
  }
}
