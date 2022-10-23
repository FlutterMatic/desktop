// 🌎 Project imports:
import 'package:fluttermatic/meta/views/workflows/models/workflow.dart';

class AppSearchState {
  final bool loading;
  final bool error;
  final bool projectsError;
  final bool workflowsError;
  final bool pubError;
  final String currentActivity;

  const AppSearchState({
    this.loading = false,
    this.error = false,
    this.projectsError = false,
    this.workflowsError = false,
    this.pubError = false,
    this.currentActivity = '',
  });

  factory AppSearchState.initial() => const AppSearchState();

  AppSearchState copyWith({
    bool? loading,
    bool? error,
    bool? projectsError,
    bool? workflowsError,
    bool? pubError,
    String? currentActivity,
  }) {
    return AppSearchState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      projectsError: projectsError ?? this.projectsError,
      workflowsError: workflowsError ?? this.workflowsError,
      pubError: pubError ?? this.pubError,
      currentActivity: currentActivity ?? this.currentActivity,
    );
  }
}

class ProjectWorkflowsGrouped {
  final String projectPath;
  final List<WorkflowTemplate> workflows;

  ProjectWorkflowsGrouped({
    required this.projectPath,
    required this.workflows,
  });
}
