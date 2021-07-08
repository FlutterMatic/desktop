import 'dart:io';
import 'dart:developer' as console;

import 'package:flutter/material.dart';
import 'package:manager/core/services/checks/flutter.check.dart'
    show checkStatus;
import 'package:manager/core/services/logs.dart';
import 'package:process_run/shell_run.dart';

class JavaCheck extends ChangeNotifier {
  Shell shell = Shell();
  String? _flutterVersion, _javaVersion;
  String? get flutterVersion => _flutterVersion.toString();
  String? get javaVersion => _javaVersion.toString();
  String get checkJavaStatus => checkStatus;
  Future<bool> checkJava() async {
    try {
      checkStatus = 'Checking for java';
      String? javaPath = await which('java');
      if (javaPath == null) {
        checkStatus = 'Java not found';
        notifyListeners();
        await logger.file(LogTypeTag.WARNING, 'Java not found');
        checkStatus = 'Downloading Java.';
        notifyListeners();
        await logger.file(LogTypeTag.INFO, 'Downloading Java');
        return true;
      }
      checkStatus = 'Java found';
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
