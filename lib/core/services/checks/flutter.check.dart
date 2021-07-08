import 'dart:developer' as console;

import 'package:flutter/widgets.dart';
import 'package:manager/core/services/logs.dart';
import 'package:process_run/shell_run.dart';
import 'package:process_run/which.dart';

FlutterCheck flutterCheck = FlutterCheck();

String checkStatus = 'Checking for flutter';

class FlutterCheck extends ChangeNotifier {
  Shell shell = Shell();
  String? _flutterVersion, _javaVersion;
  String? get flutterVersion => _flutterVersion.toString();
  String? get javaVersion => _javaVersion.toString();
  String get checkFlutterStatus => checkStatus;
  Future<bool> checkFlutter(BuildContext context) async {
    try {
      String? flutterPath = await which('flutter');
      if (flutterPath == null) {
        checkStatus = 'Flutter not found';
        notifyListeners();
        await logger.file(LogTypeTag.WARNING, 'Flutter-SDK not found');
        checkStatus = 'Downloading flutter.';
        notifyListeners();
        await logger.file(LogTypeTag.INFO, 'Downloading Flutter-SDK');
        return true;
      }
      checkStatus = 'Flutter found';
      notifyListeners();
      await logger.file(LogTypeTag.INFO, 'Flutter path : $flutterPath');
      // $ flutter --version
      // Flutter 1.7.8+hotfix.4 • channel stable • https://github.com/flutter/flutter.git
      // Framework • revision 20e59316b8 (8 weeks ago) • 2019-07-18 20:04:33 -0700
      // Engine • revision fee001c93f
      // Tools • Dart 2.4.0
      notifyListeners();
      await logger.file(
          LogTypeTag.INFO, 'Flutter version : ${_flutterVersion!.toString()}');
      return true;
    } catch (err) {
      console.log(err.toString());
      return false;
    }
  }
}
