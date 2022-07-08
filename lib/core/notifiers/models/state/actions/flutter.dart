class FlutterActionsState {
  final bool isLoading;
  final String currentProcess;
  final String error;
  final List<String> flutterDoctor;

  const FlutterActionsState({
    this.isLoading = false,
    this.error = '',
    this.currentProcess = '...',
    this.flutterDoctor = const [],
  });

  factory FlutterActionsState.initial() => FlutterActionsState.initial();

  FlutterActionsState copyWith({
    bool? isLoading,
    String? error,
    String? currentProcess,
  }) {
    return FlutterActionsState(
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
      currentProcess: currentProcess ?? this.currentProcess,
    );
  }

  // Add to Flutter doctor.
  void addFlutterDoctor(List<String> item) {
    flutterDoctor.addAll(item);
  }

  // Remove from Flutter doctor.
  void removeFlutterDoctor(String item) {
    flutterDoctor.remove(item);
  }

  // Remove where from Flutter doctor.
  void removeWhereFlutterDoctor(bool Function(String) predicate) {
    flutterDoctor.removeWhere(predicate);
  }

  // Clear Flutter doctor.
  void clearFlutterDoctor() {
    flutterDoctor.clear();
  }
}
