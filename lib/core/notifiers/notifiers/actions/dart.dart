// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/core/notifiers/models/payloads/actions/dart.dart';
import 'package:fluttermatic/core/notifiers/models/state/actions/dart.dart';
import 'package:fluttermatic/core/services/logs.dart';

class DartActionsNotifier extends StateNotifier<DartActionsState> {
  final Reader read;

  DartActionsNotifier(this.read) : super(DartActionsState.initial());

  Future<void> createNewProject(NewDartProjectInfo project) async {
    state = state.copyWith(
      loading: true,
      error: '',
    );

    try {
      if (project.projectPath.isEmpty) {
        state = state.copyWith(
          loading: false,
          error: 'Project path is empty. Please provide a valid path.',
        );

        return;
      }

      // Create the project.
      await shell
          .cd(project.projectPath)
          .run('dart create -t ${project.template} ${project.projectName}');

      await logger.file(LogTypeTag.info,
          'Created new Dart project: ${project.toJson()} at path: ${project.projectPath}');

      state = state.copyWith(
        loading: false,
        error: '',
      );

      return;
    } catch (_, s) {
      await logger.file(
          LogTypeTag.error, 'Failed to create new Dart project: $_',
          stackTraces: s);

      state = state.copyWith(
        loading: false,
        error:
            'Failed to create new Dart project. Please try again or report this issue.',
      );

      return;
    }
  }
}
