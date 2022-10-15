// 🎯 Dart imports:
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/core/models/projects.dart';
import 'package:fluttermatic/core/notifiers/models/state/actions/workflows.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/search.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/general/extract_pubspec.dart';
import 'package:fluttermatic/meta/views/workflows/models/workflow.dart';

class WorkflowsNotifier extends StateNotifier<WorkflowsState> {
  final Ref ref;

  WorkflowsNotifier(this.ref) : super(WorkflowsState.initial());

  final List<ProjectWorkflowsGrouped> _workflows = <ProjectWorkflowsGrouped>[];

  UnmodifiableListView<ProjectWorkflowsGrouped> get workflows =>
      UnmodifiableListView<ProjectWorkflowsGrouped>(_workflows);

  /// Remove all the workflow groups that have empty [workflows] list.
  void _cleanUpWorkflows() =>
      _workflows.removeWhere((e) => e.workflows.isEmpty);

  /// Loads the workflows from the current projects. You can set [force]
  /// to true or false depending on whether or not you want to force reload
  /// of the cache (if available). If false then it will load based on the
  /// cache or load from the projects if the cache has expired.
  ///
  /// **NOTE:** This will only load the workflows of the currently loaded
  /// projects from the projects notifier (using the isolate). Projects outside
  /// that list will not be loaded, or searched for in the first place.
  ///
  /// This also must only be called after the projects have been loaded.
  Future<void> getWorkflows(bool force) async {
    try {
      // If already loading then ignore this request because it could've been
      // called multiple causing multiple copies of the same workflows shown.
      if (state.loading) {
        await logger.file(LogTypeTag.warning,
            'Tried to fetch workflows when already loading state in the notifier.');

        return;
      }

      state = state.copyWith(
        loading: true,
        error: false,
      );

      // We will first try to load the projects if they aren't already loaded.
      if (ref.watch(projectsActionStateNotifier.notifier).projects.isEmpty) {
        await logger.file(LogTypeTag.info,
            'Projects is empty. Calling [getProjectsWithIsolate] in case it hasn\'t loaded already...');

        await ref
            .watch(projectsActionStateNotifier.notifier)
            .getProjects(false);
      }

      _workflows.clear();

      for (ProjectObject project
          in ref.watch(projectsActionStateNotifier.notifier).projects) {
        String workflowsPath = '${project.path}\\$fmWorkflowDir';

        /// Check if the directory exists in the first place.
        /// If it doesn't then we can skip this project.
        /// If it does then we can load the workflows.
        if (!await Directory(workflowsPath).exists()) {
          continue;
        }

        /// Get the list of files in the workflows directory.
        /// If there are no files then we can skip this project.
        List<FileSystemEntity> projectWorkflows =
            (await Directory(workflowsPath).list().toList());

        if (projectWorkflows.isEmpty) {
          continue;
        }

        List<WorkflowTemplate> templates = [];

        for (FileSystemEntity workflow in projectWorkflows) {
          if (workflow is File) {
            try {
              Map<String, dynamic> rawContent =
                  jsonDecode(await workflow.readAsString());

              templates.add(WorkflowTemplate.fromJson(rawContent));
            } catch (e, s) {
              await logger.file(LogTypeTag.warning,
                  'Failed to load workflow ${workflow.path}.',
                  error: e, stackTrace: s);
            }
          }
        }

        if (templates.isNotEmpty) {
          _workflows.add(ProjectWorkflowsGrouped(
            projectPath: workflowsPath,
            workflows: templates,
          ));
        }
      }

      state = state.copyWith(
        loading: false,
        error: false,
        initialized: true,
      );

      return;
    } catch (e, s) {
      await logger.file(LogTypeTag.error, 'Error loading workflows.',
          error: e, stackTrace: s);

      _workflows.clear();

      state = state.copyWith(
        loading: false,
        error: true,
        initialized: false,
      );

      return;
    }
  }

  /// Will save the workflow information locally on the user device. Will update
  /// the workflow state accordingly.
  ///
  /// This expects a context so that it can show a snackbar if the save fails or
  /// succeeds and generally informs the user about the state of the save.
  Future<void> saveWorkflow(
    BuildContext context, {
    required String originalName,
    required bool addToGitignore,
    required bool addAllToGitignore,
    required bool showAlerts,
    required String pubspecPath,
    required WorkflowTemplate template,
    required PubspecInfo? pubspecInfo,
  }) async {
    try {
      if (template.name.isEmpty) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Workflow name cannot be empty.'),
          ),
        );

        return;
      }

      state = state.copyWith(
        loading: true,
        error: false,
      );

      String? dirPath = pubspecInfo?.pathToPubspec ?? pubspecPath;

      dirPath = (dirPath.toString().split('\\')..removeLast()).join('\\');

      await Directory('$dirPath\\$fmWorkflowDir').create(recursive: true);

      await File.fromUri(
              Uri.file('$dirPath\\$fmWorkflowDir\\${template.name}.json'))
          .writeAsString(jsonEncode(template.toJson()))
          .timeout(const Duration(seconds: 3));

      // If we saved the project, meaning that this is the final step (user done
      // setting up the workflow), then we will see if we have to add anything
      // to .gitignore.
      if (template.isSaved && (addToGitignore || addAllToGitignore)) {
        String addComment =
            '# Specific FlutterMatic workflow hidden: ${template.name}';
        String addAllComment = '# All FlutterMatic workflows are hidden.';

        try {
          File git = File('$dirPath\\.gitignore');

          // Create the .gitignore file if it doesn't exist.
          if (!await git.exists()) {
            await git.writeAsString('').timeout(const Duration(seconds: 3));
          }

          List<String> gitignoreFile = await git.readAsLines();

          // We will add the comment if it doesn't already exist.
          if ((addToGitignore && !gitignoreFile.contains(addComment)) ||
              (addAllToGitignore && !gitignoreFile.contains(addAllComment))) {
            await git
                .writeAsString(
                    '\n${addToGitignore ? addComment : addAllComment}\n',
                    mode: FileMode.append)
                .timeout(const Duration(seconds: 3));
          }

          // Make sure it doesn't already exist.
          if (addToGitignore &&
              !gitignoreFile.contains('$fmWorkflowDir/${template.name}.json')) {
            await git
                .writeAsString('$fmWorkflowDir/${template.name}.json\n',
                    mode: FileMode.append)
                .timeout(const Duration(seconds: 3));
          } else if (addAllToGitignore &&
              !gitignoreFile.contains('$fmWorkflowDir/')) {
            await git
                .writeAsString('$fmWorkflowDir/\n', mode: FileMode.append)
                .timeout(const Duration(seconds: 3));
          }
        } catch (e, s) {
          await logger.file(
              LogTypeTag.error, 'Couldn\'t add to .gitignore for workflow.',
              error: e, stackTrace: s);
        }
      }

      // Update the workflows list.
      for (int i = 0; i < _workflows.length; i++) {
        for (int j = 0; j < _workflows[i].workflows.length; j++) {
          if (_workflows[i].workflows[j].name == originalName) {
            _workflows[i].workflows[j] = template;
            break;
          }
        }
      }

      _cleanUpWorkflows();

      await logger.file(LogTypeTag.info,
          'New workflow created/edited at the following path: ${'$dirPath\\$fmWorkflowDir\\${template.name}.json'}');

      state = state.copyWith(
        loading: false,
        error: false,
      );

      return;
    } catch (e, s) {
      await logger.file(LogTypeTag.error, 'Couldn\'t save and run workflow.',
          error: e, stackTrace: s);

      state = state.copyWith(
        loading: false,
        error: true,
      );

      return;
    }
  }

  /// Will attempt to delete the workflow at the given [projectPath].
  ///
  /// This will also handle updating the state and removing the workflow
  /// from the list of workflows.
  ///
  /// This will also delete the logs for the workflow if they exist.
  ///
  /// Make sure that the [projectPath] is the full path to the workflow file. This
  /// must end with ".json".
  Future<void> deleteWorkflow(WorkflowTemplate workflow) async {
    try {
      state = state.copyWith(
        loading: true,
        error: false,
      );

      await File(workflow.workflowPath).delete();

      // Check to see if this workflow has any logs and
      // delete them as well.
      Directory logsDir = Directory(
          '${(workflow.workflowPath.split('\\')..removeLast()).join('\\')}\\logs\\${workflow.workflowPath.split('\\').last.split('.').first}');

      if (await logsDir.exists()) {
        await logsDir.delete(recursive: true);
        await logger.file(LogTypeTag.info,
            'Deleted logs for workflow ${workflow.workflowPath.split('\\').last}');
      }

      List<FileSystemEntity> existingWorkflows = Directory(
              (workflow.workflowPath.split('\\')..removeLast()).join('\\'))
          .listSync()
          .whereType<File>()
          .toList();

      // If there are no more workflows, then delete the
      // entire workflows directory.
      if (existingWorkflows.isEmpty) {
        await Directory(
                (workflow.workflowPath.split('\\')..removeLast()).join('\\'))
            .delete(recursive: true);

        await logger.file(LogTypeTag.info,
            'Deleted project "$fmWorkflowDir" directory because no more workflows exist in it.');
      }

      await logger.file(LogTypeTag.info,
          'Deleted a workflow file from ${workflow.workflowPath}');

      // Remove the workflow from the list.
      _workflows.removeWhere((e1) {
        if (workflow.workflowPath.startsWith(e1.projectPath)) {
          e1.workflows.removeWhere((e2) {
            return e2.workflowPath == workflow.workflowPath;
          });
        }

        return false;
      });

      _cleanUpWorkflows();

      state = state.copyWith(
        loading: false,
        error: false,
      );

      return;
    } catch (e, s) {
      await logger.file(LogTypeTag.error,
          'Failed to delete workflow file from ${workflow.workflowPath}.',
          error: e, stackTrace: s);

      state = state.copyWith(
        loading: false,
        error: true,
      );

      return;
    }
  }
}
