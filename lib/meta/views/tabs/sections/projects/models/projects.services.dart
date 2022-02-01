// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

// 📦 Package imports:
import 'package:path_provider/path_provider.dart';

// 🌎 Project imports:
import 'package:fluttermatic/core/models/projects.model.dart';
import 'package:fluttermatic/core/services/logs.dart';
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

    return ProjectCacheResult.fromJson(_cache);
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
      refreshIntervals: cache.refreshIntervals ??
          int.tryParse(_getValue('refreshIntervals') ?? '1'),
      lastProjectReload: cache.lastProjectReload ??
          DateTime.tryParse(_getValue('lastReload') ?? ''),
      lastWorkflowsReload: cache.lastWorkflowsReload ??
          DateTime.tryParse(_getValue('lastWorkflowsReload') ?? ''),
    );

    await _file.writeAsString(jsonEncode(_newCache.toJson()));
  }

  /// Will update the cache for the projects locally and set the new pinned
  /// status for the provided project path.
  static Future<void> updateProjectPinStatus(String path, bool isPinned) async {
    try {
      Directory _dir = await getApplicationSupportDirectory();

      // Gets the existing cache so that we can alter it with the new pinned
      // status.
      List<ProjectObject> _cache =
          await ProjectSearchUtils.getProjectsFromCache(_dir.path);

      // Projects cache structure:
      // [
      //   {
      //    "name": "Project 1",
      //    ...
      //   },
      //   {
      //    "name": "Project 1",
      //    ...
      //   }
      // ]

      List<Map<String, dynamic>> _newCache = <Map<String, dynamic>>[];

      // Will find the project that matches the provided path and update the
      // pinned status.
      for (ProjectObject project in _cache) {
        ProjectObject _newProject = ProjectObject(
          name: project.name,
          modDate: project.modDate,
          path: project.path,
          description: project.description,
          pinned: project.path == path ? isPinned : project.pinned,
        );

        _newCache.add(_newProject.toJson());
      }

      // Now we will write the new cache to the file.
      await File(ProjectSearchUtils.getProjectCachePath(_dir.path))
          .writeAsString(jsonEncode(_newCache));
    } catch (_, s) {
      await logger.file(LogTypeTag.error,
          'Failed to update the pinned status for the project: $path :$_',
          stackTraces: s);
    }
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
    bool _force = data[2]; // Whether to force to refetch from scratch even if
    // we have cache that is not expired.

    if (await ProjectSearchUtils.hasCache(_supportDir)) {
      await logger.file(
          LogTypeTag.info, 'Fetching projects from cache. Cache found.',
          logDir: Directory(_supportDir));

      List<ProjectObject> _projectsCache =
          await ProjectSearchUtils.getProjectsFromCache(_supportDir);

      ProjectIsolateFetchResult _result = ProjectIsolateFetchResult(
        projects: _projectsCache.where((ProjectObject e) => !e.pinned).toList(),
        pinnedProjects:
            _projectsCache.where((ProjectObject e) => e.pinned).toList(),
      );

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
            .difference(_cache.lastProjectReload ?? DateTime.now())
            .inSeconds;

        // Check to see if the cache is expired. Interval in minutes. Must be
        // in seconds.
        if (((_cache.refreshIntervals ?? 0) * 60) > _difference) {
          _isExpiredCache = false;
        }

        if (_isExpiredCache || _force) {
          if (_force) {
            await logger.file(LogTypeTag.info,
                'Fetching projects from cache. Cache expired. Force refetch.',
                logDir: Directory(_supportDir));
          }

          await logger.file(
              LogTypeTag.info, 'Fetching projects from scratch. Cache expired.',
              logDir: Directory(_supportDir));

          // Don't kill isolate. Will refetch with cache.
          _port.send(<dynamic>[_result, false, true]);

          List<ProjectObject> _projectsRefetch =
              await ProjectSearchUtils.getProjectsFromPath(
            cache: _cache,
            supportDir: _supportDir,
          );

          // Update cache.
          await updateProjectCache(
            supportDir: _supportDir,
            cache: ProjectCacheResult(
              projectsPath: null,
              refreshIntervals: null,
              lastProjectReload: DateTime.now(),
              lastWorkflowsReload: null,
            ),
          );

          ProjectIsolateFetchResult _refetchResult = ProjectIsolateFetchResult(
            projects:
                _projectsRefetch.where((ProjectObject e) => !e.pinned).toList(),
            pinnedProjects:
                _projectsRefetch.where((ProjectObject e) => e.pinned).toList(),
          );

          // Kill isolate. Cache is now updated.
          _port.send(<dynamic>[_refetchResult, true, false]);
          return;
        } else {
          await logger.file(LogTypeTag.info,
              'Fetching projects from cache. Cache still valid.',
              logDir: Directory(_supportDir));
          // Kill isolate. Cache is still valid.
          _port.send(<dynamic>[_result, true, false]);
          return;
        }
      } else {
        // Kill isolate.
        _port.send(<dynamic>[_result, true, false]);
        return;
      }
    } else {
      await logger.file(
          LogTypeTag.info, 'Fetching projects initially. No cache found.',
          logDir: Directory(_supportDir));

      List<ProjectObject> _projectsPaths =
          await ProjectSearchUtils.getProjectsFromPath(
        cache: await getProjectCache(_supportDir) ??
            const ProjectCacheResult(
              lastProjectReload: null,
              projectsPath: null,
              refreshIntervals: null,
              lastWorkflowsReload: null,
            ),
        supportDir: _supportDir,
      );

      ProjectIsolateFetchResult _result = ProjectIsolateFetchResult(
        projects: _projectsPaths.where((ProjectObject e) => !e.pinned).toList(),
        pinnedProjects:
            _projectsPaths.where((ProjectObject e) => e.pinned).toList(),
      );

      // Kill isolate
      _port.send(<dynamic>[_result, true, false]);
      return;
    }
  }
}

class ProjectIsolateFetchResult {
  final List<ProjectObject> pinnedProjects;
  final List<ProjectObject> projects;

  const ProjectIsolateFetchResult({
    required this.pinnedProjects,
    required this.projects,
  });
}

class ProjectCacheResult {
  final String? projectsPath;
  final int? refreshIntervals;
  final DateTime? lastProjectReload;
  final DateTime? lastWorkflowsReload;

  const ProjectCacheResult({
    required this.projectsPath,
    required this.refreshIntervals,
    required this.lastProjectReload,
    required this.lastWorkflowsReload,
  });

  factory ProjectCacheResult.fromJson(Map<String, dynamic> json) {
    return ProjectCacheResult(
      projectsPath: json['projectsPath']?.toString(),
      refreshIntervals: int.tryParse(json['refreshIntervals'] ?? ''),
      lastProjectReload: DateTime.tryParse(json['lastReload'] ?? ''),
      lastWorkflowsReload: DateTime.tryParse(json['lastWorkflowsReload'] ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'projectsPath': projectsPath,
      'refreshIntervals': refreshIntervals?.toString(),
      'lastReload': lastProjectReload?.toString(),
      'lastWorkflowsReload': lastWorkflowsReload?.toString(),
    };
  }
}
