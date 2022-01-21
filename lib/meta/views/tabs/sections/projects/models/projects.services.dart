// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

// 🌎 Project imports:
import 'package:fluttermatic/core/libraries/models.dart';
import 'package:fluttermatic/core/libraries/services.dart';
import 'package:fluttermatic/meta/utils/bin/utils/projects.search.dart';

class ProjectServicesModel {
  /// Gets the cache about the projects information and about the projects path
  /// where they can be found.
  static Future<ProjectCacheResult?> getProjectCache(String supportDir) async {
    File _file = File(supportDir + '\\cache\\projects_cache_settings.json');

    if (!await _file.exists()) {
      return null;
    }

    Map<String, dynamic> _cache = jsonDecode((await _file.readAsString()));

    return ProjectCacheResult(
      projectsPath: _cache['projectsPath'],
      refreshIntervals: _cache['refreshIntervals'],
      lastReload: DateTime.tryParse(_cache['lastReload']),
    );
  }

  /// Updates the cache with the new information.
  /// Provide the [ProjectCacheResult] and it will update the provided cache
  /// with the new information. If any attribute is null, it will not be
  /// updated, only the provided cache will be updated.
  static Future<void> updateProjectCache({
    required String supportDir,
    required ProjectCacheResult cache,
  }) async {
    File _file = File(supportDir + '\\cache\\projects_cache_settings.json');

    Map<String, dynamic> _oldCache = <String, dynamic>{};

    // If the old cache exists, we will merge it with the new one.
    if (await _file.exists()) {
      _oldCache = jsonDecode((await _file.readAsString()));
    }

    dynamic _getValue(String key) =>
        (_oldCache.containsKey(key) ? _oldCache[key] : null);

    ProjectCacheResult _newCache = ProjectCacheResult(
      projectsPath: cache.projectsPath ?? _getValue('projectsPath'),
      refreshIntervals: cache.refreshIntervals ?? _getValue('refreshIntervals'),
      lastReload:
          cache.lastReload ?? DateTime.tryParse(_getValue('lastReload')),
    );

    await _file.writeAsString(jsonEncode(_newCache.toJson()));
  }

  /// If we have cache, we will use it to improve performance. After we send to
  /// the port listener, we will then fetch again to update the cache in the
  /// background.
  ///
  /// The first is the list of projects, the second is a boolean. True means
  /// that we want to kill the isolate and false means there is another response
  /// coming in soon so don't kill the isolate. The third item in the list is a
  /// boolean meaning is it refetching from cache or not.
  ///
  /// **RESPONSE FORMAT**:
  /// [<List> projects, <boolean> killIsolate, <boolean> isExpectedAnotherResponse]
  static Future<void> getProjectsIsolate(List<dynamic> data) async {
    SendPort _port = data[0];
    String _supportDir = data[1];

    if (await ProjectSearchUtils.hasCache(_supportDir)) {
      await logger.file(
          LogTypeTag.info, 'Fetching projects from cache. Cache found.',
          logDir: Directory(_supportDir));

      List<ProjectObject> _projectsCache =
          await ProjectSearchUtils.getProjectsFromCache(_supportDir);

      ProjectCacheResult? _cache = await getProjectCache(_supportDir);

      // Check to see if we need to refetch again because of time interval or cache
      // expired.
      if (_cache != null) {
        // Cache expired. Will return the expired cache for performance, then will
        // refetch the cache in the background and update the listener with the
        // new cache if there is a difference to avoid unnecessary rebuilds.

        bool _isExpiredCache = true;

        // Seconds Difference
        int _difference = DateTime.now()
            .difference(_cache.lastReload ?? DateTime.now())
            .inSeconds;

        // Check to see if the cache is expired.
        // Interval in minutes. Must be in seconds.
        if (_difference < ((_cache.refreshIntervals ?? 0) * 60)) {
          _isExpiredCache = false;
        }

        if (_isExpiredCache) {
          await logger.file(
              LogTypeTag.info, 'Fetching projects from scratch. Cache expired.',
              logDir: Directory(_supportDir));

          // Don't kill isolate. Will refetch with cache.
          _port.send(<dynamic>[_projectsCache, false, true]);

          List<ProjectObject> _projectsRefetch =
              await ProjectSearchUtils.getProjectsFromPath(
            cache: await getProjectCache(_supportDir) ??
                const ProjectCacheResult(
                  lastReload: null,
                  projectsPath: null,
                  refreshIntervals: null,
                ),
            supportDir: _supportDir,
          );

          // Kill isolate. Cache is now updated.
          _port.send(<dynamic>[_projectsRefetch, true, false]);
        } else {
          await logger.file(LogTypeTag.info,
              'Fetching projects from cache. Cache still valid.',
              logDir: Directory(_supportDir));
          // Kill isolate. Cache is still valid.
          _port.send(<dynamic>[_projectsCache, true, false]);
        }
      } else {
        // Kill isolate.
        _port.send(<dynamic>[_projectsCache, true, false]);
      }

      return;
    } else {
      await logger.file(
          LogTypeTag.info, 'Fetching projects initially. No cache found.',
          logDir: Directory(_supportDir));
      List<ProjectObject> _projectsPaths =
          await ProjectSearchUtils.getProjectsFromPath(
        cache: await getProjectCache(_supportDir) ??
            const ProjectCacheResult(
              lastReload: null,
              projectsPath: null,
              refreshIntervals: null,
            ),
        supportDir: _supportDir,
      );

      _port.send(<dynamic>[_projectsPaths, true, false]);
      return;
    }
  }
}

class ProjectCacheResult {
  final String? projectsPath;
  final int? refreshIntervals;
  final DateTime? lastReload;

  const ProjectCacheResult({
    required this.projectsPath,
    required this.refreshIntervals,
    required this.lastReload,
  });

  factory ProjectCacheResult.fromJson(Map<String, dynamic> json) {
    return ProjectCacheResult(
      projectsPath: json['projectsPath'].toString(),
      refreshIntervals: int.parse(json['refreshIntervals']),
      lastReload: DateTime.parse(json['lastReload']),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'projectsPath': projectsPath,
      'refreshIntervals': refreshIntervals,
      'lastReload': lastReload.toString(),
    };
  }
}
