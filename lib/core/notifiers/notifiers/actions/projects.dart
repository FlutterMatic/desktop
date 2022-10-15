// 🎯 Dart imports:
import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:isolate';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/shared_pref.dart';
import 'package:fluttermatic/components/dialog_templates/project/create/add_dependencies.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/core/models/projects.dart';
import 'package:fluttermatic/core/notifiers/models/payloads/general/notifications.dart';
import 'package:fluttermatic/core/notifiers/models/state/actions/projects.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/general/extract_pubspec.dart';
import 'package:fluttermatic/meta/utils/general/shared_pref.dart';

class ProjectsNotifier extends StateNotifier<ProjectsState> {
  final Ref ref;

  ProjectsNotifier(this.ref) : super(ProjectsState.initial());

  // Variables
  static final List<ProjectObject> _projects = [
    ..._pinned,
    ..._flutter,
    ..._dart,
  ];
  static final List<ProjectObject> _pinned = [];
  static final List<ProjectObject> _flutter = [];
  static final List<ProjectObject> _dart = [];

  // Getters
  UnmodifiableListView<ProjectObject> get projects =>
      UnmodifiableListView(_projects);
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

    dynamic getValue(String key) =>
        (oldCache.containsKey(key) ? oldCache[key] : null);

    ProjectCacheSettings newCache = ProjectCacheSettings(
      projectsPath: cache.projectsPath ?? getValue('projectsPath'),
      refreshIntervals: cache.refreshIntervals ??
          int.tryParse(getValue('refreshIntervals') ?? '1'),
      lastProjectReload: cache.lastProjectReload ??
          DateTime.tryParse(getValue('lastReload') ?? ''),
      lastWorkflowsReload: cache.lastWorkflowsReload ??
          DateTime.tryParse(getValue('lastWorkflowsReload') ?? ''),
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
      // Make sure that the project exists (it might have been loaded from
      // cache).
      if (!await Directory(project.path).exists()) {
        continue;
      }

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
      } else {
        _dart.add(project);
      }

      continue;
    }
  }

  /// Inject a project into the state. Useful when the user creates a new
  /// project in the app and you want to add the project without having to
  /// reload the projects.
  ///
  /// It will sort the projects and then notify the listeners. Will
  /// automatically update the cache and handle sorting it to the right place.
  Future<void> addProject(PubspecInfo pubspecInfo) async {
    try {
      state = state.copyWith(
        loading: true,
        error: false,
      );

      /// Before adding it, we need to make sure that this project is within
      /// the scope of the projects path. If it outside then we will not add
      /// it.
      ProjectCacheSettings? cache = await getProjectSettings(
        (await getApplicationSupportDirectory()).path,
      );

      if (cache == null) {
        await logger.file(LogTypeTag.warning, 'No cache found for projects.');

        state = state.copyWith(
          loading: false,
          error: false,
        );

        return;
      }

      if (pubspecInfo.pathToPubspec == null ||
          !pubspecInfo.pathToPubspec!.startsWith(cache.projectsPath!)) {
        await logger.file(
          LogTypeTag.warning,
          'The project ${pubspecInfo.pathToPubspec} is not within the scope of the projects path ${cache.projectsPath}.',
        );

        state = state.copyWith(
          loading: false,
          error: false,
        );

        return;
      }

      ProjectObject newProject = ProjectObject(
        name: pubspecInfo.name ?? pubspecInfo.pathToPubspec!,
        pinned: false,
        description: pubspecInfo.description,
        modDate: File(pubspecInfo.pathToPubspec!).lastModifiedSync(),
        // Remove from the path the pubspec.yaml file. Only parent path.
        path: (pubspecInfo.pathToPubspec!.split('\\')..removeLast()).join('\\'),
      );

      // Add the project to the list based on which category it is in.
      if (pubspecInfo.isFlutterProject) {
        _flutter.add(newProject);
      } else {
        _dart.add(newProject);
      }

      // Add the project to the cache in the system so we can reload it next
      // time.
      List<Map<String, dynamic>> newCache =
          _projects.map((e) => e.toJson()).toList();

      // Add the new project.
      newCache.add(newProject.toJson());

      String supportDir = (await getApplicationSupportDirectory()).path;

      // Now we will write the new cache to the file.
      await File(getProjectCachePath(supportDir))
          .writeAsString(jsonEncode(newCache));

      state = state.copyWith(
        loading: false,
        error: false,
      );
    } catch (e, s) {
      await logger.file(LogTypeTag.error,
          'Something went wrong when trying to add a project individually.',
          error: e, stackTrace: s);

      state = state.copyWith(
        loading: false,
        error: false,
      );

      return;
    }
  }

  /// Deletes the project based on the provided [projectPath]. This will also
  /// take care of updating the projects cache, and the projects state of the
  /// app.
  ///
  /// You can always know if deleting the project was successful or not by
  /// checking the [state.error] after you call and await this method. If
  /// there was an error, then it means something went wrong.
  Future<void> deleteProject(String projectPath) async {
    try {
      state = state.copyWith(
        error: false,
        loading: true,
      );

      String supportDir = (await getApplicationSupportDirectory()).path;

      await logger.file(LogTypeTag.info, 'Deleting project: $projectPath');

      await Directory(projectPath).delete(recursive: true);

      // Check to see where the project is in, pinned, flutter, or dart
      // category.
      ProjectObject project =
          _projects.firstWhere((e) => e.path == projectPath);

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
                  await File(getProjectCachePath(supportDir)).readAsString())
              as List)
          // ignore: unnecessary_lambdas
          .map((dynamic e) => ProjectObject.fromJson(e))
          .toList();

      projects.removeWhere((e) => e.path == projectPath);

      // Set the cache once again after modifying it.
      await File(getProjectCachePath(supportDir))
          .writeAsString(jsonEncode(projects));

      await ref.watch(notificationStateController.notifier).newNotification(
            NotificationObject(
              Timeline.now,
              title: 'Project Deleted',
              message:
                  'Your project "${projectPath.split('\\').last}" has been deleted successfully.',
              onPressed: null,
            ),
          );

      state = state.copyWith(
        error: false,
        loading: false,
      );

      return;
    } catch (e, s) {
      await logger.file(
          LogTypeTag.error, 'Failed to delete project: $projectPath.',
          error: e, stackTrace: s);

      state = state.copyWith(
        error: true,
        loading: false,
      );

      return;
    }
  }

  static const Duration _pubCommandDuration = Duration(seconds: 10);

  /// Updates the project with the new project info appended by the user. This
  /// is done by modifying the `pubspec.yaml` file or any other necessary
  /// resources.
  ///
  /// The current state will also be updated with the new updated info. This
  /// handles state changes for you automatically.
  ///
  /// Errors and loading states will also be taken care of.
  Future<void> updateProjectInfo(
    BuildContext context, {
    required String projectPath,
    required String projectName,
    required String projectDescription,
    required List<String> dependencies,
    required List<String> devDependencies,
    required PubspecInfo pubspecInfo,
  }) async {
    try {
      /// Will compare the old list and new list. Will return a map of this
      /// structure:
      ///
      /// {
      ///   'added': [...],
      ///   'removed': [...],
      /// }
      ///
      /// Will return the list of added elements and a different list of
      /// removed elements.
      ///
      /// If nothing changed in between both lists, then empty lists will be
      /// returned.
      Map<String, List<String>> getDifference(
          List<String> oldList, List<String> newList) {
        List<String> added = [];
        List<String> removed = [];

        for (String element in newList) {
          if (!oldList.contains(element)) {
            added.add(element);
          }
        }

        for (String element in oldList) {
          if (!newList.contains(element)) {
            removed.add(element);
          }
        }

        return {
          'added': added,
          'removed': removed,
        };
      }

      if (projectName.isEmpty) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(snackBarTile(
          context,
          'Please provide a project name.',
          type: SnackBarType.error,
        ));

        return;
      }

      if (projectDescription.isEmpty) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(snackBarTile(
          context,
          'Please provide a project description.',
          type: SnackBarType.error,
        ));

        return;
      }

      state = state.copyWith(
        loading: true,
        error: false,
        currentActivity: '',
      );

      List<String> oldDependencies = extractPubspec(
              lines: await File('$projectPath\\pubspec.yaml').readAsLines(),
              path: projectPath)
          .dependencies
          .map((e) => e.name)
          .toList();

      List<String> oldDevDependencies = extractPubspec(
              lines: await File('$projectPath\\pubspec.yaml').readAsLines(),
              path: projectPath)
          .devDependencies
          .map((e) => e.name)
          .toList();

      List<String> addedDependencies =
          getDifference(oldDependencies, dependencies)['added'] ?? [];

      List<String> removedDependencies =
          getDifference(oldDependencies, dependencies)['removed'] ?? [];

      List<String> addedDevDependencies =
          getDifference(oldDevDependencies, devDependencies)['added'] ?? [];

      List<String> removedDevDependencies =
          getDifference(oldDevDependencies, devDependencies)['removed'] ?? [];

      // We will add each dependency to the pubspec.yaml file
      for (String dependency in addedDependencies) {
        state = state.copyWith(
          currentActivity: 'Adding dependency $dependency...',
        );

        try {
          await addDependencyToProject(
            path: projectPath,
            dependency: dependency,
            isDev: false,
            isDart: !pubspecInfo.isFlutterProject,
          ).timeout(_pubCommandDuration);
        } catch (_) {} // Ignore...
      }

      for (String dependency in addedDevDependencies) {
        state = state.copyWith(
          currentActivity: 'Adding dev dependency $dependency...',
        );

        try {
          await addDependencyToProject(
            path: projectPath,
            dependency: dependency,
            isDev: true,
            isDart: !pubspecInfo.isFlutterProject,
          ).timeout(_pubCommandDuration);
        } catch (_) {} // Ignore...
      }

      // We will remove all the dependencies that are not in the list of
      // dependencies or dev dependencies.
      for (String dependency in removedDependencies) {
        bool exists = false;

        for (String dependency2 in dependencies) {
          if (dependency2 == dependency) {
            exists = true;
            break;
          }
        }

        if (!exists) {
          state = state.copyWith(
            currentActivity: 'Removing dependency $dependency...',
          );

          try {
            await addDependencyToProject(
              path: projectPath,
              dependency: dependency,
              isDev: false,
              isDart: !pubspecInfo.isFlutterProject,
              remove: true,
            ).timeout(_pubCommandDuration);
          } catch (_) {} // Ignore...
        }
      }

      for (String dependency in removedDevDependencies) {
        bool exists = false;

        for (String dependency2 in devDependencies) {
          if (dependency2 == dependency) {
            exists = true;
            break;
          }
        }

        if (!exists) {
          state = state.copyWith(
            currentActivity: 'Removing dev dependency $dependency...',
          );

          try {
            await addDependencyToProject(
              path: projectPath,
              dependency: dependency,
              isDev: false,
              isDart: !pubspecInfo.isFlutterProject,
              remove: true,
            ).timeout(_pubCommandDuration);
          } catch (_) {} // Ignore...
        }
      }

      // We will update the pubspec.yaml file with the new name and description
      state = state.copyWith(
        currentActivity: 'Updating pubspec.yaml...',
      );

      List<String> pubspecLines =
          await File('$projectPath\\pubspec.yaml').readAsLines();

      bool addedName = false;
      bool addedDescription = false;

      // We will update the name and description
      for (int i = 0; i < pubspecLines.length; i++) {
        if (pubspecLines[i].startsWith('name: ')) {
          pubspecLines[i] = 'name: $projectName';
          addedName = true;
        } else if (pubspecLines[i].startsWith('description: ')) {
          pubspecLines[i] = 'description: $projectDescription';
          addedDescription = true;
        }

        if (addedName && addedDescription) {
          break;
        }
      }

      // We will now write the new pubspec.yaml file
      await File('$projectPath\\pubspec.yaml')
          .writeAsString(pubspecLines.join('\n'));

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(snackBarTile(
          context,
          'Updated your project information.',
          type: SnackBarType.done,
        ));
      }

      // Update the state with the new project information by replacing the
      // old project with the new one.
      int pinnedIndex = _pinned.indexWhere((e) => e.path == projectPath);
      int flutterIndex = _flutter.indexWhere((e) => e.path == projectPath);
      int dartIndex = _dart.indexWhere((e) => e.path == projectPath);

      if (pinnedIndex != -1) {
        _pinned.removeAt(pinnedIndex);
        _pinned.insert(
          pinnedIndex,
          ProjectObject(
            path: projectPath,
            name: projectName,
            description: projectDescription,
            modDate: DateTime.now(),
            pinned: true,
          ),
        );
      } else if (flutterIndex != -1) {
        _flutter.removeAt(flutterIndex);
        _flutter.insert(
          flutterIndex,
          ProjectObject(
            path: projectPath,
            name: projectName,
            description: projectDescription,
            modDate: DateTime.now(),
            pinned: false,
          ),
        );
      } else if (dartIndex != -1) {
        _dart.removeAt(dartIndex);
        _dart.insert(
          dartIndex,
          ProjectObject(
            path: projectPath,
            name: projectName,
            description: projectDescription,
            modDate: DateTime.now(),
            pinned: false,
          ),
        );
      }

      state = state.copyWith(
        loading: false,
        error: false,
        currentActivity: '',
      );

      return;
    } catch (e, s) {
      await logger.file(LogTypeTag.error, 'Failed to save project changes.',
          error: e, stackTrace: s);

      state = state.copyWith(
        loading: false,
        error: true,
        currentActivity: '',
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
        loading: true,
        error: false,
      );

      // Remove the project from it's current position and add it to the
      // pinned or flutter/dart category.
      ProjectObject project =
          _projects.firstWhere((e) => e.path == projectPath);

      PubspecInfo pubspecParsed = extractPubspec(
        lines: await File('$projectPath\\pubspec.yaml').readAsLines(),
        path: '$projectPath\\pubspec.yaml',
      );

      // Remove the project from it's current position and add it to either
      // pinned or flutter/dart list.
      if (isPinned) {
        if (pubspecParsed.isFlutterProject) {
          _flutter.removeWhere((e) => e.path == projectPath);
        } else {
          _dart.removeWhere((e) => e.path == projectPath);
        }

        _pinned.add(project.copyWith(
          pinned: true,
        ));
      } else {
        _pinned.removeWhere((e) => e.path == projectPath);

        if (pubspecParsed.isFlutterProject) {
          _flutter.add(project.copyWith(
            pinned: false,
          ));
        } else {
          _dart.add(project.copyWith(
            pinned: false,
          ));
        }
      }

      // We will now update the cache with the new pinned state so that when
      // the projects view reloads, we reload the correct pinned state.

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
      for (ProjectObject project in _projects) {
        ProjectObject newProject = ProjectObject(
          name: project.name,
          modDate: project.modDate,
          path: project.path,
          description: project.description,
          pinned: project.path == projectPath ? isPinned : project.pinned,
        );

        newCache.add(newProject.toJson());
      }

      String supportDir = (await getApplicationSupportDirectory()).path;

      // Now we will write the new cache to the file.
      await File(getProjectCachePath(supportDir))
          .writeAsString(jsonEncode(newCache));

      state = state.copyWith(
        error: false,
        loading: false,
      );

      return;
    } catch (e, s) {
      state = state.copyWith(
        error: true,
        loading: false,
      );

      await logger.file(LogTypeTag.error,
          'Failed to update the pinned status for the project: $projectPath.',
          error: e, stackTrace: s);

      return;
    }
  }

  /// Will fetch the projects from either the cache or realtime. This depends
  /// on the [force] parameter. If it is set to true then it will fetch from
  /// realtime, if [force] is set to false then we will fetch from cache or
  /// realtime, whichever we think is suitable.
  ///
  /// It is recommend to set [force] to false whenever possible, as this will
  /// help with performance and it self manages and decides that it should
  /// consider [force] as true.
  ///
  /// This will use an isolate in the background to fetch the projects from
  /// the file system. This will also update the state with the new projects.
  /// This is resource intensive to call at times with larger scopes of project
  /// search paths. It is recommended to use [force] as false whenever possible.
  Future<void> getProjects(bool force) async {
    try {
      // If already loading then ignore this request because it could've been
      // called multiple causing multiple isolates to be released and multiple
      // copies of the same projects shown.
      //
      // Merging projects and automatically removing duplicates isn't supported
      // yet.
      if (state.loading) {
        await logger.file(LogTypeTag.warning,
            'Tried to fetch projects when already loading state in the notifier.');

        return;
      }

      state = state.copyWith(
        error: false,
        loading: true,
      );

      String supportDir = (await getApplicationSupportDirectory()).path;

      // Load a temporarily UI view, and if we decide to reload all projects
      // (re-index), we can do that in the background while displaying the last
      // known indexes.
      //
      // Thats why we should check if a project exists before doing anything
      // else, it might have existed from a previous session's cache.
      //
      // If were given a force request, we don't need to load a temporary cache
      // preview.
      if (await hasCache(supportDir) && !force) {
        try {
          List<ProjectObject> projects =
              await _getProjectsFromCacheRaw(supportDir);

          await _sortProjects(projects);

          await logger.file(
            LogTypeTag.info,
            'Loaded temporary projects from cache of size: ${projects.length}',
            logDir: Directory(supportDir),
          );
        } catch (e, s) {
          await logger.file(LogTypeTag.error,
              'Failed to load temporary UI projects from cache. Error: $e',
              stackTrace: s);
        }
      }

      if (SharedPref().pref.containsKey(SPConst.projectsPath)) {
        await updateProjectSettings(
          supportDir,
          ProjectCacheSettings(
            projectsPath: SharedPref().pref.getString(SPConst.projectsPath),
            refreshIntervals: null,
            lastProjectReload: null,
            lastWorkflowsReload: null,
          ),
        );

        List<ProjectObject> projects = [];

        ProjectCacheSettings? settings = await getProjectSettings(supportDir);

        Duration expirationDuration =
            Duration(seconds: settings?.refreshIntervals ?? 0);

        DateTime lastFetch = settings?.lastProjectReload ?? DateTime.now();

        bool hasExpired = settings?.refreshIntervals != -1 &&
            DateTime.now().difference(lastFetch) > expirationDuration;

        if (force || hasExpired) {
          await logger.file(
              LogTypeTag.info, 'Beginning projects fetch with isolate.');

          projects.addAll(await _getProjectsWithIsolateFromRaw(force));
        }

        if (projects.isNotEmpty && _projects.isEmpty) {
          await _sortProjects(projects);

          await logger.file(
            LogTypeTag.info,
            'Loaded ${_projects.length} project(s) with isolate using ${force ? 'realtime' : 'cache'}.',
          );
        }
      } else {
        await logger.file(LogTypeTag.warning,
            'Tried to load projects with isolate when no projects path has been set.');
      }

      state = state.copyWith(
        error: false,
        loading: false,
        initialized: true,
      );

      return;
    } catch (e, s) {
      await logger.file(LogTypeTag.error,
          'Couldn\'t fetch projects with isolate. No projects loaded.',
          error: e, stackTrace: s);

      state = state.copyWith(
        error: true,
        loading: false,
        initialized: false,
      );

      return;
    }
  }
}

Future<List<ProjectObject>> _getProjectsFromCacheRaw(String supportDir) async {
  try {
    String cachePath = ProjectsNotifier.getProjectCachePath(supportDir);

    if (await File(cachePath).exists()) {
      List<ProjectObject> projects = <ProjectObject>[];

      List<Map<String, dynamic>> raw =
          (jsonDecode(await File(cachePath).readAsString()) as List)
              .cast<Map<String, dynamic>>();

      for (Map<String, dynamic> project in raw) {
        try {
          projects.add(ProjectObject.fromJson(project));
        } catch (e, s) {
          await logger.file(LogTypeTag.error, 'Failed to parse cache project.',
              error: e, stackTrace: s, logDir: Directory(supportDir));
        }
      }

      await logger.file(
          LogTypeTag.info, 'Loaded ${projects.length} projects from cache.',
          logDir: Directory(supportDir));

      return projects;
    }

    return [];
  } catch (e, s) {
    await logger.file(LogTypeTag.error, 'Couldn\'t get projects from cache.',
        error: e, stackTrace: s, logDir: Directory(supportDir));

    return [];
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
Future<List<ProjectObject>> _getProjectsWithIsolateFromRaw(bool force) async {
  try {
    Future<List<ProjectObject>> performForce(Map<String, dynamic> data) async {
      SendPort sendPort = data['sendPort'];
      String supportDir = data['supportDir'];
      String? projectsPath = data['projectsPath'];

      Future<List<ProjectObject>> forceFetch() async {
        if (projectsPath == null) {
          return [];
        }

        await logger.file(
            LogTypeTag.info, 'Fetching projects from path. Forced request.',
            logDir: Directory(supportDir));

        List<ProjectObject> newProjects = <ProjectObject>[];

        // Gets all the files in the path
        List<FileSystemEntity> files = Directory(projectsPath)
            .listSync(recursive: true)
            .where((FileSystemEntity e) => e.path.endsWith('\\pubspec.yaml'))
            .toList();

        const List<String> skipNames = <String>[
          // Linux
          'linux\\flutter\\ephemeral',
          'linux/flutter/ephemeral',

          // Macos
          'macos\\Flutter\\ephemeral',
          'macos/Flutter/ephemeral',

          // Windows
          'windows\\flutter\\ephemeral',
          'windows/flutter/ephemeral',
        ];

        List<ProjectObject> projectsFromCache =
            await _getProjectsFromCacheRaw(supportDir);

        // Adds to the projects list the parent path of the pubspec.yaml file
        for (FileSystemEntity file in files) {
          String parentName = file.parent.path.split('\\').last;

          bool skip = false;

          for (String path in skipNames) {
            if (file.path.contains(path)) {
              skip = true;
              break;
            }
          }

          if (skip) {
            continue;
          }

          // We will skip if this project is an example project for a project.
          if (parentName == 'example') {
            bool hasParent =
                await File('${file.parent.parent.path}\\pubspec.yaml').exists();

            if (hasParent) {
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
              pinned: projectsFromCache
                  .any((p) => p.path == file.parent.path && p.pinned),
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
          List<ProjectObject> forcedProjects = await forceFetch();
          Isolate.exit(sendPort, forcedProjects);
        }

        // This was not a forced request, so we will check if we should fetch
        // from cache or fetch again.
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
            if (settings.refreshIntervals != -1 &&
                ((settings.refreshIntervals ?? 0) * 60) > difference) {
              isExpiredCache = false;
            }

            if (isExpiredCache) {
              await logger.file(
                LogTypeTag.info,
                'Fetching projects from scratch. Cache expired.',
                logDir: Directory(supportDir),
              );

              List<ProjectObject> forcedProjects = await forceFetch();
              Isolate.exit(sendPort, forcedProjects);
            }

            // Cache is not expired yet, so we will fetch from cache.
            List<ProjectObject> projectsFromCache =
                await _getProjectsFromCacheRaw(supportDir);

            Isolate.exit(sendPort, projectsFromCache);
          }
        }

        await logger.file(
          LogTypeTag.info,
          'Initial fetch of projects from scratch. Cache or settings does not exist.',
          logDir: Directory(supportDir),
        );

        List<ProjectObject> forcedProjects = await forceFetch();
        Isolate.exit(sendPort, forcedProjects);
      } catch (e, s) {
        await logger.file(
            LogTypeTag.error, 'Failed to run projects fetch on isolate.',
            error: e, stackTrace: s, logDir: Directory(supportDir));

        List<ProjectObject> forcedProjects = await forceFetch();
        Isolate.exit(sendPort, forcedProjects);
      }
    }

    String supportDir = (await getApplicationSupportDirectory()).path;

    ReceivePort receivePort = ReceivePort();

    await Isolate.spawn(
      performForce,
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
  } catch (e, s) {
    await logger.file(
        LogTypeTag.error, 'Couldn\'t fetch projects with isolate.',
        error: e, stackTrace: s);

    rethrow;
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
