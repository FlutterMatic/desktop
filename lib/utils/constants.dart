import 'package:flutter/material.dart';

bool flutterExist = false;
bool javaInstalled = false;
bool vscInstalled = false;
bool vscInsidersInstalled = false;
bool studioInstalled = false;

//Assets
const String flutterIcons = 'assets/flutter_icons';
const String statusIcons = 'assets/status_icons';
const String icons = 'assets/icons';

//Animations
const String lottie = 'assets/lottie';

class LottieAssets {
  static const String folder = '$lottie/folder.json';
}

class Assets {
  //Futter Icons
  static const String development = '$flutterIcons/icon_development.svg';
  static const String performance = '$flutterIcons/icon_performance.svg';
  static const String ui = '$flutterIcons/icon_ui.svg';

  //Status Icons
  static const String done = '$statusIcons/done.svg';
  static const String warning = '$statusIcons/warning.svg';
  static const String error = '$statusIcons/error.svg';

  //Icons
  static const String upgrade = '$icons/upgrade.svg';
  static const String channels = '$icons/channels.svg';
}

class PageRoutes {
  static const String routeHome = '/';
  static const String routeInstallScreen = '/installScreen';
}

const Color kRedColor = Color(0xffDE4629);
const Color kYellowColor = Color(0xffFFBA00);
const Color kGreenColor = Color(0xff379C81);
const Color kGreyColor = Color(0xffF1F1F1);
const Color kLightGreyColor = Color(0xffE5E5E5);
const Color kDarkColor = Color(0xff2F2F2F);
