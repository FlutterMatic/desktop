class WorkflowsState {
  final bool loading;
  final bool error;
  final bool initialized;

  WorkflowsState({
    this.loading = false,
    this.error = false,
    this.initialized = false,
  });

  factory WorkflowsState.initial() => WorkflowsState();

  WorkflowsState copyWith({
    bool? loading,
    bool? error,
    bool? initialized,
  }) {
    return WorkflowsState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      initialized: initialized ?? this.initialized,
    );
  }
}
