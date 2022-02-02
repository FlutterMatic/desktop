// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/core/services/actions/flutter.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/bin/project_pre_configs/response.dart';

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
      projectPath = projectPath + '\\' + project.projectName;
      String _orgName = googleServicesJSON['client'][0]['client_info']
          ['android_client_info']['package_name'];

      if (_orgName != project.orgName || _orgName.split('.').length != 3) {
        PreConfigResponse(
            success: false,
            error:
                'Firebase Android org name does not match the project org name. They have to match. Please upload a new google-services.json file that matches the org name.');
      }

      // Will add the google-services.json to the android/app folder
      await File.fromUri(
              Uri.file(projectPath + '\\android\\app\\google-services.json'))
          .writeAsString(jsonEncode(googleServicesJSON));

      // Will add the google-services plugin to the android/build.gradle file
      // Example:
      //   ...
      //   dependencies {
      //   // ... adds the following line:
      //   classpath 'com.google.gms:google-services:4.3.10'  // Google Services plugin
      // }
      //   ...
      List<String> _buildGradle =
          await File.fromUri(Uri.file(projectPath + '\\android\\build.gradle'))
              .readAsLines();

      List<String> _newBuildGradle = <String>[];

      for (int i = 0; i < _buildGradle.length; i++) {
        _newBuildGradle.add(_buildGradle[i]);

        if (_buildGradle[i].trim().startsWith('dependencies {')) {
          _newBuildGradle.add((' ' * 8) +
              'classpath \'com.google.gms:google-services:4.3.10\'  // Google Services plugin');
        }
      }

      // Will now write the new build.gradle file (project-level)
      await File.fromUri(Uri.file(projectPath + '\\android\\build.gradle'))
          .writeAsString(_newBuildGradle.join('\n'));

      // Will now add to the build.gradle file (module-level) the following
      // plugin:
      // apply plugin: 'com.google.gms.google-services'  // Google Services plugin
      List<String> _moduleBuildGradle = await File.fromUri(
              Uri.file(projectPath + '\\android\\app\\build.gradle'))
          .readAsLines();

      List<String> _newModuleBuildGradle = <String>[];

      bool _addedPlugin = false;

      for (int i = 0; i < _moduleBuildGradle.length; i++) {
        _newModuleBuildGradle.add(_moduleBuildGradle[i]);

        if (_moduleBuildGradle[i].startsWith('apply plugin:') &&
            !_addedPlugin) {
          _newModuleBuildGradle.add(
              'apply plugin: \'com.google.gms.google-services\'  // Google Services plugin');
          _addedPlugin = true;
        }
      }

      // Will now write the new build.gradle file (module-level)
      await File.fromUri(Uri.file(projectPath + '\\android\\app\\build.gradle'))
          .writeAsString(_newModuleBuildGradle.join('\n'));

      try {
        // Will now add packages to the pubspec.yaml file for the app to work
        // with Firebase.
        await shell.cd(projectPath).run('flutter pub add firebase_core');
      } catch (_) {
        // Will ignore if the pub add fails.
      }

      return PreConfigResponse(success: true, error: null);
    } catch (_, s) {
      await logger.file(
          LogTypeTag.error, 'Failed to add Android Firebase pre config: $_',
          stackTraces: s);
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
      projectPath = projectPath + '\\' + project.projectName;
      String? _orgName;

      for (int i = 0; i < googleServicesPlist.length; i++) {
        if (googleServicesPlist[i].trim() == '<key>BUNDLE_ID</key>') {
          _orgName = googleServicesPlist[i + 1]
              .split('<string>')[1]
              .split('</string>')
              .first;
          break;
        }
      }

      if (_orgName != project.orgName || _orgName?.split('.').length != 3) {
        PreConfigResponse(
            success: false,
            error:
                'Firebase iOS org name does not match the project org name. They have to match. Please upload a new google-services.plist file that matches the org name.');
      }

      // Will add the google-services.plist to the ios/Runner folder
      await File.fromUri(
              Uri.file(projectPath + '\\ios\\Runner\\google-services.plist'))
          .writeAsString(googleServicesPlist.join('\n'));

      try {
        // Will now add packages to the pubspec.yaml file for the app to work
        // with Firebase.
        await shell.cd(projectPath).run('flutter pub add firebase_core');
      } catch (_) {
        // Will ignore if the pub add fails.
      }

      return PreConfigResponse(success: true, error: null);
    } catch (_, s) {
      await logger.file(
          LogTypeTag.error, 'Failed to add iOS Firebase pre config: $_',
          stackTraces: s);
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
      projectPath = projectPath + '\\' + project.projectName;
      String _scriptUrl =
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
      List<String> _webIndex =
          await File.fromUri(Uri.file(projectPath + '\\web\\index.html'))
              .readAsLines();

      int _lastScriptTagIndex =
          _webIndex.lastIndexWhere((String s) => s.trim() == '</script>');

      List<String> _newWebIndex = <String>[];

      for (int i = 0; i < _webIndex.length; i++) {
        if (i == _lastScriptTagIndex + 1) {
          _newWebIndex.add('');
          _newWebIndex.add(
              '<!-- The Firebase services that is used in this web app -->');
          _newWebIndex.add('<script src="$_scriptUrl"></script>');
          _newWebIndex.add('');
          _newWebIndex.add('<!-- Firebase web app configuration -->');
          _newWebIndex.add('<script>');

          List<String> _requiredKeys = <String>[
            'apiKey',
            'authDomain',
            'projectId',
            'storageBucket',
            'messagingSenderId',
            'appId',
            'measurementId'
          ];

          List<String> _configParams = <String>[];

          for (int j = 0; j < _requiredKeys.length; j++) {
            for (int k = 0; k < firebaseConfig.length; k++) {
              if (firebaseConfig[k].trim().startsWith(_requiredKeys[j])) {
                _configParams.add(_requiredKeys[j] +
                    ': ' +
                    firebaseConfig[k].split(':').sublist(1).join(':'));
                break;
              }
            }
          }

          _newWebIndex.add('var firebaseConfig = {');
          _newWebIndex.add(_configParams.join('\n'));
          _newWebIndex.add('};');
          _newWebIndex.add('// Initialize Firebase');
          _newWebIndex.add('firebase.initializeApp(firebaseConfig);');
          _newWebIndex.add('</script>\n');
        } else {
          _newWebIndex.add(_webIndex[i]);
        }
      }

      // Will now add the firebase config to the web/index.html file
      await File.fromUri(Uri.file(projectPath + '\\web\\index.html'))
          .writeAsString(_newWebIndex.join('\n'));

      try {
        // Will now add packages to the pubspec.yaml file for the app to work
        // with Firebase.
        await shell.cd(projectPath).run('flutter pub add firebase_core');
      } catch (_) {
        // Will ignore if the pub add fails.
      }

      return PreConfigResponse(success: true, error: null);
    } catch (_, s) {
      await logger.file(
          LogTypeTag.error, 'Failed to add Web Firebase pre config: $_',
          stackTraces: s);
      return PreConfigResponse(
          success: false, error: 'Failed to add Web Firebase pre config.');
    }
  }
}
