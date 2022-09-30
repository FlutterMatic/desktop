class ProjectsState {
  final bool loading;
  final bool error;
  final String currentActivity;

  const ProjectsState({
    this.loading = false,
    this.error = false,
    this.currentActivity = '',
  });

  factory ProjectsState.initial() => const ProjectsState();

  ProjectsState copyWith({
    bool? loading,
    bool? error,
    String? currentActivity,
  }) {
    return ProjectsState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      currentActivity: currentActivity ?? this.currentActivity,
    );
  }
}
