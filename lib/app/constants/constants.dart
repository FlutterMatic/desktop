import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:bitsdojo_window_platform_interface/window.dart';
import 'package:flutter/services.dart';
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
String? tagName;

/// SHA for vscode
String? sha;

/// OS
String? platform;

/// Application path in Root(C:\\ in win32) directory.
String applicationPath = 'C:\\fluttermatic\\flutter\\bin\\';

/// Report issue url
String reportIssueUrl =
    'https://github.com/FlutterMatic/FlutterMatic-desktop/issues/new';

DesktopWindow startup = appWindow;

DesktopWindow mainWin = appWindow;

/// Class for buttons
class ButtonTexts {
  static const String install = 'Install';
  static const String uninstall = 'Uninstall';
  static const String update = 'Update';
  static const String next = 'Next';
  static const String skip = 'Skip';
  static const String restart = 'Restart';
}

/// Class for assets
class Assets {
  static const String confetti = 'assets/images/icons/confetti.svg';
  static const String flutter = 'assets/images/logos/flutter.svg';
  static const String editor = 'assets/images/icons/editor.svg';
  static const String studio = 'assets/images/logos/android_studio.svg';
  static const String vscode = 'assets/images/logos/vs_code.svg';
  static const String git = 'assets/images/logos/git.svg';
  static const String java = 'assets/images/logos/java.svg';
}

/// Class for installed softwares
class Installed {
  static const String vscode = 'Visual Studio Code installed';
  static const String studio = 'Android Studio installed';
  static const String flutter = 'Flutter installed';
  static const String git = 'Git installed';
  static const String java = 'Java installed';
  static const String congos = 'Congrats';
}

/// Class for install softwares
class Install {
  static const String vscode = 'Install Visual Studio Code';
  static const String studio = 'Install Android Studio';
  static const String flutter = 'Install Flutter';
  static const String git = 'Install Git';
  static const String java = 'Install Java';
}

/// class for install softwares content
class InstallContent {
  static const String welcome = '''Welcome to the Flutter App Manager. 
      You will be guided through the steps necessary to 
      setup and install Flutter in your computer. 
      Please make sure of good internet connection.''';
  static const String git =
      'Flutter relies on Git to get and install dependencies and other tools.';
  static const String java =
      'Java is sometimes needed in Flutter development. However you can skip if you do not want to install Java.';
  static const String flutter =
      'Flutter relies on Flutter to build and run Flutter.';
  static const String docs =
      'Read the official Flutter documentation or check our documentation for how to use this app.';
}

/// Class for installed software content
class InstalledContent {
  static const String java =
      'You have successfully installed Java. Click next to wrap up.';
  static const String flutter =
      'You have successfully installed Flutter. Click next to wrap up.';
  static const String vscode =
      'You have successfully installed Visual Studio Code. Click next to wrap up.';
  static const String studio =
      'You have successfully installed Android Studio. Click next to wrap up.';
  static const String allDone =
      'All set! You will need to restart your computer to start using Flutter.';
}

class PlatformVersion {
  static const MethodChannel _channel = MethodChannel('duh');

  static Future<String?> get platformVersion async {
    String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
