// Dart imports:
import 'dart:io';

// Project imports:
import '../../script.dart';
import '../../utils.dart';
import '../version.dart';

enum BuildMode { release, profile, debug }

Future<void> buildWithMode(
    BuildMode mode, Version version, String target) async {
  try {
    String _cmd = 'flutter build $target --${mode.name}';

    // Add the release type to the String from environment.
    _cmd += ' --dart-define RELEASE_TYPE=${version.releaseType.name}';

    // Add the current version to the String from environment.
    _cmd += ' --dart-define CURRENT_VERSION=';
    _cmd += '${version.major}.${version.minor}.${version.patch}';
    _cmd += '-${version.releaseType.name}';

    await shell.cd(fluttermaticDesktopPath).run('dart run import_sorter:main');
    await shell.cd(fluttermaticDesktopPath).run(_cmd);
  } catch (_) {
    print(errorPen('Failed to build with mode $mode on $target'));
    exit(1);
  }
}
