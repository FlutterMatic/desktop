import 'package:flutter/material.dart';
import 'package:flutter_installer/components/widgets/activity_button.dart';
import 'package:flutter_installer/models/flutter_api.dart';

const String _iconName = 'IconsFont';

// API data
String? baseUrl = 'https://storage.googleapis.com/flutter_infra/releases',
    flutterHASH,
    flutterChannelHASH,
    flutterAPIChannel,
    flutterAPIVersion;

//Installed
bool flutterInstalled = false;
bool javaInstalled = false;
bool vscInstalled = false;
bool vscInsidersInstalled = false;
bool studioInstalled = false;
bool emulatorInstalled = false;
bool xCodeInstalled = false;

// Flutter release data
FlutterReleases? flutterReleases;

//Versions
String? flutterVersion,
    flutterChannel,
    vscodeVersion,
    xcodeVersion,
    androidSVersion,
    javaVersion;

// Platforms
bool win32 = false;
bool mac = false;
bool linux = false;

//Utils
bool channelIsUpdating = false;
String desktopVersion = '1.0.0';
String? projDir, studioPath, javaPath, vscPath, flutterPath, emulatorPath, defaultEditor;

//Lists
/// List of Background activities.
List<BgActivityButton> bgActivities = [];

/// List of Projects.
List<String> projs = [];

/// List of Projects modified dates.
List<String> projsModDate = [];

//Assets
const String flutterIcons = 'assets/icons/flutter_icons';
const String statusIcons = 'assets/icons/status_icons';
const String ideIcons = 'assets/ides';

//Animations
const String lottie = 'assets/lottie';

class LottieAssets {
  static const String folder = '$lottie/folder.json';
  static const String searching = '$lottie/searching.json';
}

class Scripts {
  // Scripts to append path to user env
  static const String win32PathAdder = 'assets/scripts/path/win32.bat';
  static const String macosPathAdder = 'assets/scripts/path/macos.sh';
  static const String linuxPathAdder = 'assets/scripts/path/linux.sh';
}

class Assets {
  //Futter Icons
  static const String development = '$flutterIcons/icon_development.svg';
  static const String performance = '$flutterIcons/icon_performance.svg';
  static const String ui = '$flutterIcons/icon_ui.svg';
  static const String flutterIcon = 'assets/icons/flutter_icon.png';

  //Status Icons
  static const String done = '$statusIcons/done.svg';
  static const String warning = '$statusIcons/warning.svg';
  static const String error = '$statusIcons/error.svg';

  //Ides Icons
  static const String androidStudio = '$ideIcons/android_studio.svg';
  static const String emulator = '$ideIcons/emulator.svg';
  static const String vscode = '$ideIcons/vscode.svg';
  static const String xcode = '$ideIcons/xcode.svg';
}

class PageRoutes {
  static const String routeSplash = '/';
  static const String routeInstallScreen = '/installScreen';
  static const String routeState = '/statesCheck';
  static const String routeHome = '/home';
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
  static const IconData moon = IconData(0xece7, fontFamily: _iconName);
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
const Color kDarkColor = Color(0xff2F2F2F);

// API Links
class APILinks {
  static const String flutterAPIBaseURL =
      'https://storage.googleapis.com/flutter_infra/releases';
  static Uri win32RelaseEndpoint =
      Uri.parse('$flutterAPIBaseURL/releases_windows.json');
  static Uri macRelaseEndpoint =
      Uri.parse('$flutterAPIBaseURL/releases_macos.json');
  static Uri linuxRelaseEndpoint =
      Uri.parse('$flutterAPIBaseURL/releases_linux.json');
}
