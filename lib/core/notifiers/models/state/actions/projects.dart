class ProjectsState {
  final bool loading;
  final bool error;
  final bool initialized;
  final String currentActivity;

  const ProjectsState({
    this.loading = false,
    this.error = false,
    this.initialized = false,
    this.currentActivity = '',
  });

  factory ProjectsState.initial() => const ProjectsState();

  ProjectsState copyWith({
    bool? loading,
    bool? error,
    bool? initialized,
    String? currentActivity,
  }) {
    return ProjectsState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      initialized: initialized ?? this.initialized,
      currentActivity: currentActivity ?? this.currentActivity,
    );
  }
}
