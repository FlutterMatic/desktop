import 'package:flutter/material.dart';

bool flutterInstalled = false;
bool javaInstalled = false;
bool vscInstalled = false;
bool vscInsidersInstalled = false;
bool studioInstalled = false;
bool xCodeInstalled = false;

String? flutterVersion, flutterChannel, codeVersion, javaVersion;

//Assets
const String flutterIcons = 'assets/icons/flutter_icons';
const String statusIcons = 'assets/icons/status_icons';
const String footerIcons = 'assets/icons/footer_icons';

//Animations
const String lottie = 'assets/lottie';

class LottieAssets {
  static const String folder = '$lottie/folder.json';
  static const String searching = '$lottie/searching.json';
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

  //Footer Icons
  static const String gitHub = '$footerIcons/github.svg';
  static const String twitter = '$footerIcons/twitter.svg';
  static const String docs = '$footerIcons/docs.svg';
  static const String dartPad = '$footerIcons/dartpad.svg';
}

class PageRoutes {
  static const String routeSplash = '/';
  static const String routeInstallScreen = '/installScreen';
  static const String routeState = '/statesCheck';
  static const String routeHome = '/home';
}

const String _iconName = 'IconsFont';

class Iconsdata {
  static const IconData settings = IconData(0xeb20, fontFamily: _iconName);
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
}

const Color kRedColor = Color(0xffDE4629);
const Color kYellowColor = Color(0xffFFBA00);
const Color kGreenColor = Color(0xff379C81);
const Color kGreyColor = Color(0xffF1F1F1);
const Color kLightGreyColor = Color(0xffE5E5E5);
const Color kDarkColor = Color(0xff2F2F2F);
