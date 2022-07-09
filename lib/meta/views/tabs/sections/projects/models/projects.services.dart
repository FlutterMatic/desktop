// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

// 📦 Package imports:
import 'package:path_provider/path_provider.dart';

// 🌎 Project imports:
import 'package:fluttermatic/core/models/projects.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/search/projects_search.dart';

class ProjectServicesModel {
  /// Gets the cache about the projects information and about the projects path
  /// where they can be found.
  static Future<ProjectCacheResult?> getProjectCache(String supportDir) async {
    File file = File('$supportDir\\cache\\projects_cache_settings.json');

    if (!await file.exists()) {
      return null;
    }

    Map<String, dynamic> cache = jsonDecode((await file.readAsString()));

    return ProjectCacheResult.fromJson(cache);
  }

  /// Updates the cache with the new information.
  /// Provide the [ProjectCacheResult] and it will update the provided cache
  /// with the new information. If any attribute is null, it will not be
  /// updated, only the provided cache will be updated.
  static Future<void> updateProjectCache({
    required String supportDir,
    required ProjectCacheResult cache,
  }) async {
    File file = File('$supportDir\\cache\\projects_cache_settings.json');

    Map<String, dynamic> oldCache = <String, dynamic>{};

    // If the old cache exists, we will merge it with the new one.
    if (await file.exists()) {
      oldCache = jsonDecode((await file.readAsString()));
    }

    dynamic _getValue(String key) =>
        (oldCache.containsKey(key) ? oldCache[key] : null);

    ProjectCacheResult newCache = ProjectCacheResult(
      projectsPath: cache.projectsPath ?? _getValue('projectsPath'),
      refreshIntervals: cache.refreshIntervals ??
          int.tryParse(_getValue('refreshIntervals') ?? '1'),
      lastProjectReload: cache.lastProjectReload ??
          DateTime.tryParse(_getValue('lastReload') ?? ''),
      lastWorkflowsReload: cache.lastWorkflowsReload ??
          DateTime.tryParse(_getValue('lastWorkflowsReload') ?? ''),
    );

    await file.writeAsString(jsonEncode(newCache.toJson()));
  }

  /// Will update the cache for the projects locally and set the new pinned
  /// status for the provided project path.
  static Future<void> updateProjectPinStatus(String path, bool isPinned) async {
    try {
      Directory dir = await getApplicationSupportDirectory();

      // Gets the existing cache so that we can alter it with the new pinned
      // status.
      List<ProjectObject> cache =
          await ProjectSearchUtils.getProjectsFromCache(dir.path);

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

      List<Map<String, dynamic>> newCache = <Map<String, dynamic>>[];

      // Will find the project that matches the provided path and update the
      // pinned status.
      for (ProjectObject project in cache) {
        ProjectObject newProject = ProjectObject(
          name: project.name,
          modDate: project.modDate,
          path: project.path,
          description: project.description,
          pinned: project.path == path ? isPinned : project.pinned,
        );

        newCache.add(newProject.toJson());
      }

      // Now we will write the new cache to the file.
      await File(ProjectSearchUtils.getProjectCachePath(dir.path))
          .writeAsString(jsonEncode(newCache));
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
    SendPort port = data[0];
    String supportDir = data[1];
    bool force = data[2]; // Whether to force to refetch from scratch even if
    // we have cache that is not expired.

    if (await ProjectSearchUtils.hasCache(supportDir)) {
      await logger.file(
          LogTypeTag.info, 'Fetching projects from cache. Cache found.',
          logDir: Directory(supportDir));

      List<ProjectObject> projectsCache =
          await ProjectSearchUtils.getProjectsFromCache(supportDir);

      ProjectIsolateFetchResult result = ProjectIsolateFetchResult(
        projects: projectsCache.where((ProjectObject e) => !e.pinned).toList(),
        pinnedProjects:
            projectsCache.where((ProjectObject e) => e.pinned).toList(),
      );

      ProjectCacheResult? cache = await getProjectCache(supportDir);

      // Check to see if we need to refetch again because of time interval or cache
      // expired.
      if (cache != null) {
        // Cache expired. Will return the expired cache for performance, then will
        // refetch the cache in the background and update the listener with the
        // new cache if there is a difference to avoid unnecessary rebuilds.

        bool isExpiredCache = true;

        // Seconds Difference
        int difference = DateTime.now()
            .difference(cache.lastProjectReload ?? DateTime.now())
            .inSeconds;

        // Check to see if the cache is expired. Interval in minutes. Must be
        // in seconds.
        if (((cache.refreshIntervals ?? 0) * 60) > difference) {
          isExpiredCache = false;
        }

        if (isExpiredCache || force) {
          if (force) {
            await logger.file(LogTypeTag.info,
                'Fetching projects from cache. Cache expired. Force refetch.',
                logDir: Directory(supportDir));
          }

          await logger.file(
              LogTypeTag.info, 'Fetching projects from scratch. Cache expired.',
              logDir: Directory(supportDir));

          // Don't kill isolate. Will refetch with cache.
          port.send(<dynamic>[result, false, true]);

          List<ProjectObject> projectsRefetch =
              await ProjectSearchUtils.getProjectsFromPath(
            cache: cache,
            supportDir: supportDir,
          );

          // Update cache.
          await updateProjectCache(
            supportDir: supportDir,
            cache: ProjectCacheResult(
              projectsPath: null,
              refreshIntervals: null,
              lastProjectReload: DateTime.now(),
              lastWorkflowsReload: null,
            ),
          );

          ProjectIsolateFetchResult refetchResult = ProjectIsolateFetchResult(
            projects:
                projectsRefetch.where((ProjectObject e) => !e.pinned).toList(),
            pinnedProjects:
                projectsRefetch.where((ProjectObject e) => e.pinned).toList(),
          );

          // Kill isolate. Cache is now updated.
          port.send(<dynamic>[refetchResult, true, false]);
          return;
        } else {
          await logger.file(LogTypeTag.info,
              'Fetching projects from cache. Cache still valid.',
              logDir: Directory(supportDir));
          // Kill isolate. Cache is still valid.
          port.send(<dynamic>[result, true, false]);
          return;
        }
      } else {
        // Kill isolate.
        port.send(<dynamic>[result, true, false]);
        return;
      }
    } else {
      await logger.file(
          LogTypeTag.info, 'Fetching projects initially. No cache found.',
          logDir: Directory(supportDir));

      List<ProjectObject> projectsPaths =
          await ProjectSearchUtils.getProjectsFromPath(
        cache: await getProjectCache(supportDir) ??
            const ProjectCacheResult(
              lastProjectReload: null,
              projectsPath: null,
              refreshIntervals: null,
              lastWorkflowsReload: null,
            ),
        supportDir: supportDir,
      );

      ProjectIsolateFetchResult result = ProjectIsolateFetchResult(
        projects: projectsPaths.where((ProjectObject e) => !e.pinned).toList(),
        pinnedProjects:
            projectsPaths.where((ProjectObject e) => e.pinned).toList(),
      );

      // Kill isolate
      port.send(<dynamic>[result, true, false]);
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
