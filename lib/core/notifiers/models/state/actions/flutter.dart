class FlutterActionsState {
  final String error;
  final bool loading;
  final String currentActivity;

  const FlutterActionsState({
    this.error = '',
    this.loading = false,
    this.currentActivity = '...',
  });

  factory FlutterActionsState.initial() => const FlutterActionsState();

  FlutterActionsState copyWith({
    String? error,
    bool? loading,
    String? currentActivity,
  }) {
    return FlutterActionsState(
      error: error ?? this.error,
      loading: loading ?? this.loading,
      currentActivity: currentActivity ?? this.currentActivity,
    );
  }
}
