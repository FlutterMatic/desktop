import 'package:fluttermatic/app/enum.dart';

class WorkflowActionScripts {
  /// Analyze the project code and returns a none zero exit code if there are
  /// any warnings or errors, depending on the [severity] specified in the
  /// analysis_options.yaml file.
  static List<String> analyzeDartProject(bool isFlutter) {
    return <String>[
      if (isFlutter) 'flutter analyze',
      if (!isFlutter) 'dart analyze',
    ];
  }

  /// Run the unit tests, widget tests, or integration tests for Flutter, and
  /// executes all the tests provided for a Dart project.
  static List<String> runProjectTests(bool isFlutter) {
    return <String>[
      if (isFlutter) 'flutter test',
      if (!isFlutter) 'dart test',
    ];
  }

  /// Build the code for a Flutter web project. This will run pub get beforehand
  /// in case and then build the project with the provided web renderer and
  /// provided release mode.
  static List<String> buildProjectForWeb(
      {required PlatformBuildModes mode, required WebRenderers renderer}) {
    return <String>[
      'flutter pub get',
      'flutter build web --${mode.name} --web-renderer ${renderer.name}',
    ];
  }

  /// Build the code for an iOS project. This will run pub get beforehand in
  /// case and then build the project with the provided release mode.
  static List<String> buildProjectForIos(PlatformBuildModes mode) {
    return <String>[
      'flutter pub get',
      'flutter build ios --${mode.name}',
    ];
  }

  /// Build the code for an Android project. This will run pub get beforehand
  /// in case and then build the project with the provided release mode.
  static List<String> buildProjectForAndroid({
    required PlatformBuildModes mode,
    required AndroidBuildType type,
  }) {
    return <String>[
      'flutter pub get',
      if (type == AndroidBuildType.appBundle)
        'flutter build appbundle --${mode.name}',
      if (type == AndroidBuildType.apk) 'flutter build apk --${mode.name}',
    ];
  }

  /// Build the code for a Windows project. This will run pub get beforehand in
  /// case and then build the project with the provided release mode.
  static List<String> buildProjectForWindows(PlatformBuildModes mode) {
    return <String>[
      'flutter pub get',
      'flutter build windows --${mode.name}',
    ];
  }

  /// Build the code for a macOS project. This will run pub get beforehand in
  /// case and then build the project with the provided release mode.
  static List<String> buildProjectForMacos(PlatformBuildModes mode) {
    return <String>[
      'flutter pub get',
      'flutter build macos --${mode.name}',
    ];
  }

  /// Build the code for a Linux project. This will run pub get beforehand in
  /// case and then build the project with the provided release mode.
  static List<String> buildProjectForLinux(PlatformBuildModes mode) {
    return <String>[
      'flutter pub get',
      'flutter build linux --${mode.name}',
    ];
  }
}
