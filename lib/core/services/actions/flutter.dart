import 'package:manager/core/libraries/constants.dart';

class FlutterActionServices {
  static Future<void> createNewProject(NewFlutterProjectInfo project) async {
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
      throw ArgumentError('At least one platform must be selected.');
    }

    // Create the project.
    await shell.cd('').run(
          // TODO(@ZiyadF296): Use the project path.
          'flutter create --template=app ${project.projectName} --org=${project.orgName} --android=${project.android} --ios=${project.iOS} --web=${project.web} --macos=${project.macos} --windows=${project.windows} --linux=${project.linux}',
        );
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
  final bool nullSafety;

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
    required this.nullSafety,
  });
}
