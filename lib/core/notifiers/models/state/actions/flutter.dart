class FlutterActionsState {
  final bool loading;
  final String currentActivity;
  final String error;

  const FlutterActionsState({
    this.loading = false,
    this.error = '',
    this.currentActivity = '...',
  });

  factory FlutterActionsState.initial() => FlutterActionsState.initial();

  FlutterActionsState copyWith({
    bool? loading,
    String? error,
    String? currentActivity,
  }) {
    return FlutterActionsState(
      error: error ?? this.error,
      loading: loading ?? this.loading,
      currentActivity: currentActivity ?? this.currentActivity,
    );
  }
}
