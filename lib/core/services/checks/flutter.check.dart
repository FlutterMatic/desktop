import 'dart:developer' as console;
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:manager/core/services/logs.dart';
import 'package:process_run/shell_run.dart';
import 'package:process_run/which.dart';

FlutterCheck flutterCheck = FlutterCheck();

class FlutterCheck extends ChangeNotifier {
  Shell shell = Shell();
  String _checkStatus = 'Checking for flutter';
  String? _flutterVersion, _javaVersion;
  String? get flutterVersion => _flutterVersion.toString();
  String? get javaVersion => _javaVersion.toString();
  String get checkStatus => _checkStatus;
  Future<bool> checkFlutter() async {
    try {
      String? flutterPath = await which('flutter');
      if (flutterPath == null) {
        _checkStatus = 'Flutter not found';
        notifyListeners();
        await logger.file(LogTypeTag.WARNING, 'Flutter-SDK not found');
        _checkStatus = 'Downloading flutter.';
        notifyListeners();
        await logger.file(LogTypeTag.INFO, 'Downloading Flutter-SDK');
        await checkJava();
        return true;
      }
      _checkStatus = 'Flutter found';
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
      await checkJava();
      return true;
    } catch (err) {
      console.log(err.toString());
      return false;
    }
  }

  Future<bool> checkJava() async {
    try {
      _checkStatus = 'Checking for java';
      String? javaPath = await which('java');
      if (javaPath == null) {
        _checkStatus = 'Java not found';
        notifyListeners();
        await logger.file(LogTypeTag.WARNING, 'Java not found');
        _checkStatus = 'Downloading Java.';
        notifyListeners();
        await logger.file(LogTypeTag.INFO, 'Downloading Java');
        return true;
      }
      _checkStatus = 'Java found';
      notifyListeners();
      await logger.file(LogTypeTag.INFO, 'Java path : $javaPath');
      notifyListeners();
      List<ProcessResult> results = await run('java -version', verbose: false);
      String resultOutput = results.first.stderr.toString().trim();
      if (resultOutput.isEmpty) {
        resultOutput = results.first.stdout.toString().trim();
      }
      _javaVersion = resultOutput.split('\n').first.split(' ').last;
      console.log(resultOutput);
      await logger.file(
          LogTypeTag.INFO, 'Java version : ${_javaVersion!.toString()}');
      return true;
    } catch (err) {
      await logger.file(LogTypeTag.ERROR, err.toString());
      return false;
    }
  }
}
