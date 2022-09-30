class NetworkState {
  final bool connected;

  const NetworkState({
    this.connected = false,
  });

  factory NetworkState.initial() => const NetworkState();

  NetworkState copyWith({bool? connected}) {
    return NetworkState(
      connected: connected ?? this.connected,
    );
  }
}
