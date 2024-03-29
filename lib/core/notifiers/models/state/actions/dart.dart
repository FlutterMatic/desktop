class DartActionsState {
  final bool loading;
  final String error;

  const DartActionsState({
    this.loading = false,
    this.error = '',
  });

  factory DartActionsState.initial() => const DartActionsState();

  DartActionsState copyWith({
    bool? loading,
    String? error,
  }) {
    return DartActionsState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }
}
