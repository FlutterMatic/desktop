import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:process_run/cmd_run.dart';
import 'package:process_run/shell_run.dart';

class FlutterActions {
  Shell shell = Shell();

  Future<void> flutterCreate(
      String projName, String projDesc, String projOrg) async {
    ProcessCmd cmd = ProcessCmd('flutter', [
      'create',
      '--project-name',
      projName,
      '--description',
      projDesc,
      '--org',
      projOrg,
    ]);
    ProcessResult result = await runCmd(cmd);
    debugPrint(result.outText);
  }
}
