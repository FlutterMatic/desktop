// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io';

// 🌎 Project imports:
import 'package:fluttermatic/core/models/projects.model.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/extract_pubspec.dart';
import 'package:fluttermatic/meta/views/tabs/sections/projects/models/projects.services.dart';

class ProjectSearchUtils {
  /// Returns the path where the projects cache is stored or where it should
  /// be stored.
  static String getProjectCachePath(String applicationSupportDir) =>
      applicationSupportDir + '\\cache\\project_cache.json';

  /// Will return [true] if there is cache for the personal projects and [false]
  /// if there isn't.
  static Future<bool> hasCache(String supportDir) async =>
      File(getProjectCachePath(supportDir)).exists();

  /// Gets all the project from the path stored in shared preferences.
  ///
  /// NOTE: This is a very performance impacting request and will freeze the
  /// screen if not handled correctly. Try isolating this function in a
  /// different thread.
  ///
  /// Avoid calling this function too many times as they could be a reason the
  /// user will delete this app because of performance issues. Use clever
  /// caching algorithms that self merge when new changes are found.
  static Future<List<ProjectObject>> getProjectsFromPath({
    required ProjectCacheResult cache,
    required String supportDir,
  }) async {
    try {
      if (cache.projectsPath != null) {
        List<ProjectObject> _projects = <ProjectObject>[];

        // Gets all the files in the path
        List<FileSystemEntity> files = Directory.fromUri(
                Uri.file(cache.projectsPath!))
            .listSync(recursive: true)
            .where((FileSystemEntity e) => e.path.endsWith('\\pubspec.yaml'))
            .toList();

        // Adds to the projects list the parent path of the pubspec.yaml file
        for (FileSystemEntity file in files) {
          String _parentName = file.parent.path.split('\\').last;

          if (_parentName == 'example') {
            continue;
          }

          PubspecInfo _pubspec = extractPubspec(
              lines: await File(file.path).readAsLines(), path: file.path);

          if (_pubspec.isValid) {
            _projects.add(ProjectObject(
              path: file.parent.path,
              name: _parentName,
              description: _pubspec.description,
              modDate: file.statSync().modified,
            ));
          }
        }

        // Sets the cache for the projects.
        await File(getProjectCachePath(supportDir)).writeAsString(
            jsonEncode(_projects.map((_) => _.toJson()).toList()));

        await ProjectServicesModel.updateProjectCache(
          cache: ProjectCacheResult(
            projectsPath: null,
            refreshIntervals: null,
            lastProjectReload: DateTime.now(),
            lastWorkflowsReload: null,
          ),
          supportDir: supportDir,
        );

        return _projects;
      } else {
        await logger.file(LogTypeTag.info,
            'Tried to get projects when the projects directory is not set.',
            logDir: Directory(supportDir));
        return <ProjectObject>[];
      }
    } catch (_, s) {
      await logger.file(LogTypeTag.error, 'Couldn\'t fetch projects from path',
          stackTraces: s, logDir: Directory(supportDir));
      return <ProjectObject>[];
    }
  }

  static Future<List<ProjectObject>> getProjectsFromCache(
      String supportDir) async {
    try {
      if (await hasCache(supportDir)) {
        // Gets the projects from the cache.
        List<ProjectObject> _projectsFromCache = (jsonDecode(
          await File(getProjectCachePath(supportDir)).readAsString(),
        ) as List<dynamic>)
            // ignore: unnecessary_lambdas
            .map((_) => ProjectObject.fromJson(_))
            .toList();

        return _projectsFromCache;
      } else {
        await logger.file(LogTypeTag.warning,
            'Tried to get projects when the projects cache is not set. Should request to fetch in background as an initial fetch from path.',
            logDir: Directory(supportDir));
        return <ProjectObject>[];
      }
    } catch (_, s) {
      await logger.file(LogTypeTag.error, 'Couldn\'t fetch from projects cache',
          stackTraces: s, logDir: Directory(supportDir));
      return <ProjectObject>[];
    }
  }
}
