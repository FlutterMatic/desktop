// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/core/models/projects.model.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/bin/utils/projects.search.dart';
import 'package:fluttermatic/meta/views/tabs/sections/projects/models/projects.services.dart';
import 'package:fluttermatic/meta/views/workflows/models/workflow.dart';

class WorkflowSearchUtils {
  /// Returns the path where the workflow cache is stored or where it should
  /// be stored.
  static String getWorkflowCachePath(String applicationSupportDir) =>
      applicationSupportDir + '\\cache\\workflow_cache.json';

  /// Will return [true] if there is cache for the workflows and [false] if
  /// there isn't.
  static Future<bool> hasCache(String supportDir) async =>
      File(getWorkflowCachePath(supportDir)).exists();

  /// Will get all the workflows in a specific project. Will return a list of
  /// [WorkflowTemplate] objects.
  static Future<List<WorkflowTemplate>> getWorkflowFromProject(
      String path) async {
    Directory _path = Directory(path + '\\$fmWorkflowDir');

    if (await _path.exists()) {
      // Will list all the files in the directory.
      List<FileSystemEntity> _files = _path.listSync();

      List<WorkflowTemplate> _workflows = <WorkflowTemplate>[];

      // Will loop through all the files and check if the file is a workflow
      // and try to parse it.
      for (FileSystemEntity file in _files) {
        if (file is File && file.path.endsWith('.json')) {
          try {
            // Will parse the file and return the workflow.
            _workflows.add(WorkflowTemplate.fromJson(
                jsonDecode(await File(file.path).readAsString())));
          } catch (_, s) {
            await logger.file(LogTypeTag.warning,
                'Failed to parse a workflow. Ignoring file: $_',
                stackTraces: s);
          }
        }
      }

      return _workflows;
    } else {
      return <WorkflowTemplate>[];
    }
  }

  /// Gets all the workflows from the path stored in shared preferences.
  ///
  /// NOTE: This is a very performance impacting request and will freeze the
  /// screen if not handled correctly. Try isolating this function in a
  /// different thread.
  ///
  /// Avoid calling this function too many times as they could be a reason the
  /// user will delete this app because of performance issues. Use clever
  /// caching algorithms that self merge when new changes are found.
  static Future<List<ProjectWorkflowsGrouped>> getWorkflowsFromPath({
    required ProjectCacheResult cache,
    required String supportDir,
  }) async {
    try {
      // The projects path must not be null. We will fetch the workflows from
      // the projects path that is set. So this depends on the projects path
      // being set, meaning that if it is not set, then the projects feature
      // should not work as well as the workflows feature. Workflows feature
      // should only work if the projects feature is working.
      if (cache.projectsPath != null) {
        List<ProjectObject> _projectsRefetch =
            await ProjectSearchUtils.getProjectsFromPath(
                cache: cache, supportDir: supportDir);

        // Each project will have its own list of workflows. They are
        // automatically sorted for the user.
        List<String> _paths = <String>[];
        List<List<WorkflowTemplate>> _workflows = <List<WorkflowTemplate>>[];

        // Will loop through all the projects and get the workflows to parse
        // and sort.
        for (ProjectObject project in _projectsRefetch) {
          List<WorkflowTemplate> _projectWorkflows =
              await getWorkflowFromProject(project.path);

          if (_projectWorkflows.isNotEmpty) {
            _paths.add(project.path);
            _workflows.add(_projectWorkflows);
          }
        }

        List<Map<String, List<Map<String, dynamic>>>> _workflowsSave =
            <Map<String, List<Map<String, dynamic>>>>[];

        for (int i = 0; i < _workflows.length; i++) {
          List<WorkflowTemplate> workflow = _workflows[i];
          if (workflow.isNotEmpty) {
            List<Map<String, dynamic>> _parseWorkflows =
                <Map<String, dynamic>>[];

            for (WorkflowTemplate temptParse in workflow) {
              _parseWorkflows.add(temptParse.toJson());
            }

            _workflowsSave.add(<String, List<Map<String, dynamic>>>{
              _paths[i]: _parseWorkflows
            });
          }
        }

        // _workflowsSave.forEach(print);

        // Sets the cache for the workflows.
        await File(getWorkflowCachePath(supportDir))
            .writeAsString(jsonEncode(_workflowsSave));

        await ProjectServicesModel.updateProjectCache(
          cache: ProjectCacheResult(
            projectsPath: null,
            refreshIntervals: null,
            lastProjectReload: null,
            lastWorkflowsReload: DateTime.now(),
          ),
          supportDir: supportDir,
        );

        return _workflowsSave
            .map((Map<String, List<Map<String, dynamic>>> _workflow) {
          return ProjectWorkflowsGrouped(
            path: _workflow.keys.first,
            workflows:
                _workflow.values.first.map((Map<String, dynamic> _workflow) {
              return WorkflowTemplate.fromJson(_workflow);
            }).toList(),
          );
        }).toList();
      } else {
        await logger.file(LogTypeTag.info,
            'Tried to get workflows when the projects directory is not set.',
            logDir: Directory(supportDir));
        return <ProjectWorkflowsGrouped>[];
      }
    } catch (_, s) {
      await logger.file(LogTypeTag.error, 'Couldn\'t fetch workflows from path',
          stackTraces: s, logDir: Directory(supportDir));
      return <ProjectWorkflowsGrouped>[];
    }
  }

  static Future<List<ProjectWorkflowsGrouped>> getWorkflowsFromCache(
      String supportDir) async {
    try {
      if (await hasCache(supportDir)) {
        // Gets the workflow from the cache.
        List<ProjectWorkflowsGrouped> _workflowsFromCache =
            <ProjectWorkflowsGrouped>[];

        List<dynamic> _read = jsonDecode(
            await File(getWorkflowCachePath(supportDir)).readAsString());

        for (dynamic workflow in _read) {
          Map<String, dynamic> _projectWorkflows =
              workflow as Map<String, dynamic>;

          _workflowsFromCache.add(ProjectWorkflowsGrouped(
              path: _projectWorkflows.keys.first,
              workflows: (_projectWorkflows.values.first as List<dynamic>)
                  .map((_) =>
                      WorkflowTemplate.fromJson(_ as Map<String, dynamic>))
                  .toList()));
        }

        return _workflowsFromCache;
      } else {
        await logger.file(LogTypeTag.warning,
            'Tried to get workflows when the workflow cache is not set. Should request to fetch in background as an initial fetch from path.',
            logDir: Directory(supportDir));
        return <ProjectWorkflowsGrouped>[];
      }
    } catch (_, s) {
      await logger.file(LogTypeTag.error, 'Couldn\'t fetch from workflow cache',
          stackTraces: s, logDir: Directory(supportDir));
      return <ProjectWorkflowsGrouped>[];
    }
  }
}

class ProjectWorkflowsGrouped {
  final String path;
  final List<WorkflowTemplate> workflows;

  ProjectWorkflowsGrouped({
    required this.path,
    required this.workflows,
  });
}
