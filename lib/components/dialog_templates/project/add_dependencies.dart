import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/core/services/logs.dart';

Future<bool> addDependencyToProject({
  required String path,
  required String dependency,
  required bool isDev,
  required bool isDart,
}) async {
  try {
    await shell.cd(path).run(
        '${isDart ? 'dart' : 'flutter'} pub add $dependency${isDev ? ' --dev' : ''}');
    return true;
  } catch (_, s) {
    await logger.file(LogTypeTag.warning,
        'Failed to add ${isDev ? 'dev' : 'normal'} dependency to project. Could be already added: $_',
        stackTraces: s);

    return false;
  }
}
