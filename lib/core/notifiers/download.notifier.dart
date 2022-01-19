// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:manager/app/constants/enum.dart';
import 'package:manager/core/libraries/services.dart';

class DownloadNotifier extends ChangeNotifier {
  Duration perTime = const Duration(milliseconds: 500);
  List<int>? buffer;
  int secsTime = 0,
      minsTime = 0,
      hoursTime = 0,
      daysTime = 0,
      downloadedLength = 0;
  String _remainingTime = 'calculating';
  double dProgress = 0;
  Progress _progress = Progress.none;
  String get remainingTime => _remainingTime;
  Progress get progress => _progress;
  double get downloadProgress => dProgress;

  Future<void> downloadFile(String uri, String? fileName, String dir,
      {Color? progressBarColor}) async {
    _progress = Progress.started;
    dProgress = 0;
    notifyListeners();

    HttpClient _httpClient = HttpClient();
    try {
      HttpClientRequest request = await _httpClient.getUrl(Uri.parse(uri));
      HttpClientResponse response = await request.close();
      if (response.statusCode == 200) {
        _progress = Progress.downloading;
        notifyListeners();
        await logger.file(LogTypeTag.info, 'Started downloading $fileName.');
        bool _exists = await checkFile(dir + '\\', fileName!);
        if (!_exists) {
          IOSink openFile = File(dir + '\\' + fileName).openWrite();
          if (dProgress > 100) {
            dProgress = 0;
            notifyListeners();
          }
          if (downloadedLength != 0) {
            downloadedLength = 0;
          }
          if (buffer != null && buffer!.isNotEmpty) {
            buffer = null;
          }

          // Keep track of the time taken so we can calculate the remaining time.
          Stopwatch _elapsed = Stopwatch()..start();

          await for (buffer in response) {
            openFile.add(buffer!);
            downloadedLength += buffer!.length;
            dProgress = downloadedLength / response.contentLength * 100;
            notifyListeners();
            calculateTimeRemaining(
                downloadLength: downloadedLength,
                contentLength: response.contentLength,
                elapsed: _elapsed);
          }

          _elapsed.stop();
          await logger.file(LogTypeTag.info, 'Flushing the buffer...');
          await openFile.flush();
          await logger.file(LogTypeTag.info, 'Closing the buffer...');
          await openFile.close();
          dProgress = 0;
          notifyListeners();
          await logger.file(LogTypeTag.info, '$fileName has been downloaded.');
        } else {
          await logger.file(LogTypeTag.info, '$fileName already exist.');
        }
      } else {
        _progress = Progress.failed;
        notifyListeners();
        await logger.file(LogTypeTag.error,
            'Error code while downloading $fileName - ${response.statusCode}');
      }
    } catch (_, s) {
      _progress = Progress.failed;
      notifyListeners();
      await logger.file(LogTypeTag.error, 'Failed to use download notifier: $_',
          stackTraces: s);
    }
  }

  void calculateTimeRemaining({
    required int downloadLength,
    required int contentLength,
    required Stopwatch elapsed,
  }) {
    // Completed the download process.
    if (downloadLength == contentLength) {
      _remainingTime = '0s';
      notifyListeners();
      return;
    }

    // Still didn't download anything.
    if (downloadLength == 0) {
      _remainingTime = 'calculating...';
      notifyListeners();
      return;
    }

    // Calculate the time remaining
    if (downloadLength < contentLength) {
      int _remaining = contentLength - downloadLength;
      int _elapsed = elapsed.elapsed.inMilliseconds;
      double _speed = downloadLength / _elapsed * 1000;
      int _time = _remaining ~/ _speed;
      int _secs = _time % 60;
      int _mins = (_time ~/ 60) % 60;
      int _hours = (_time ~/ 3600) % 24;
      int _days = _time ~/ 86400;
      if (_secs < 10) {
        _remainingTime = '$_days:0$_hours:0$_mins:0$_secs';
      } else {
        _remainingTime = '$_days:$_hours:$_mins:$_secs';
      }
      notifyListeners();
    }

    return;
  }
}
