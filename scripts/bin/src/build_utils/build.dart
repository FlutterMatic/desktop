// Dart imports:
import 'dart:io';

// Project imports:
import '../../script.dart';
import '../../utils.dart';

enum BuildMode { release, profile, debug }

Future<void> buildWithMode(BuildMode mode, String target) async {
  try {
    String _cmd = 'flutter build $target --${mode.name}';

    await shell.cd(fluttermaticDesktopPath).run('dart run import_sorter:main');
    await shell.cd(fluttermaticDesktopPath).run(_cmd);
  } catch (_) {
    print(errorPen('Failed to build with mode $mode on $target'));
    exit(1);
  }
}
