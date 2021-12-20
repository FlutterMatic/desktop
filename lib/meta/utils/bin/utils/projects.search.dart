// 🎯 Dart imports:
import 'dart:io';

// 🌎 Project imports:
import 'package:manager/core/libraries/utils.dart';
import 'package:manager/core/libraries/models.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:manager/app/constants/shared_pref.dart';
import 'package:manager/meta/utils/extract_pubspec.dart';

class ProjectSearchUtils {
  /// Gets all the project from the path stored in shared preferences.
  ///
  /// NOTE: This is a very performance impacting request and will freeze the
  /// screen if not handled correctly. Try isolating this function in a
  /// different thread.
  ///
  /// Avoid calling this function too many times as they could be a reason the
  /// user will delete this app because of performance issues. Use clever
  /// caching algorithms that self merge when new changes are found.
  static Future<List<ProjectObject>> getProjectsFromPath() async {
    try {
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
              modDate: file.statSync().modified,
            ));
          }
        }

        // Sets the cache.
        await SharedPref().pref.setStringList(SPConst.projectsCache,
            projects.map((ProjectObject e) => e.path).toList());

        return projects;
      } else {
        await logger.file(LogTypeTag.info,
            'Tried to get projects when the projects directory is not set.');
        return <ProjectObject>[];
      }
    } catch (_, s) {
      await logger.file(LogTypeTag.error, 'Couldn\'t fetch projects from path',
          stackTraces: s);
      return <ProjectObject>[];
    }
  }

  static Future<List<ProjectObject>> getProjectsCache() async {
    try {
      if (SharedPref().pref.containsKey(SPConst.projectsCache)) {
        List<ProjectObject> projects = <ProjectObject>[];

        List<String> _projectsFromCache =
            SharedPref().pref.getStringList(SPConst.projectsCache)!;

        for (String project in _projectsFromCache) {
          File _file = File(project + '\\pubspec.yaml');
          PubspecInfo _pubspec = extractPubspec(await _file.readAsLines());
          String _parentName = _file.parent.path.split('\\').last;

          projects.add(
            ProjectObject(
              name: _parentName,
              modDate: _file.statSync().modified,
              path: project,
              description: _pubspec.description,
            ),
          );
        }

        return projects;
      } else {
        await logger.file(LogTypeTag.info,
            'Tried to get projects when the projects cache is not set. Will request to fetch in background.');
        return <ProjectObject>[];
      }
    } catch (_, s) {
      await logger.file(LogTypeTag.error, 'Couldn\'t fetch from projects cache',
          stackTraces: s);
      return <ProjectObject>[];
    }
  }
}
