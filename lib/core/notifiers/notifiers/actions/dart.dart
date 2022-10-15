// 🎯 Dart imports:
import 'dart:io';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/core/notifiers/models/payloads/actions/dart.dart';
import 'package:fluttermatic/core/notifiers/models/state/actions/dart.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/general/extract_pubspec.dart';

class DartActionsNotifier extends StateNotifier<DartActionsState> {
  final Ref ref;

  DartActionsNotifier(this.ref) : super(DartActionsState.initial());

  Future<void> createNewProject(NewDartProjectInfo project) async {
    try {
      if (project.projectPath.isEmpty) {
        state = state.copyWith(
          loading: false,
          error: 'Project path is empty. Please provide a valid path.',
        );

        return;
      }

      if (project.projectName.isEmpty) {
        state = state.copyWith(
          loading: false,
          error: 'Project name is empty. Please provide a valid name.',
        );

        return;
      }

      if (project.template.isEmpty) {
        state = state.copyWith(
          loading: false,
          error: 'Template is empty. Please provide a valid template.',
        );

        return;
      }

      state = state.copyWith(
        loading: true,
        error: '',
      );

      // Create the project by commanding in the project path through a shell.
      await shell
          .cd(project.projectPath)
          .run('dart create -t ${project.template} ${project.projectName}');

      await logger.file(LogTypeTag.info,
          'Created new Dart project: ${project.toJson()} at path: ${project.projectPath}');

      String projectPubspecPath =
          '${project.projectPath}\\${project.projectName}\\pubspec.yaml';

      // Add the project to the dart projects list.
      await ref.watch(projectsActionStateNotifier.notifier).addProject(
            extractPubspec(
                lines: await File(projectPubspecPath).readAsLines(),
                path: projectPubspecPath),
          );

      state = state.copyWith(
        loading: false,
        error: '',
      );

      return;
    } catch (e, s) {
      await logger.file(LogTypeTag.error, 'Failed to create new Dart project.',
          error: e, stackTrace: s);

      state = state.copyWith(
        loading: false,
        error:
            'Failed to create new Dart project. Please try again or report this issue.',
      );

      return;
    }
  }
}
