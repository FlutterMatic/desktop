// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:process_run/shell.dart';

// 🌎 Project imports:
import 'package:fluttermatic/core/models/flutter_sdk.model.dart';
import 'package:fluttermatic/core/models/fluttermatic.model.dart';

// Shell global reference
final Shell shell = Shell(
  commandVerbose: false,
  commentVerbose: false,
  runInShell: true,
  verbose: false,
);

bool completedSetup = false;

/// Whether or not to show the dev controls.
bool _showDevControls = false;

bool allowDevControls = (kDebugMode && _showDevControls);

/// FlutterMatic workflow dir in projects
const String fmWorkflowDir = '.fmatic';

/// FlutterMatic API data object.
FlutterMaticAPI? apiData;

/// Flutter-SDK API data object.
FlutterSDK? sdkData;

/// Tag name for vscode
String? tagName;

/// SHA for vscode
String? sha;

// OS
String platform = Platform.operatingSystem;
String osName = Platform.operatingSystem;
String osVersion = Platform.operatingSystemVersion;
String appVersion =
    const String.fromEnvironment('CURRENT_VERSION').split('-').first;
String appBuild = const String.fromEnvironment('RELEASE_TYPE').toUpperCase();

const String _placeholderBase = 'assets/images/placeholders/';
const String _imagesIconsBase = 'assets/images/icons/';
const String _imagesLogosBase = 'assets/images/logos/';
const String _lottieBase = 'assets/lottie/';

/// Class for assets
class Assets {
  static const String studio = '${_imagesLogosBase}android_studio.svg';
  static const String firebase = '${_imagesLogosBase}firebase.svg';
  static const String settings = '${_imagesIconsBase}settings.svg';
  static const String workflow = '${_imagesIconsBase}workflow.svg';
  static const String confetti = '${_imagesIconsBase}confetti.svg';
  static const String package = '${_imagesIconsBase}package.svg';
  static const String project = '${_imagesIconsBase}project.svg';
  static const String flutter = '${_imagesLogosBase}flutter.svg';
  static const String codingLottie = '${_lottieBase}coding.json';
  static const String twitter = '${_imagesLogosBase}twitter.svg';
  static const String vscode = '${_imagesLogosBase}vs_code.svg';
  static const String packages = '${_lottieBase}packages.json';
  static const String logo = '${_imagesLogosBase}app_logo.svg';
  static const String coding = '${_placeholderBase}coding.svg';
  static const String editor = '${_imagesIconsBase}editor.svg';
  static const String github = '${_imagesLogosBase}github.svg';
  static const String xCode = '${_imagesLogosBase}xcode.png';
  static const String error = '${_imagesIconsBase}error.svg';
  static const String ghosts = '${_lottieBase}ghosts.json';
  static const String home = '${_imagesIconsBase}home.svg';
  static const String dart = '${_imagesLogosBase}dart.svg';
  static const String done = '${_imagesIconsBase}done.svg';
  static const String warn = '${_imagesIconsBase}warn.svg';
  static const String java = '${_imagesLogosBase}java.svg';
  static const String doc = '${_imagesIconsBase}doc.svg';
  static const String git = '${_imagesLogosBase}git.svg';
  static const String appLogo = 'assets/images/logo.png';
  static const String appFrame = 'assets/images/frame.png';
}

const Color kRedColor = Color(0xffE44516);
const Color kYellowColor = Color(0xffF7C605);
const Color kGreenColor = Color(0xff07C2A3);

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
  // OS Type
  static const String winOS = 'Windows 7 SP1 or later (64-bit), x86-64 based';
  static const String macOS = 'macOS';
  static const String linuxOS = 'Linux (64 bit)';

  // Space Required
  static const String winSpace = '1.7 GB (Only Flutter SDK)';
  static const String macSpace = '2.8 GB (Only Flutter SDK)';
  static const String linuxSpace = '600 MB (Only Flutter SDK)';

  // Tools Required
  static const String winTools = 'Git, PowerShell, Java (version: 1.8.***)';
  static const String macTools = 'Git, CocoaPods, Java (version: 1.8.***)';
  static const String linuxTools =
      'bash, curl, file, git 2.x, mkdir, rm, unzip, which, xz-utils, zip, Java (version: 1.8.***)';
}
