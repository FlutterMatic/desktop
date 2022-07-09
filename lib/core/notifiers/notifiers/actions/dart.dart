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

  Future<String> createNewProject(NewDartProjectInfo project) async {
    state = state.copyWith(
      isLoading: true,
    );

    try {
      if (project.projectPath.isEmpty) {
        state = state.copyWith(
          isLoading: false,
        );
        return 'Project path is empty. Please provide a valid path.';
      }

      // Create the project.
      await shell
          .cd(project.projectPath)
          .run('dart create -t ${project.template} ${project.projectName}');

      await logger.file(LogTypeTag.info,
          'Created new Dart project: ${project.toJson()} at path: ${project.projectPath}');

      state = state.copyWith(
        isLoading: false,
      );
      return 'success';
    } catch (_, s) {
      await logger.file(
          LogTypeTag.error, 'Failed to create new Dart project: $_',
          stackTraces: s);

      state = state.copyWith(
        isLoading: false,
      );
      return 'Failed to create new Dart project. Please try again or report this issue.';
    }
  }
}
