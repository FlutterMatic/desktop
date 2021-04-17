import 'package:flutter/material.dart';

bool flutterExist = false;
bool javaInstalled = false;
bool vscInstalled = false;
bool vscInsidersInstalled = false;
bool studioInstalled = false;

const String images = 'assets/images';
const String lottie = 'assets/lottie';

class LottieAssets {
  static const String folder = '$lottie/folder.json';
}

class Assets {
  static const String flutterIcon = '$images/flutter_icon.png';
}

class PageRoutes {
  static const String routeHome = '/';
  static const String routeState = '/state';
  static const String routeInstallScreen = '/installScreen';
}

const kRedColor = Color(0xffDE4629);
const kYellowColor = Color(0xffFFBA00);
const kGreenColor = Color(0xff379C81);
const kGreyColor = Color(0xffF1F1F1);
const kDarkColor = Color(0xff2F2F2F);
