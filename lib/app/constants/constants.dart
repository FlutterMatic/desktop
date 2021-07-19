import 'package:manager/core/libraries/models.dart';
import 'package:process_run/shell.dart';

/// Shell object.
Shell shell = Shell(
  verbose: false,
  commandVerbose: false,
  commentVerbose: false,
  runInShell: true,
);

/// Fluttermatic API data object.
FluttermaticAPI? apiData;

/// Flutter-SDK API data object.
FlutterSDK? sdkData;

/// class with any other script files.
class Scripts {
  /// Windiows Scripts to append path to user env.
  static const String win32PathAdder = 'assets/scripts/win32.vbs';

  /// OSx Scripts to append path to user env.
  static const String darwinPathAdder = 'assets/scripts/darwin.sh';

  /// Linux Scripts to append path to user env.
  static const String linuxPathAdder = 'assets/scripts/linux.sh';
}

/// Application path in Root(C:\\ in win32) directory.
String applicationPath = 'C:\\fluttermatic\\flutter\\bin\\';
