// 📦 Package imports:
import 'package:pub_semver/src/version.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/enum.dart';

class VSCState {
  final Version? vscVersion;
  final String channel;
  final Progress progress;

  const VSCState({
    this.vscVersion,
    this.channel = '...',
    this.progress = Progress.none,
  });

  factory VSCState.initial() => const VSCState();

  VSCState copyWith({
    Version? vscVersion,
    String? channel,
    Progress? progress,
  }) {
    return VSCState(
      vscVersion: vscVersion ?? this.vscVersion,
      channel: channel ?? this.channel,
      progress: progress ?? this.progress,
    );
  }
}
