// 📦 Package imports:
import 'package:pub_semver/src/version.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/enum.dart';

class FlutterState {
  final Version? flutterVersion;
  final String channel;
  final Progress progress;

  const FlutterState({
    this.flutterVersion,
    this.channel = '...',
    this.progress = Progress.none,
  });

  factory FlutterState.initial() => const FlutterState();

  FlutterState copyWith({
    Version? flutterVersion,
    String? channel,
    Progress? progress,
  }) {
    return FlutterState(
      flutterVersion: flutterVersion ?? this.flutterVersion,
      channel: channel ?? this.channel,
      progress: progress ?? this.progress,
    );
  }
}
