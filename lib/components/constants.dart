import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:manager/components/widgets/ui/activity_tile.dart';
import 'package:process_run/shell_run.dart';
import 'dart:async';
import 'dart:io';

const String _iconName = 'IconsFont';
final HttpClient httpClient = HttpClient();
StreamSubscription<ConnectivityResult>? subscription;
List<ProcessResult>? path;

// API data
String? flutterBaseUrl =
        'https://storage.googleapis.com/flutter_infra_release/releases',
    flutterHASH,
    flutterChannelHASH,
    flutterAPIChannel,
    flutterAPIVersion;

//Installed
bool flutterInstalled = false;
bool javaInstalled = false;
bool gitInstalled = false;
bool vscInstalled = false;
bool studioInstalled = false;
bool emulatorInstalled = false;
bool xCodeInstalled = false;
bool connection = true;

//Versions
String? flutterVersion,
    flutterChannel,
    vscodeVersion,
    xcodeVersion,
    androidSVersion,
    javaVersion,
    gitVersion;

// Platforms
bool win32 = false;
bool darwin = false;
bool linux = false;

//Utils
bool channelIsUpdating = false;
String desktopVersion = '1.0.0';
String? projDir,
    studioPath,
    gitPath,
    javaPath,
    vscPath,
    flutterPath,
    emulatorPath,
    defaultEditor;

//Lists
/// List of Background activities.
List<BgActivityTile> bgActivities = <BgActivityTile>[];

/// List of Projects.
List<String> projs = <String>[];

/// List of Projects modified dates.
List<String> projsModDate = <String>[];

//Assets
// const String flutterIcons = 'assets/icons/flutter_icons';
const String iconsPath = 'assets/icons';
const String ideIcons = 'assets/ides';

class Scripts {
  // Scripts to append path to user env
  static const String win32PathAdder = 'assets/scripts/path/win32.vbs';
  static const String darwinPathAdder = 'assets/scripts/path/darwin.sh';
  static const String linuxPathAdder = 'assets/scripts/path/linux.sh';
}

class Assets {
  //Status Icons
  static const String done = '$iconsPath/done.svg';
  static const String warning = '$iconsPath/warning.svg';
  static const String error = '$iconsPath/error.svg';

  //Ides Icons
  static const String androidStudio = '$ideIcons/android_studio.svg';
  static const String emulator = '$ideIcons/emulator.svg';
  static const String vscode = '$ideIcons/vscode.svg';
  static const String xcode = '$ideIcons/xcode.svg';
}

class Iconsdata {
  static const IconData browser = IconData(0xebb7, fontFamily: _iconName);
  static const IconData download = IconData(0xea96, fontFamily: _iconName);
  static const IconData channel = IconData(0xeb9d, fontFamily: _iconName);
  static const IconData rocket = IconData(0xec45, fontFamily: _iconName);
  static const IconData examples = IconData(0xeb39, fontFamily: _iconName);
  static const IconData changeChannel = IconData(0xebc7, fontFamily: _iconName);
  static const IconData github = IconData(0xec1c, fontFamily: _iconName);
  static const IconData twitter = IconData(0xec27, fontFamily: _iconName);
  static const IconData info = IconData(0xeac5, fontFamily: _iconName);
  static const IconData docs = IconData(0xeb67, fontFamily: _iconName);
  static const IconData dartpad = IconData(0xeb0f, fontFamily: _iconName);
  static const IconData sun = IconData(0xeb30, fontFamily: _iconName);
  static const IconData terminal = IconData(0xebef, fontFamily: _iconName);
  static const IconData moon = IconData(0xece7, fontFamily: _iconName);
  static const IconData chart = IconData(0xea59, fontFamily: _iconName);
  static const IconData folder = IconData(0xeaad, fontFamily: _iconName);
  static const IconData search = IconData(0xeb1c, fontFamily: _iconName);
  static const IconData delete = IconData(0xeb41, fontFamily: _iconName);
  static const IconData gitIssue = IconData(0xea05, fontFamily: _iconName);
  static const IconData gitPR = IconData(0xeab6, fontFamily: _iconName);
}

const Color kRedColor = Color(0xffDE4629);
const Color kYellowColor = Color(0xffFFBA00);
const Color kGreenColor = Color(0xff379C81);
const Color kGreyColor = Color(0xffF1F1F1);
const Color kLightGreyColor = Color(0xffE5E5E5);
const Color kDarkColor = Color(0xFF373E47);

// API Links
class APILinks {
  static const String flutterAPIBaseURL =
      'https://storage.googleapis.com/flutter_infra_release/releases';
  static final Uri win32ReleaseEndpoint =
      Uri.parse('$flutterAPIBaseURL/releases_windows.json');
  static final Uri macReleaseEndpoint =
      Uri.parse('$flutterAPIBaseURL/releases_macos.json');
  static final Uri linuxReleaseEndpoint =
      Uri.parse('$flutterAPIBaseURL/releases_linux.json');
}

// GitHub Services
class GitHubServices {
  static const String _githubBaseUrl =
      'https://github.com/FlutterMatic/FlutterMatic-desktop';
  static final Uri gitAPIUri = Uri.parse(
      'https://api.github.com/repos/git-for-windows/git/releases/latest');
  static const String gitBaseURI =
      'https://github.com/git-for-windows/git/releases/download/';
  static const String issueUrl = '$_githubBaseUrl/issues';
  static const String pr = '$_githubBaseUrl/pulls';
  static const String repUrl = _githubBaseUrl;
}

// Shell object
Shell shell = Shell(
  verbose: false,
  commandVerbose: false,
  commentVerbose: false,
  runInShell: true,
);

class ProgressEvent {
  final int contentLength;
  final int downloadedLength;

  const ProgressEvent(this.contentLength, this.downloadedLength);
}
