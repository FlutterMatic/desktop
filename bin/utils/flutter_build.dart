import 'package:process_run/shell.dart';

import 'app_data.dart';

class FlutterMaticBuild {
  static Future<void> build(String? platform) async {
    /// Shell object.
    Shell shell = Shell(
      commandVerbose: false,
      commentVerbose: false,
      runInShell: true,
      verbose: false,
    );
    List<String> args = <String>['build'];
    if (appData.platform != null) args.add(appData.platform!.toLowerCase());
    if (appData.buildMode != null) args.add('--${appData.buildMode!.toLowerCase()}');
    if (appData.releaseType != null) {
      args.add('--dart-define');
      args.add('release-type=${appData.releaseType}');
    }
    if (appData.version != null) {
      args.add('--dart-define');
      args.add('current-version=${appData.version}');
    }
    await shell.run('flutter ${args.join(' ')}');
  }
}
