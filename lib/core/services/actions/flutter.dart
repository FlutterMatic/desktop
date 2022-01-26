// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/core/services/logs.dart';

class FlutterActionServices {
  static Future<String> createNewProject(NewFlutterProjectInfo project) async {
    try {
      if (project.projectPath.isEmpty) {
        return 'Project path is empty. Please provide a valid path.';
      }

      String _platforms = <String>[
        if (project.android) 'android',
        if (project.iOS) 'ios',
        if (project.web) 'web',
        if (project.macos) 'macos',
        if (project.windows) 'windows',
        if (project.linux) 'linux',
      ].join(',');

      // Make sure that [_platforms] is not empty (meaning there is at least
      // one platform selected).
      if (_platforms.isEmpty) {
        await logger.file(LogTypeTag.warning,
            'Selected no platform(s) but tried to create a project');
        return 'At least one platform must be selected.';
      }

      // Create the project.
      await shell.cd(project.projectPath).run(
            'flutter create --template=app ${project.projectName} --org ${project.orgName} --platforms $_platforms',
          );

      return 'success';
    } catch (_, s) {
      await logger.file(
          LogTypeTag.error, 'Failed to create new Flutter project: $_',
          stackTraces: s);
      return 'Failed to create new Flutter project. Please try again or report this issue.';
    }
  }
}

class NewFlutterProjectInfo {
  final String projectName;
  final String projectPath;
  final String description;
  final String orgName;
  final Map<String, dynamic> firebaseJson;
  final bool iOS;
  final bool android;
  final bool web;
  final bool windows;
  final bool macos;
  final bool linux;

  const NewFlutterProjectInfo({
    required this.projectName,
    required this.projectPath,
    required this.description,
    required this.orgName,
    required this.firebaseJson,
    required this.iOS,
    required this.android,
    required this.web,
    required this.windows,
    required this.macos,
    required this.linux,
  });
}
