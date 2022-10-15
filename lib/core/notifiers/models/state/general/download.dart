// 🌎 Project imports:
import 'package:fluttermatic/app/enum.dart';

class DownloadState {
  final String remainingTime;
  final Progress progress;
  final double downloadProgress;

  const DownloadState({
    this.remainingTime = '...',
    this.progress = Progress.none,
    this.downloadProgress = 0,
  });

  factory DownloadState.initial() => const DownloadState();

  DownloadState copyWith({
    String? remainingTime,
    Progress? progress,
    double? downloadProgress,
  }) {
    return DownloadState(
      remainingTime: remainingTime ?? this.remainingTime,
      progress: progress ?? this.progress,
      downloadProgress: downloadProgress ?? this.downloadProgress,
    );
  }
}
