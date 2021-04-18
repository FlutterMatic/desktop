import 'package:flutter/material.dart';

bool flutterExist = false;
bool javaInstalled = false;
bool vscInstalled = false;
bool vscInsidersInstalled = false;
bool studioInstalled = false;
bool xCode = false;

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

class Iconsdata {
  static const IconData settings = IconData(0xeb20, fontFamily: 'IconsFont');
  static const IconData download = IconData(0xea96, fontFamily: 'IconsFont');
  static const IconData channel = IconData(0xeb9d, fontFamily: 'IconsFont');
  static const IconData rocket = IconData(0xec45, fontFamily: 'IconsFont');
  static const IconData examples = IconData(0xeb39, fontFamily: 'IconsFont');
  static const IconData changeChannel =
      IconData(0xebc7, fontFamily: 'IconsFont');
}

const Color kRedColor = Color(0xffDE4629);
const Color kYellowColor = Color(0xffFFBA00);
const Color kGreenColor = Color(0xff379C81);
const Color kGreyColor = Color(0xffF1F1F1);
const Color kLightGreyColor = Color(0xffE5E5E5);
const Color kDarkColor = Color(0xff2F2F2F);
