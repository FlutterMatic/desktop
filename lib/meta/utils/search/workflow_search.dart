// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/core/models/projects.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/search/projects_search.dart';
import 'package:fluttermatic/meta/views/tabs/sections/projects/models/projects.services.dart';
import 'package:fluttermatic/meta/views/workflows/models/workflow.dart';

class WorkflowSearchUtils {
  /// Returns the path where the workflow cache is stored or where it should
  /// be stored.
  static String getWorkflowCachePath(String applicationSupportDir) =>
      '$applicationSupportDir\\cache\\workflow_cache.json';

  /// Will return [true] if there is cache for the workflows and [false] if
  /// there isn't.
  static Future<bool> hasCache(String supportDir) async =>
      File(getWorkflowCachePath(supportDir)).exists();

  /// Will get all the workflows in a specific project. Will return a list of
  /// [WorkflowTemplate] objects.
  static Future<List<WorkflowTemplate>> getWorkflowFromProject(
      String pathOfProject) async {
    Directory path = Directory('$pathOfProject\\$fmWorkflowDir');

    if (await path.exists()) {
      // Will list all the files in the directory.
      List<FileSystemEntity> files = path.listSync();

      List<WorkflowTemplate> workflows = <WorkflowTemplate>[];

      // Will loop through all the files and check if the file is a workflow
      // and try to parse it.
      for (FileSystemEntity file in files) {
        if (file is File && file.path.endsWith('.json')) {
          try {
            // Will parse the file and return the workflow.
            workflows.add(WorkflowTemplate.fromJson(
                jsonDecode(await File(file.path).readAsString())));
          } catch (_, s) {
            await logger.file(LogTypeTag.warning,
                'Failed to parse a workflow. Ignoring file: $_',
                stackTraces: s);
          }
        }
      }

      return workflows;
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
        List<ProjectObject> projectsRefetch =
            await ProjectSearchUtils.getProjectsFromPath(
                cache: cache, supportDir: supportDir);

        // Each project will have its own list of workflows. They are
        // automatically sorted for the user.
        List<String> paths = <String>[];
        List<List<WorkflowTemplate>> workflows = <List<WorkflowTemplate>>[];

        // Will loop through all the projects and get the workflows to parse
        // and sort.
        for (ProjectObject project in projectsRefetch) {
          List<WorkflowTemplate> projectWorkflows =
              await getWorkflowFromProject(project.path);

          if (projectWorkflows.isNotEmpty) {
            paths.add(project.path);
            workflows.add(projectWorkflows);
          }
        }

        List<Map<String, List<Map<String, dynamic>>>> workflowsSave =
            <Map<String, List<Map<String, dynamic>>>>[];

        for (int i = 0; i < workflows.length; i++) {
          List<WorkflowTemplate> workflow = workflows[i];
          if (workflow.isNotEmpty) {
            List<Map<String, dynamic>> parseWorkflows =
                <Map<String, dynamic>>[];

            for (WorkflowTemplate temptParse in workflow) {
              parseWorkflows.add(temptParse.toJson());
            }

            workflowsSave.add(
                <String, List<Map<String, dynamic>>>{paths[i]: parseWorkflows});
          }
        }

        // _workflowsSave.forEach(print);

        // Sets the cache for the workflows.
        await File(getWorkflowCachePath(supportDir))
            .writeAsString(jsonEncode(workflowsSave));

        await ProjectServicesModel.updateProjectCache(
          cache: ProjectCacheResult(
            projectsPath: null,
            refreshIntervals: null,
            lastProjectReload: null,
            lastWorkflowsReload: DateTime.now(),
          ),
          supportDir: supportDir,
        );

        return workflowsSave
            .map((Map<String, List<Map<String, dynamic>>> workflow) {
          return ProjectWorkflowsGrouped(
            path: workflow.keys.first,
            workflows:
                workflow.values.first.map((Map<String, dynamic> workflow) {
              return WorkflowTemplate.fromJson(workflow);
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
        List<ProjectWorkflowsGrouped> workflowsFromCache =
            <ProjectWorkflowsGrouped>[];

        List<dynamic> read = jsonDecode(
            await File(getWorkflowCachePath(supportDir)).readAsString());

        for (dynamic workflow in read) {
          Map<String, dynamic> projectWorkflows =
              workflow as Map<String, dynamic>;

          workflowsFromCache.add(ProjectWorkflowsGrouped(
              path: projectWorkflows.keys.first,
              workflows: (projectWorkflows.values.first as List<dynamic>)
                  .map((_) =>
                      WorkflowTemplate.fromJson(_ as Map<String, dynamic>))
                  .toList()));
        }

        return workflowsFromCache;
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
