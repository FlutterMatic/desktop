class ProjectsState {
  final bool error;
  final bool loading;
  final String currentActivity;

  const ProjectsState({
    this.error = false,
    this.loading = false,
    this.currentActivity = '',
  });

  factory ProjectsState.initial() => const ProjectsState();

  ProjectsState copyWith({
    bool? error,
    bool? loading,
    String? currentActivity,
  }) {
    return ProjectsState(
      error: error ?? this.error,
      loading: loading ?? this.loading,
      currentActivity: currentActivity ?? this.currentActivity,
    );
  }
}
