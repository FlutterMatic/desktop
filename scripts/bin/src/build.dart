// Dart imports:
import 'dart:io';

// Project imports:
import '../script.dart';
import '../utils.dart';
import 'build_utils/build.dart';
import 'build_utils/move_build.dart';
import 'change_pubspec_version.dart';
import 'confirm_changelog.dart';
import 'update_launch_json.dart';
import 'version.dart';

Future<void> buildAppWithMode(BuildMode mode) async {
  // Asks for the new version we are building for.
  print('\n📝  What version are we building for and its release?\n');

  String? _version = stdin.readLineSync();

  if (_version == null) {
    print(errorPen('Please provide a version number and release.'));
    exit(1);
  }

  // Makes sure that the version is valid.
  if (!Version.isValidVersion(_version)) {
    print(errorPen(
        'Version number is invalid. Make sure it\'s something like x.y.z-alpha'));
    exit(1);
  }

  // Makes sure that the changelog contains the information about this release.
  await confirmChangelogExists(Version.fromString(_version));

  // Updates the .vscode/launch.json file with the new version and release type.
  await updateLaunchJson(Version.fromString(_version));

  // Change the pubspec.yaml file to the new version.
  await changePubspecVersion(_version.trim());

  print(infoPen('Building... This might take a while.'));

  // Build the app in release mode.
  await buildWithMode(mode, Platform.operatingSystem);

  // Capitalize the first letter of the mode.
  String _mode =
      mode.name.substring(0, 1).toUpperCase() + mode.name.substring(1);

  String _out =
      '$fluttermaticDesktopPath\\build\\${Platform.operatingSystem}\\runner\\$_mode';

  // Now it should take the build and put it into the final_builds folder.
  await moveBuildOutput(
      _out, '$fluttermaticDesktopPath\\final_builds\\${mode.name}');
}
