import 'package:flutter/widgets.dart';
import 'package:flutter_installer/utils/constants.dart';
import 'package:process_run/shell.dart';

Shell _shell = Shell(
  verbose: false,
  commandVerbose: false,
  commentVerbose: false,
);

Future<bool> compareVersion(
    {required String previousVersion, required String latestVersion}) async {
  int oldV, newV;
  oldV = int.tryParse(previousVersion.replaceAll('.', '').toString())!;
  newV = int.tryParse(latestVersion.replaceAll('.', '').toString())!;
  return oldV < newV;
}

Future<bool> setPath(String? path) async {
  if (path != null) {
    try {
      await _shell.run('${Scripts.win32PathAdder} "$path"');
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  } else {
    debugPrint('No path provided');
    return false;
  }
}
