class NetworkState {
  final bool isConnected;

  const NetworkState({
    this.isConnected = false,
  });

  factory NetworkState.initial() => const NetworkState();

  NetworkState copyWith({bool? isConnected}) {
    return NetworkState(
      isConnected: isConnected ?? this.isConnected,
    );
  }
}
