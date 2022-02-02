// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/core/services/logs.dart';

class DartActionServices {
  static Future<String> createNewProject(NewDartProjectInfo project) async {
    try {
      if (project.projectPath.isEmpty) {
        return 'Project path is empty. Please provide a valid path.';
      }

      // Create the project.
      await shell
          .cd(project.projectPath)
          .run('dart create -t ${project.template} ${project.projectName}');

      await logger.file(LogTypeTag.info,
          'Created new Dart project: ${project.toString()} at path: ${project.projectPath}');

      return 'success';
    } catch (_, s) {
      await logger.file(
          LogTypeTag.error, 'Failed to create new Dart project: $_',
          stackTraces: s);
      return 'Failed to create new Dart project. Please try again or report this issue.';
    }
  }
}

class NewDartProjectInfo {
  final String projectName;
  final String projectPath;
  final String template;

  const NewDartProjectInfo({
    required this.projectName,
    required this.projectPath,
    required this.template,
  });
}
