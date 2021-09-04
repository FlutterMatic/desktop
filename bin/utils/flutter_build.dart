import 'package:process_run/shell.dart';

import '../outputs/prints.dart';
import 'app_data.dart';
import 'enum.dart';
import 'spinner.dart';

class FlutterMaticBuild {
  /// Builds the app and returns the build directory
  /// Takes an argument [platform] to build for.
  static Future<void> build(String? platform) async {
    /// Shell object.
    Shell shell = Shell(
      commandVerbose: false,
      commentVerbose: false,
      runInShell: true,
      verbose: false,
    );

    /// List of arguments to be passed to the build command.
    List<String> args = <String>['build'];

    /// If platform is not null, add it to the arguments.
    if (appData.platform != null) args.add(appData.platform!.toLowerCase());

    /// If build mode is not null, add it to the arguments.
    if (appData.buildMode != null) args.add('--${appData.buildMode!.toString().split('.')[1]}');

    /// If release mode is not null, add `--dart-define` to the arguments.
    /// And also add `release-type` key and it's value to the arguments.
    if (appData.releaseType != null) {
      args.add('--dart-define');
      args.add('release-type=${appData.releaseType.toString().split('.')[1]}');
    }

    /// If version is not null, add `--dart-define` to the arguments.
    /// And also add `current-version` key and it's value to the arguments.
    if (appData.version != null) {
      args.add('--dart-define');
      args.add('current-version=${appData.version}');
    }

    /// Run the build command.
    await shell.run('flutter ${args.join(' ')}');
  }

  /// Builds the MSXI file. All parameters are pre defined.
  static Future<void> buildMSIX() async {
    if (appData.buildMode == BuildType.release) {
      /// Shell object.
      Shell shell = Shell(
        commandVerbose: false,
        commentVerbose: false,
        runInShell: true,
        verbose: false,
      );
      List<String> args = <String>['pub', 'run', 'msix:create', 'CN=FLUTTERMATIC,', 'O=Fluttermatic'];
      await shell.run('flutter ${args.join(' ')}');
    }
    if (appData.buildMode == BuildType.debug || appData.buildMode == BuildType.profile) {
      stopSpinner();
      printError('Debug and Profile modes are not supported for MSIX');
    }
  }
}
