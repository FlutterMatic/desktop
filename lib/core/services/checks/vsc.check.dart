import 'dart:developer' as console;
import 'package:flutter/material.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:manager/core/libraries/models.dart';
import 'package:manager/meta/utils/bin/code.bin.dart';
import 'package:process_run/shell.dart';
import 'package:pub_semver/src/version.dart';

/// [VSCodeNotifier] class is a [ValueNotifier]
/// for VS Code checks.
class VSCodeNotifier extends ValueNotifier<String> {
  VSCodeNotifier([String value = 'Checking VS Code']) : super(value);

  /// [vscVersion] value holds VS Code version information
  Version? vscVersion;
  Future<void> checkVSCode(BuildContext context, FluttermaticAPI? api) async {
    try {
      /// Make a fake delay of 1 second such that UI looks cool.
      await Future<dynamic>.delayed(const Duration(seconds: 1));
      String? vscPath = await which('code');
      if (vscPath == null) {
        value = 'VS Code not installed';
        await logger.file(
            LogTypeTag.WARNING, 'VS Code not installed in the system.');
        value = 'Downloading VS Code';
        await logger.file(LogTypeTag.INFO, 'Downloading VS Code');
      }

      /// Make a fake delay of 1 second such that UI looks cool.
      await Future<dynamic>.delayed(const Duration(seconds: 1));
      value = 'VS Code found';
      await logger.file(LogTypeTag.INFO, 'VS Code found at - $vscPath');

      /// Make a fake delay of 1 second such that UI looks cool.
      await Future<dynamic>.delayed(const Duration(seconds: 1));
      value = 'Fetching VS Code version';
      vscVersion = await getVSCBinVersion();
      versions.vsCode = vscVersion.toString();
      await logger.file(
          LogTypeTag.INFO, 'VS Code version : ${versions.vsCode}');
    } on ShellException catch (shellException) {
      console.log(shellException.message);
      await logger.file(LogTypeTag.ERROR, shellException.message);
    } catch (err) {
      console.log(err.toString());
      await logger.file(LogTypeTag.ERROR, err.toString());
    }
  }
}

class VSCodeChangeNotifier extends VSCodeNotifier {
  VSCodeChangeNotifier() : super('Checking VS Code');
}
