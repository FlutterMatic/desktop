// 🎯 Dart imports:
import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

// 📦 Package imports:
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/shared_pref.dart';
import 'package:fluttermatic/core/models/projects.dart';
import 'package:fluttermatic/core/notifiers/models/payloads/general/notifications.dart';
import 'package:fluttermatic/core/notifiers/models/state/actions/projects.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/general/extract_pubspec.dart';
import 'package:fluttermatic/meta/utils/general/shared_pref.dart';

class ProjectsNotifier extends StateNotifier<ProjectsState> {
  final Reader read;

  ProjectsNotifier(this.read) : super(ProjectsState.initial());

  // Variables
  static final List<ProjectObject> _pinned = [];
  static final List<ProjectObject> _flutter = [];
  static final List<ProjectObject> _dart = [];

  // Getters
  UnmodifiableListView<ProjectObject> get pinned =>
      UnmodifiableListView(_pinned);
  UnmodifiableListView<ProjectObject> get flutter =>
      UnmodifiableListView(_flutter);
  UnmodifiableListView<ProjectObject> get dart => UnmodifiableListView(_dart);

  /// Returns the path where the projects cache is stored or where it should
  /// be stored.
  static String getProjectCachePath(String applicationSupportDir) =>
      '$applicationSupportDir\\cache\\project_cache.json';

  /// Will return [true] if there is cache for the personal projects and [false]
  /// if there isn't.
  static Future<bool> hasCache(String supportDir) =>
      File(getProjectCachePath(supportDir)).exists();

  /// Gets the cache about the projects information and about the projects path
  /// where they can be found.
  static Future<ProjectCacheSettings?> getProjectSettings(
      String supportDir) async {
    File file = File('$supportDir\\cache\\projects_cache_settings.json');

    if (!await file.exists()) {
      return null;
    }

    Map<String, dynamic> cache = jsonDecode((await file.readAsString()));

    return ProjectCacheSettings.fromJson(cache);
  }

  /// Updates the cache with the new information.
  /// Provide the [ProjectCacheResult] and it will update the provided cache
  /// with the new information. If any attribute is null, it will not be
  /// updated, only the provided cache will be updated.
  static Future<void> updateProjectSettings(
      String supportDir, ProjectCacheSettings cache) async {
    File file = File('$supportDir\\cache\\projects_cache_settings.json');

    Map<String, dynamic> oldCache = <String, dynamic>{};

    // If the old cache exists, we will merge it with the new one.
    if (await file.exists()) {
      oldCache = jsonDecode((await file.readAsString()));
    }

    dynamic _getValue(String key) =>
        (oldCache.containsKey(key) ? oldCache[key] : null);

    ProjectCacheSettings newCache = ProjectCacheSettings(
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

  /// Sorts the projects passed in based on whether they are pinned, a Flutter
  /// project, or a dart project.
  ///
  /// It will scan each project's `pubspec.yaml` file to find the perfect
  /// category for it.
  Future<void> _sortProjects(List<ProjectObject> projects) async {
    // Sort the projects from pinned, flutter, and dart.
    _pinned.clear();
    _flutter.clear();
    _dart.clear();

    for (ProjectObject project in projects) {
      if (project.pinned) {
        _pinned.add(project);
        continue;
      }

      PubspecInfo pubspec = extractPubspec(
        lines: await File('${project.path}\\pubspec.yaml').readAsLines(),
        path: '${project.path}\\pubspec.yaml',
      );

      if (pubspec.isFlutterProject) {
        _flutter.add(project);
        continue;
      } else {
        _dart.add(project);
        continue;
      }
    }
  }

  /// Deletes the project based on the provided [projectPath]. This will also
  /// take care of updating the projects cache, and the projects state of the
  /// app.
  ///
  /// You can always know if deleting the project was successful or not by
  /// checking the [state.isError] after you call and await this method. If
  /// there was an error, then it means something went wrong.
  Future<void> deleteProject(String projectPath) async {
    try {
      state = state.copyWith(
        isError: false,
        isLoading: true,
      );

      String supportDir = (await getApplicationSupportDirectory()).path;

      await logger.file(LogTypeTag.info, 'Deleting project: $projectPath');

      await Directory(projectPath).delete(recursive: true);

      // Remove this project from the cache and also the current state.
      await getProjectsFromCache();

      // Check to see where the project is in, pinned, flutter, or dart
      // category.
      ProjectObject project =
          [..._pinned, ..._flutter, ..._dart].firstWhere((e) {
        return e.path == projectPath;
      });

      // It is in the pinned category.
      if (project.pinned) {
        _pinned.removeWhere((e) => e.path == projectPath);
      } else {
        PubspecInfo pubspecParsed = extractPubspec(
          lines: await File('$projectPath\\pubspec.yaml').readAsLines(),
          path: '$projectPath\\pubspec.yaml',
        );

        // Remove it from the Flutter category.
        if (pubspecParsed.isFlutterProject) {
          _flutter.removeWhere((e) => e.path == projectPath);
        } else {
          _dart.removeWhere((e) => e.path == projectPath);
        }
      }

      // Update the cache on locally to no longer include this project. This
      // can be done by just modifying the existing cache, without requesting
      // a re-scan of the projects.
      List<ProjectObject> projects = (jsonDecode(
        await File(getProjectCachePath(supportDir)).readAsString(),
      ) as List)
          .map(
        (e) {
          return ProjectObject.fromJson(e);
        },
      ).toList();

      projects.removeWhere((e) => e.path == projectPath);

      // Set the cache once again after modifying it.
      await File(getProjectCachePath(supportDir))
          .writeAsString(jsonEncode(projects));

      await read(notificationStateController.notifier).newNotification(
        NotificationObject(
          Timeline.now.toString(),
          title: 'Project Deleted',
          message:
              'Your project "${projectPath.split('\\').last}" has been deleted successfully.',
          onPressed: null,
        ),
      );

      state = state.copyWith(
        isError: false,
        isLoading: false,
      );

      return;
    } catch (_, s) {
      await logger.file(
        LogTypeTag.error,
        'Failed to delete project: $projectPath: $_',
        stackTraces: s,
      );

      state = state.copyWith(
        isError: true,
        isLoading: false,
      );

      return;
    }
  }

  /// Will update the cache for the projects locally and set the new pinned
  /// status for the provided project path. This will also take care of updating
  /// the state.
  Future<void> updatePinnedStatus(String projectPath, bool isPinned) async {
    try {
      state = state.copyWith(
        isLoading: true,
      );

      String supportDir = (await getApplicationSupportDirectory()).path;

      // Gets the existing cache so that we can alter it with the new pinned
      // status.
      await getProjectsFromCache();

      // Projects cache structure:
      // [
      //   {
      //    "name": "Project 1",
      //    ...
      //   },
      //   ...
      // ]

      List<Map<String, dynamic>> newCache = <Map<String, dynamic>>[];

      // Will find the project that matches the provided path and update the
      // pinned status.
      for (ProjectObject project in [..._pinned, ..._flutter, ..._dart]) {
        ProjectObject newProject = ProjectObject(
          name: project.name,
          modDate: project.modDate,
          path: project.path,
          description: project.description,
          pinned: project.path == projectPath ? isPinned : project.pinned,
        );

        newCache.add(newProject.toJson());
      }

      // Now we will write the new cache to the file.
      await File(getProjectCachePath(supportDir))
          .writeAsString(jsonEncode(newCache));

      // Reload the projects from the cache.
      await getProjectsFromCache();

      state = state.copyWith(
        isError: false,
        isLoading: false,
      );

      return;
    } catch (_, s) {
      state = state.copyWith(
        isError: true,
      );

      await logger.file(
        LogTypeTag.error,
        'Failed to update the pinned status for the project: $projectPath :$_',
        stackTraces: s,
      );

      return;
    }
  }

  /// Will get and set the projects getter to the returned value of cached
  /// projects locally.
  ///
  /// If this is called when there are no cached projects locally, a warning
  /// will be logged and returned projects will be an empty list.
  Future<void> getProjectsFromCache() async {
    String supportDir = (await getApplicationSupportDirectory()).path;

    try {
      state = state.copyWith(
        isError: false,
        isLoading: true,
      );

      if (await hasCache(supportDir)) {
        List<ProjectObject> projects = await _getProjectsFromCache(supportDir);

        await _sortProjects(projects);

        state = state.copyWith(
          isError: false,
          isLoading: false,
        );

        return;
      }

      await logger.file(
        LogTypeTag.warning,
        'Tried to get projects when the projects cache is not set. Should request to fetch in background as an initial fetch from path.',
        logDir: Directory(supportDir),
      );

      state = state.copyWith(
        isError: true,
        isLoading: false,
      );

      return;
    } catch (_, s) {
      await logger.file(
          LogTypeTag.error, 'Couldn\'t fetch from projects cache: $_',
          stackTraces: s);

      state = state.copyWith(
        isError: true,
        isLoading: false,
      );

      return;
    }
  }

  /// Gets all the project from the path stored in shared preferences.
  ///
  /// NOTE: This is a very performance impacting request and will freeze the
  /// screen if not handled correctly. Try isolating this function in a
  /// different thread.
  ///
  /// Avoid calling this function too many times as they could be a reason the
  /// user will delete this app because of performance issues. Use clever
  /// caching algorithms that self merge when new changes are found.
  Future<List<ProjectObject>> getProjectsFromPath() async {
    try {
      String supportDir = (await getApplicationSupportDirectory()).path;

      ProjectCacheSettings? settings = await getProjectSettings(supportDir);

      if (settings?.projectsPath != null) {
        // We will get the projects from cache so that we can keep the pinned
        // projects status alive.
        List<ProjectObject> cachedProjects =
            await _getProjectsFromCache(supportDir);

        List<ProjectObject> projects = <ProjectObject>[];

        // Gets all the files in the path
        List<FileSystemEntity> files = Directory.fromUri(
                Uri.file(settings!.projectsPath!))
            .listSync(recursive: true)
            .where((FileSystemEntity e) => e.path.endsWith('\\pubspec.yaml'))
            .toList();

        const List<String> skipNames = <String>[
          'ephemeral',
        ];

        // Adds to the projects list the parent path of the pubspec.yaml file
        for (FileSystemEntity file in files) {
          String parentName = file.parent.path.split('\\').last;

          bool skip = false;

          for (String name in file.path.split('\\')) {
            if (skipNames.contains(name)) {
              skip = true;
              break;
            }
          }

          if (skip) continue;

          // We will skip if this project is an example project for a project.
          if (parentName == 'example') {
            if (File('${file.parent.parent.path}\\pubspec.yaml').existsSync()) {
              continue;
            }
          }

          // Extracts the pubspec file so we can check its attributes
          PubspecInfo pubspec = extractPubspec(
              lines: await File(file.path).readAsLines(), path: file.path);

          // Make sure this project contains a valid pubspec.yaml for it to
          // be considered as a project which we will display.
          if (pubspec.isValid) {
            projects.add(ProjectObject(
              path: file.parent.path,
              name: parentName,
              description: pubspec.description,
              modDate: file.statSync().modified,
              // We will keep the pinned status alive by checking if the
              // project is in the cache and is pinned in the cache.
              pinned: cachedProjects.any(
                  (ProjectObject p) => p.path == file.parent.path && p.pinned),
            ));
          }
        }

        // Sets the cache for the projects locally on the system.
        await File(getProjectCachePath(supportDir)).writeAsString(
            jsonEncode(projects.map((_) => _.toJson()).toList()));

        // Updates the time the cache was updated so that we can refetch on
        // time intervals.
        await updateProjectSettings(
          supportDir,
          ProjectCacheSettings(
            projectsPath: null,
            refreshIntervals: null,
            lastProjectReload: DateTime.now(),
            lastWorkflowsReload: null,
          ),
        );

        return projects;
      }

      // The projects path to search was not set, so we will return an empty
      // list and log this warning.
      await logger.file(LogTypeTag.warning,
          'Tried to get projects when the projects directory is not set.',
          logDir: Directory(supportDir));

      return <ProjectObject>[];
    } catch (_, s) {
      await logger.file(
          LogTypeTag.error, 'Couldn\'t fetch projects from path: $_',
          stackTraces: s);

      return <ProjectObject>[];
    }
  }

  /// Will fetch the projects from either the cache or realtime. This depends on
  /// the [force] parameter. If it is set to true then it will fetch from
  /// realtime, if [force] is set to false then we will fetch from cache or
  /// realtime, whichever we think is suitable. It is recommend to set [force]
  /// to false whenever possible, as this will help with performance and it self
  /// manages and decides that it should consider [force] as true.
  ///
  /// Once returned, you should kill the isolate to prevent memory leaks and
  /// other issues.
  Future<void> getProjectsWithIsolate(bool force) async {
    state = state.copyWith(
      isError: false,
      isLoading: true,
    );

    try {
      if (SharedPref().pref.containsKey(SPConst.projectsPath)) {
        await updateProjectSettings(
          (await getApplicationSupportDirectory()).path,
          ProjectCacheSettings(
            projectsPath: SharedPref().pref.getString(SPConst.projectsPath),
            refreshIntervals: null,
            lastProjectReload: null,
            lastWorkflowsReload: null,
          ),
        );

        await logger.file(
            LogTypeTag.info, 'Beginning projects fetch with isolate.');

        List<ProjectObject> projects =
            await _getProjectsWithIsolateFromRaw(force);

        await _sortProjects(projects);
      }
    } catch (_, s) {
      await logger.file(
        LogTypeTag.error,
        'Couldn\'t fetch projects with isolate. Error: $_',
        stackTraces: s,
      );

      state = state.copyWith(
        isError: true,
        isLoading: false,
      );

      return;
    }
  }
}

Future<List<ProjectObject>> _getProjectsFromCache(String supportDir) async {
  return [];
}

/// Will fetch the projects from either the cache or realtime. This depends on
/// the [force] parameter. If it is set to true then it will fetch from
/// realtime, if [force] is set to false then we will fetch from cache or
/// realtime, whichever we think is suitable. It is recommend to set [force]
/// to false whenever possible, as this will help with performance and it self
/// manages and decides that it should consider [force] as true.
///
/// Once returned, you should kill the isolate to prevent memory leaks and
/// other issues.
Future<List<ProjectObject>> _getProjectsWithIsolateFromRaw(bool force) async {
  try {
    Future<List<ProjectObject>> perform(Map<String, dynamic> data) async {
      SendPort sendPort = data['sendPort'];
      String supportDir = data['supportDir'];
      String? projectsPath = data['projectsPath'];

      Future<List<ProjectObject>> forceFetch() async {
        if (projectsPath == null) {
          return [];
        }

        await logger.file(
          LogTypeTag.info,
          'Fetching projects from path. Forced request.',
          logDir: Directory(supportDir),
        );

        List<ProjectObject> newProjects = <ProjectObject>[];

        // Gets all the files in the path
        List<FileSystemEntity> files = Directory.fromUri(Uri.file(projectsPath))
            .listSync(recursive: true)
            .where((FileSystemEntity e) => e.path.endsWith('\\pubspec.yaml'))
            .toList();

        const List<String> skipNames = <String>[
          'ephemeral',
        ];

        List<ProjectObject> projectsFromCache =
            await _getProjectsFromCache(supportDir);

        // Adds to the projects list the parent path of the pubspec.yaml file
        for (FileSystemEntity file in files) {
          String parentName = file.parent.path.split('\\').last;

          bool skip = false;

          for (String name in file.path.split('\\')) {
            if (skipNames.contains(name)) {
              skip = true;
              break;
            }
          }

          if (skip) {
            continue;
          }

          // We will skip if this project is an example project for a project.
          if (parentName == 'example') {
            if (File('${file.parent.parent.path}\\pubspec.yaml').existsSync()) {
              continue;
            }
          }

          // Extracts the pubspec file so we can check its attributes
          PubspecInfo pubspec = extractPubspec(
              lines: await File(file.path).readAsLines(), path: file.path);

          // Make sure this project contains a valid pubspec.yaml for it to
          // be considered as a project which we will display.
          if (pubspec.isValid) {
            newProjects.add(ProjectObject(
              path: file.parent.path,
              name: parentName,
              description: pubspec.description,
              modDate: file.statSync().modified,
              // We will keep the pinned status alive by checking if the
              // project is in the cache and is pinned in the cache.
              pinned: projectsFromCache.any(
                  (ProjectObject p) => p.path == file.parent.path && p.pinned),
            ));
          }
        }

        // Sets the cache for the projects locally on the system.
        await File(ProjectsNotifier.getProjectCachePath(supportDir))
            .writeAsString(
                jsonEncode(newProjects.map((_) => _.toJson()).toList()));

        // Updates the time the cache was updated so that we can refetch on
        // time intervals.
        await ProjectsNotifier.updateProjectSettings(
          supportDir,
          ProjectCacheSettings(
            projectsPath: null,
            refreshIntervals: null,
            lastProjectReload: DateTime.now(),
            lastWorkflowsReload: null,
          ),
        );

        Isolate.exit(sendPort, newProjects);
      }

      try {
        if (force) {
          Isolate.exit(sendPort, forceFetch());
        }

        // This was not a forced request, so we will check if we should fetch from
        // cache or fetch again.
        if (await ProjectsNotifier.hasCache(supportDir)) {
          // Cache exists, check the last time we rawly fetched.
          ProjectCacheSettings? settings =
              await ProjectsNotifier.getProjectSettings(supportDir);

          // Check to see if we need to refetch again because of time
          // interval or cache expired.
          if (settings != null) {
            // Cache expired. Will return the expired cache for performance,
            // then will refetch the cache in the background and update the
            // listener with the new cache if there is a difference to avoid
            // unnecessary rebuilds.
            bool isExpiredCache = true;

            // Seconds Difference
            int difference = DateTime.now()
                .difference(settings.lastProjectReload ?? DateTime.now())
                .inSeconds;

            // Check to see if the cache is expired. Interval in minutes.
            // Must be in seconds.
            if (((settings.refreshIntervals ?? 0) * 60) > difference) {
              isExpiredCache = false;
            }

            if (isExpiredCache) {
              await logger.file(
                LogTypeTag.info,
                'Fetching projects from scratch. Cache expired.',
                logDir: Directory(supportDir),
              );

              Isolate.exit(sendPort, forceFetch());
            }

            // Cache is not expired yet, so we will fetch from cache.
            List<ProjectObject> projectsFromCache =
                await _getProjectsFromCache(supportDir);

            Isolate.exit(sendPort, projectsFromCache);
          }
        }

        await logger.file(
          LogTypeTag.info,
          'Initial fetch of projects from scratch. Cache or settings does not exist.',
          logDir: Directory(supportDir),
        );

        Isolate.exit(sendPort, forceFetch());
      } catch (_, s) {
        await logger.file(
          LogTypeTag.error,
          'Failed to run projects fetch on isolate. Error: $_',
          stackTraces: s,
        );

        Isolate.exit(sendPort, forceFetch());
      }
    }

    String supportDir = (await getApplicationSupportDirectory()).path;

    ReceivePort receivePort = ReceivePort();

    await Isolate.spawn(
      perform,
      {
        'sendPort': receivePort.sendPort,
        'supportDir': supportDir,
        'projectsPath': (await ProjectsNotifier.getProjectSettings(supportDir))
            ?.projectsPath,
      },
    );

    List<ProjectObject> projects =
        (await receivePort.first) as List<ProjectObject>;

    return projects;
  } catch (_, s) {
    await logger.file(
      LogTypeTag.error,
      'Couldn\'t fetch projects with isolate. Error: $_',
      stackTraces: s,
    );

    return [];
  }
}

class ProjectCacheSettings {
  final String? projectsPath;
  final int? refreshIntervals;
  final DateTime? lastProjectReload;
  final DateTime? lastWorkflowsReload;

  const ProjectCacheSettings({
    required this.projectsPath,
    required this.refreshIntervals,
    required this.lastProjectReload,
    required this.lastWorkflowsReload,
  });

  factory ProjectCacheSettings.fromJson(Map<String, dynamic> json) {
    return ProjectCacheSettings(
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
