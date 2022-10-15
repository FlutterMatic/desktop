// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/core/services/logs.dart';

Future<bool> addDependencyToProject({
  required String path,
  required String dependency,
  required bool isDev,
  required bool isDart,
  bool remove = false,
}) async {
  try {
    await shell.cd(path).run(
        '${isDart ? 'dart' : 'flutter'} pub ${remove ? 'remove' : 'add'} $dependency${isDev ? ' --dev' : ''}');

    await logger.file(LogTypeTag.info,
        'Successfully ${remove ? 'removed' : 'added'} ${isDev ? 'dev' : 'normal'} dependency to project.');

    return true;
  } catch (e, s) {
    await logger.file(LogTypeTag.warning,
        'Failed to add ${isDev ? 'dev' : 'normal'} dependency to project. Could be already added.',
        error: e, stackTrace: s);

    return false;
  }
}
