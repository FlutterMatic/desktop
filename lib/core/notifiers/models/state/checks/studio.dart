// 📦 Package imports:
import 'package:pub_semver/src/version.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/enum.dart';

class AndroidStudioState {
  final Version? studioVersion;
  final Progress progress;
  final String? studioPath;

  const AndroidStudioState({
    this.studioVersion,
    this.progress = Progress.none,
    this.studioPath,
  });

  factory AndroidStudioState.initial() => const AndroidStudioState();

  AndroidStudioState copyWith({
    Version? studioVersion,
    Progress? progress,
    String? studioPath,
  }) {
    return AndroidStudioState(
      studioVersion: studioVersion ?? this.studioVersion,
      progress: progress ?? this.progress,
      studioPath: studioPath ?? this.studioPath,
    );
  }
}
