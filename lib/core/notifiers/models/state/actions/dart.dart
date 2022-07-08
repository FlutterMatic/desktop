class DartActionsState {
  final bool isLoading;

  const DartActionsState({
    this.isLoading = false,
  });

  factory DartActionsState.initial() => DartActionsState.initial();

  DartActionsState copyWith({
    bool? isLoading,
  }) {
    return DartActionsState(
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
