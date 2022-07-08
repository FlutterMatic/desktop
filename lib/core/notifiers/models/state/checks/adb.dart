import 'package:pub_semver/src/version.dart';

class ADBState {
  final Version? adbVersion;

  const ADBState({
    this.adbVersion,
  });

  factory ADBState.initial() => const ADBState();

  ADBState copyWith({
    Version? adbVersion,
  }) {
    return ADBState(
      adbVersion: adbVersion,
    );
  }
}
