import 'package:flutter/material.dart';
import 'package:manager/core/services/logs.dart';
import 'package:process_run/which.dart';
import 'package:pub_semver/src/version.dart';

class JavaCheck extends ChangeNotifier {
  String _checkStatus = 'Checking for Java';
  Version? _javaVersion;
  String? get javaVersion => _javaVersion.toString();
  String get checkStatus => _checkStatus;
  Future<bool> checkJava() async {
    try {
      String? javaPath = await which('java');
      if (javaPath == null) {
        _checkStatus = 'Java not found';
        notifyListeners();
        await logger.file(LogTypeTag.WARNING, 'Flutter-SDK not found');
        _checkStatus = 'Downloading Java.';
        notifyListeners();
        await logger.file(LogTypeTag.INFO, 'Downloading Java');
        return true;
      }
      _checkStatus = 'Java found';
      notifyListeners();
      await logger.file(LogTypeTag.INFO, 'Java path : $javaPath');
      notifyListeners();
      await logger.file(
          LogTypeTag.INFO, 'Java version : ${_javaVersion.toString()}');
            return true;
    } catch (err) {
      await logger.file(LogTypeTag.ERROR, err.toString());
      return false;
    }
  }
}
