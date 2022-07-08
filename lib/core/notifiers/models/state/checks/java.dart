import 'package:fluttermatic/app/enum.dart';
import 'package:pub_semver/src/version.dart';

class JavaState {
  final Version? javaVersion;
  final String channel;
  final Progress progress;

  const JavaState({
    this.javaVersion,
    this.channel = '...',
    this.progress = Progress.none,
  });

  factory JavaState.initial() => const JavaState();

  JavaState copyWith({
    Version? javaVersion,
    String? channel,
    Progress? progress,
  }) {
    return JavaState(
      javaVersion: javaVersion ?? this.javaVersion,
      channel: channel ?? this.channel,
      progress: progress ?? this.progress,
    );
  }
}
