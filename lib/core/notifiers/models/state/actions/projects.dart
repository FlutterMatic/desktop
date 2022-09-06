class ProjectsState {
  final bool isError;
  final bool isLoading;

  const ProjectsState({
    this.isError = false,
    this.isLoading = false,
  });

  factory ProjectsState.initial() => const ProjectsState();

  ProjectsState copyWith({
    bool? isError,
    bool? isLoading,
  }) {
    return ProjectsState(
      isError: isError ?? this.isError,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
