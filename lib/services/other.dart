import 'package:flutter/widgets.dart';
import 'package:flutter_installer/utils/constants.dart';
import 'package:process_run/shell.dart';

Shell shell = Shell(
  verbose: false,
  commandVerbose: false,
  commentVerbose: false,
);

Future<bool> compareVersion(
    {required String previousVersion, required String latestVersion}) async {
  int temp1, temp2;
  temp1 = int.tryParse(previousVersion.replaceAll('.', '').toString())!;
  temp2 = int.tryParse(latestVersion.replaceAll('.', '').toString())!;
  return (temp1 < temp2) ? true : false;
}

Future<void> setPath(String? path) async {
  try {
    await shell.run('${Scripts.win32PathAdder} "${path!}"');
  } catch (e) {
    debugPrint(e.toString());
  }
}
