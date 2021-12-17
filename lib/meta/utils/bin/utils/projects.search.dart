// 🎯 Dart imports:
import 'dart:io';

// 🌎 Project imports:
import 'package:manager/app/constants/shared_pref.dart';
import 'package:manager/core/libraries/models.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:manager/core/libraries/utils.dart';
import 'package:manager/meta/utils/extract_pubspec.dart';

class ProjectSearchUtils {
  static Future<List<ProjectObject>> getProjectsFromPath() async {
    if (SharedPref().pref.containsKey(SPConst.projectsPath)) {
      List<ProjectObject> projects = <ProjectObject>[];
      String? _path = SharedPref().pref.getString(SPConst.projectsPath);

      // Gets all the files in the path
      List<FileSystemEntity> files = Directory.fromUri(Uri.file(_path!))
          .listSync(recursive: true)
          .where((FileSystemEntity e) => e.path.endsWith('\\pubspec.yaml'))
          .toList();

      // Adds to the projects list the parent path of the pubspec.yaml file
      for (FileSystemEntity file in files) {
        String _parentName = file.parent.path.split('\\').last;

        if (_parentName == 'example') {
          continue;
        }

        PubspecInfo _pubspec =
            extractPubspec(await File(file.path).readAsLines());

        if (_pubspec.isValid) {
          projects.add(ProjectObject(
            path: file.parent.path,
            name: _parentName,
            description: _pubspec.description,
            // Gets the modification date of the pubspec.yaml file
            modDate: file.statSync().modified.toString(),
          ));
        }
      }

      return projects;
    } else {
      await logger.file(LogTypeTag.info,
          'Tried to get projects when the projects directory is not set.');
      return <ProjectObject>[];
    }
  }
}
