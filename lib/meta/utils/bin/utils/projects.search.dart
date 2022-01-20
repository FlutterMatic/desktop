// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io';

// 📦 Package imports:
import 'package:path_provider/path_provider.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/shared_pref.dart';
import 'package:fluttermatic/core/libraries/models.dart';
import 'package:fluttermatic/core/libraries/services.dart';
import 'package:fluttermatic/core/libraries/utils.dart';
import 'package:fluttermatic/meta/utils/extract_pubspec.dart';

class ProjectSearchUtils {
  /// Returns the path where the projects cache is stored or where it should
  /// be stored.
  static Future<String> getProjectCachePath() async =>
      (await getApplicationSupportDirectory()).path +
      '\\cache\\project_cache.json';

  /// Will return [true] if there is cache for the personal projects and [false]
  /// if there isn't.
  static Future<bool> hasCache() async =>
      File(await getProjectCachePath()).exists();

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
        List<ProjectObject> _projects = <ProjectObject>[];
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

          PubspecInfo _pubspec = extractPubspec(
            lines: await File(file.path).readAsLines(),
            path: file.path,
          );

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
        await File(await getProjectCachePath()).writeAsString(jsonEncode(
            _projects.map((ProjectObject e) => e.toJson()).toList()));

        await SharedPref()
            .pref
            .setString(SPConst.lastProjectsReload, DateTime.now().toString());

        return _projects;
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

  static Future<List<ProjectObject>> getProjectsFromCache() async {
    try {
      if (await hasCache()) {
        // Gets the projects from the cache.
        List<ProjectObject> _projectsFromCache = (jsonDecode(
          await File(await getProjectCachePath()).readAsString(),
        ) as List<dynamic>)
            // ignore: unnecessary_lambdas
            .map((_) => ProjectObject.fromJson(_))
            .toList();

        return _projectsFromCache;
      } else {
        await logger.file(LogTypeTag.warning,
            'Tried to get projects when the projects cache is not set. Should request to fetch in background as an initial fetch.');
        return <ProjectObject>[];
      }
    } catch (_, s) {
      await logger.file(LogTypeTag.error, 'Couldn\'t fetch from projects cache',
          stackTraces: s);
      return <ProjectObject>[];
    }
  }
}
