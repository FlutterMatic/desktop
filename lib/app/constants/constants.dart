import 'package:flutter/material.dart';
import 'package:bitsdojo_window_platform_interface/window.dart';
import 'package:manager/core/libraries/widgets.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:manager/core/libraries/models.dart';
import 'package:process_run/shell.dart';

/// Shell global reference
Shell shell = Shell(
  commandVerbose: false,
  commentVerbose: false,
  runInShell: true,
  verbose: false,
);

bool? allChecked;

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
String? osName;
String? osVersion;
String? appVersion;
String? appBuild;

/// Application path in Root(C:\\ in win32) directory.
// String applicationPath = 'C:\\fluttermatic\\flutter\\bin\\';
String? appTemp;
String? appMainDir;

/// Report issue url
String reportIssueUrl = 'https://github.com/FlutterMatic/FlutterMatic-desktop/issues/new';

DesktopWindow startup = appWindow;

DesktopWindow mainWin = appWindow;

/// Class for buttons
class ButtonTexts {
  static const String uninstall = 'Uninstall';
  static const String install = 'Install';
  static const String restart = 'Restart';
  static const String cancel = 'Cancel';
  static const String update = 'Update';
  static const String skip = 'Skip';
  static const String next = 'Next';
}

const String _placeholderBase = 'assets/images/placeholders/';
const String _imagesIconsBase = 'assets/images/icons/';
const String _imagesLogosBase = 'assets/images/logos/';
const String _lottieBase = 'assets/lottie/';

/// Class for assets
class Assets {
  static const String studio = '${_imagesLogosBase}android_studio.svg';
  static const String settings = '${_imagesIconsBase}settings.svg';
  static const String extracting = '${_lottieBase}extraction.json';
  static const String ghosts = '${_lottieBase}ghosts.json';
  static const String packages = '${_lottieBase}packages.json';
  static const String confetti = '${_imagesIconsBase}confetti.svg';
  static const String flutter = '${_imagesLogosBase}flutter.svg';
  static const String logo = '${_imagesLogosBase}app_logo.svg';
  static const String twitter = '${_imagesLogosBase}twitter.svg';
  static const String vscode = '${_imagesLogosBase}vs_code.svg';
  static const String coding = '${_placeholderBase}coding.svg';
  static const String codingLottie = '${_lottieBase}coding.json';
  static const String editor = '${_imagesIconsBase}editor.svg';
  static const String github = '${_imagesLogosBase}github.svg';
  static const String xcode = '${_imagesLogosBase}xcode.png';
  static const String error = '${_imagesIconsBase}error.svg';
  static const String dart = '${_imagesLogosBase}dart.svg';
  static const String done = '${_imagesIconsBase}done.svg';
  static const String warn = '${_imagesIconsBase}warn.svg';
  static const String java = '${_imagesLogosBase}java.svg';
  static const String doc = '${_imagesIconsBase}doc.svg';
  static const String git = '${_imagesLogosBase}git.svg';
  static const String appLogo = 'assets/images/logo.png';
}

/// Class for installed softwares
class Installed {
  static const String vscode = 'Visual Studio Code installed';
  static const String studio = 'Android Studio installed';
  static const String flutter = 'Flutter installed';
  static const String java = 'Java installed';
  static const String git = 'Git installed';
  static const String congos = 'Congrats';
}

/// Class for install softwares
class Install {
  static const String vscode = 'Install Visual Studio Code';
  static const String studio = 'Install Android Studio';
  static const String flutter = 'Install Flutter';
  static const String java = 'Install Java';
  static const String git = 'Install Git';
}

/// class for install softwares content
class InstallContent {
  static const String welcome =
      'Welcome to the Flutter App Manager. You will be guided through the steps necessary to setup and install Flutter in your device.';
  static const String git = 'Flutter relies on Git to get and install dependencies and other tools.';
  static const String java =
      'Java is sometimes needed in Flutter development. However you can skip if you do not want to install Java.';
  static const String flutter = 'Flutter relies on Flutter to build and run Flutter.';
  static const String docs =
      'Read the official Flutter documentation or check our documentation for how to use this app.';
}

/// Class for installed software content
class InstalledContent {
  static const String java = 'You have successfully installed Java. Click next to wrap up.';
  static const String flutter = 'You have successfully installed Flutter. Click next to wrap up.';
  static const String vscode = 'You have successfully installed Visual Studio Code. Click next to wrap up.';
  static const String studio = 'You have successfully installed Android Studio. Click next to wrap up.';
  static const String allDone = 'All set! You will need to restart your device to start using Flutter.';
  static const String restart =
      'You will need to restart your device to fully complete this setup. Make sure to save all your work before restarting.';
}

//Lists
/// List of Background activities.
List<BgActivityTile> bgActivities = <BgActivityTile>[];

/// List of Projects.
List<String> projs = <String>[];

/// List of Projects modified dates.
List<String> projsModDate = <String>[];

const Color kRedColor = Color(0xffE44516);
const Color kYellowColor = Color(0xffF7C605);
const Color kGreenColor = Color(0xff07C2A3);

class ProgressEvent {
  final int contentLength;
  final int downloadedLength;

  const ProgressEvent(this.contentLength, this.downloadedLength);
}

/// ### SEPARATORS
/// The following are size boxes used across the app. Try to use these
/// as much as possible as it helps simplify the code and makes it easier
/// for changes in the future. If the size you are looking for doesn't
/// exist, try to use multiple separators that will result in the closest
/// result possible.

/// ### VSeparators
///
///  - xSmall = 5
///  - small = 10
///  - normal = 15
///  - large = 20
///  - xLarge = 30
class VSeparators {
  static SizedBox xSmall() => const SizedBox(height: 5);
  static SizedBox small() => const SizedBox(height: 10);
  static SizedBox normal() => const SizedBox(height: 15);
  static SizedBox large() => const SizedBox(height: 20);
  static SizedBox xLarge() => const SizedBox(height: 30);
}

/// ### HSeparators
///
///  - xSmall = 5
///  - small = 10
///  - normal = 15
///  - large = 20
///  - xLarge = 30

class HSeparators {
  static SizedBox xSmall() => const SizedBox(width: 5);
  static SizedBox small() => const SizedBox(width: 10);
  static SizedBox normal() => const SizedBox(width: 15);
  static SizedBox large() => const SizedBox(width: 20);
  static SizedBox xLarge() => const SizedBox(width: 30);
}

class SystemRequirementsContent {
  static const String winOS = 'Windows 7 SP1 or later (64-bit), x86-64 based';
  static const String macOS = 'macOS';
  static const String linuxOS = 'Linux (64 bit)';
  static const String winSpace = '1.7 GB (Only Flutter SDK)';
  static const String macSpace = '2.8 GB (Only Flutter SDK)';
  static const String linuxSpace = '600 MB (Only Flutter SDK)';
  static const String winTools = 'Git, PowerShell, Java (version: 1.8.***)';
  static const String macTools = 'Git, CocoaPods, Java (version: 1.8.***)';
  static const String linuxTools =
      'bash, curl, file, git 2.x, mkdir, rm, unzip, which, xz-utils, zip, Java (version: 1.8.***)';
}
