import 'package:fluttermatic/app/enum.dart';
import 'package:pub_semver/src/version.dart';

class GitState {
  final Version? gitVersion;
  final String channel;
  final Progress progress;

  const GitState({
    this.gitVersion,
    this.channel = '...',
    this.progress = Progress.none,
  });

  factory GitState.initial() => const GitState();

  GitState copyWith({
    Version? gitVersion,
    String? channel,
    Progress? progress,
  }) {
    return GitState(
      gitVersion: gitVersion ?? this.gitVersion,
      channel: channel ?? this.channel,
      progress: progress ?? this.progress,
    );
  }
}
