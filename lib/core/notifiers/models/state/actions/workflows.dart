class WorkflowsState {
  final bool loading;
  final bool error;

  WorkflowsState({
    this.loading = false,
    this.error = false,
  });

  factory WorkflowsState.initial() => WorkflowsState();

  WorkflowsState copyWith({
    bool? loading,
    bool? error,
  }) {
    return WorkflowsState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }
}
