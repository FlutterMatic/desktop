// 🎯 Dart imports:
import 'dart:io';

// 📦 Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/enum.dart';
import 'package:fluttermatic/core/notifiers/models/state/general/download.dart';
import 'package:fluttermatic/core/notifiers/out.dart';
import 'package:fluttermatic/core/services/logs.dart';

class DownloadNotifier extends StateNotifier<DownloadState> {
  final Ref ref;

  DownloadNotifier(this.ref) : super(DownloadState.initial());

  // ignore: prefer_final_fields
  List<int> _buffer = <int>[];

  /// Resets the state of the download back to default.
  void resetState() => state = DownloadState.initial();

  /// Downloads the file from the given [uri] and saves it to the given [dir].
  ///
  /// This will return a [Future] that will resolve when the download is
  /// complete.
  ///
  /// You also have to specify the [fileName]. This is what the file will be
  /// named once this future resolves.
  ///
  /// This will also update the [DownloadState] to reflect the download
  /// progress in real time as it is happening. This is useful if you want to
  /// show a progress bar or something similar.
  Future<void> downloadFile(String uri, String fileName, String dir) async {
    int downloadedLength = 0;

    state.copyWith(
      progress: Progress.started,
      downloadProgress: 0,
    );

    HttpClient httpClient = HttpClient();

    try {
      HttpClientRequest request = await httpClient.getUrl(Uri.parse(uri));
      HttpClientResponse response = await request.close();

      if (response.statusCode == 200) {
        state = state.copyWith(
          progress: Progress.downloading,
        );

        await logger.file(LogTypeTag.info, 'Started downloading $fileName.');

        bool exists = await ref
            .watch(fileStateNotifier.notifier)
            .fileExists('$dir\\', fileName);

        if (!exists) {
          IOSink openFile = File('$dir\\$fileName').openWrite();

          if (state.downloadProgress > 100) {
            state = state.copyWith(
              downloadProgress: 0,
            );
          }

          if (downloadedLength != 0) {
            downloadedLength = 0;
          }

          if (_buffer.isNotEmpty) {
            _buffer.clear();
          }

          // Keep track of the time taken so we can calculate the
          // remaining time.
          Stopwatch elapsed = Stopwatch()..start();

          await for (_buffer in response) {
            openFile.add(_buffer);
            downloadedLength += _buffer.length;

            state = state.copyWith(
              downloadProgress: downloadedLength / response.contentLength * 100,
            );

            calculateTimeRemaining(
              downloadLength: downloadedLength,
              contentLength: response.contentLength,
              elapsed: elapsed,
            );
          }

          elapsed.stop();

          await logger.file(LogTypeTag.info, 'Flushing the buffer...');
          await openFile.flush();
          await logger.file(LogTypeTag.info, 'Closing the buffer...');
          await openFile.close();

          state = state.copyWith(
            downloadProgress: 0,
          );

          await logger.file(LogTypeTag.info, '$fileName has been downloaded.');
        } else {
          await logger.file(LogTypeTag.info, '$fileName already exist.');
        }
      } else {
        state = state.copyWith(
          progress: Progress.failed,
        );

        await logger.file(LogTypeTag.error,
            'Error code while downloading $fileName - ${response.statusCode}');
      }
    } catch (e, s) {
      state = state.copyWith(
        progress: Progress.failed,
      );

      await logger.file(LogTypeTag.error, 'Failed to use download notifier.',
          error: e, stackTrace: s);
    }

    // Reset the state back to default.
    state = DownloadState.initial();
  }

  /// Calculates the remaining time and sets it directly to the state instead
  /// of returning it. You can call this as many times as you want, but usually
  /// you should call it whenever there is a change in the download progress.
  void calculateTimeRemaining({
    required int downloadLength,
    required int contentLength,
    required Stopwatch elapsed,
  }) {
    // Completed the download process.
    if (downloadLength == contentLength) {
      state = state.copyWith(
        remainingTime: '0s',
      );
      return;
    }

    // Nothing downloaded yet - just started.
    if (downloadLength == 0) {
      state = state.copyWith(
        remainingTime: DownloadState.initial().remainingTime,
      );
      return;
    }

    // Calculate the time remaining
    if (downloadLength < contentLength) {
      int remaining = contentLength - downloadLength;
      int timeElapsed = elapsed.elapsed.inMilliseconds;
      double speed = downloadLength / timeElapsed * 1000;
      int time = remaining ~/ speed;
      int secs = time % 60;
      int mins = (time ~/ 60) % 60;
      int hours = (time ~/ 3600) % 24;
      int days = time ~/ 86400;

      if (secs < 10) {
        state = state.copyWith(
          remainingTime: '$days:0$hours:0$mins:0$secs',
        );
      } else {
        state = state.copyWith(
          remainingTime: '$days:$hours:$mins:$secs',
        );
      }
    }

    return;
  }
}
