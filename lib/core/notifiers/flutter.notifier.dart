import 'dart:developer' as console;
import 'package:flutter/material.dart';
import 'package:manager/core/models/version.model.dart';
import 'package:manager/core/services/logs.dart';
import 'package:process_run/shell_run.dart';
import 'package:process_run/which.dart';
import 'package:pub_semver/src/version.dart';

class FlutterNotifier extends ValueNotifier<String> {
  FlutterNotifier([String value = 'Checking flutter']) : super(value);
  Versions versions = Versions();
  Version? flutterVersion;
  Future<void> flutterCheck() async {
    try {
      String? flutterPath = await which('flutter');
      if (flutterPath == null) {
        value = 'Flutter not found';
        await logger.file(LogTypeTag.WARNING, 'Flutter-SDK not found');
        value = 'Downloading flutter.';
        await logger.file(LogTypeTag.INFO, 'Downloading Flutter-SDK');
      }
      value = 'Flutter-SDK found.';
      versions.flutter = getFlutterBinVersion().toString();
      await logger.file(
          LogTypeTag.INFO, 'Flutter version : ${versions.flutter}');
      versions.channel = await getFlutterBinChannel();
      await logger.file(
          LogTypeTag.INFO, 'Flutter channel : ${versions.channel}');
    } on ShellException catch (shellException) {
      console.log(shellException.message);
      await logger.file(LogTypeTag.ERROR, shellException.message);
    } catch (err) {
      console.log(err.toString());
      await logger.file(LogTypeTag.ERROR, err.toString());
    }
  }
}

class FlutterChangeNotifier extends FlutterNotifier {
  FlutterChangeNotifier() : super('Checking Flutter');
}
