import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:process_run/shell_run.dart';

class FlutterActions {
  Shell shell = Shell();

  Future<void> flutterCreate(
      String projName, String projDesc, String projOrg) async {
    List<ProcessResult> result = await shell.run(
      'flutter create --project-name $projName --description $projDesc --org $projOrg',
    );
    debugPrint(result.outText);
  }
}
