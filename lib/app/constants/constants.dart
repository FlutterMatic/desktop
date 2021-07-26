import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:bitsdojo_window_platform_interface/window.dart';
import 'package:manager/core/libraries/models.dart';
import 'package:process_run/shell.dart';

/// Shell object.
Shell shell = Shell(
  verbose: false,
  commandVerbose: false,
  commentVerbose: false,
  runInShell: true,
);

/// VSCode Git API data object.
VSCodeAPI? vscodeApi;

/// Fluttermatic API data object.
FluttermaticAPI? apiData;

/// Flutter-SDK API data object.
FlutterSDK? sdkData;

/// Tag name for vscode
String? tag_name;

/// SHA for vscode
String? sha;

/// OS
String? platform;

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

/// Report issue url
String reportIssueUrl =
    'https://github.com/FlutterMatic/FlutterMatic-desktop/issues/new';

DesktopWindow startup = appWindow;

DesktopWindow mainWin = appWindow;
