import 'dart:io';

import 'package:flutter/material.dart';
import 'package:manager/app/constants/enum.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:manager/core/services/logs.dart';

class DownloadNotifier extends ChangeNotifier {
  Duration perTime = const Duration(milliseconds: 1000);
  List<int>? buffer;
  int secsTime = 0,
      minsTime = 0,
      hoursTime = 0,
      daysTime = 0,
      downloadedLength = 0;
  String _remainingTime = 'Estimating...';
  double dProgress = 0;
  Progress _progress = Progress.NONE;
  String get remainingTime => _remainingTime;
  Progress get progress => _progress;
  double get downloadProgress => dProgress;

  Future<void> downloadFile(String uri, String? fileName, String dir,
      {Color? progressBarColor}) async {
    _progress = Progress.STARTED;
    dProgress = 0;
    notifyListeners();

    HttpClient httpClient = HttpClient();
    try {
      HttpClientRequest request = await httpClient.getUrl(
        Uri.parse(uri),
      );
      HttpClientResponse response = await request.close();
      if (response.statusCode == 200) {
        _progress = Progress.DOWNLOADING;
        notifyListeners();
        await logger.file(LogTypeTag.INFO, 'Started downloading $fileName.');
        bool wtf = await checkFile(dir + '\\', fileName!);
        if (!wtf) {
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
          await for (buffer in response) {
            openFile.add(buffer!);
            downloadedLength += buffer!.length;
            dProgress = downloadedLength / response.contentLength * 100;
            notifyListeners();
            await calculateSpeed(downloadedLength, response.contentLength);
          }
          await logger.file(LogTypeTag.INFO, 'Flushing the buffer...');
          await openFile.flush();
          await logger.file(LogTypeTag.INFO, 'Closing the buffer...');
          await openFile.close();
          dProgress = 0;
          notifyListeners();
          await logger.file(LogTypeTag.INFO, '$fileName has been downloaded.');
        } else {
          await logger.file(LogTypeTag.INFO, '$fileName already exist.');
        }
      } else {
        _progress = Progress.FAILED;
        notifyListeners();
        await logger.file(LogTypeTag.ERROR,
            'Error code while downloading $fileName - ${response.statusCode}');
      }
    } catch (e) {
      _progress = Progress.FAILED;
      notifyListeners();
      await logger.file(LogTypeTag.ERROR, e.toString());
    }
  }

  Future<void> calculateSpeed(int downLength, int totalLength) async {
    secsTime = Duration(
            seconds:
                (((perTime.inMilliseconds * totalLength) / downLength) - 100)
                    .toInt())
        .inSeconds;
    minsTime = Duration(seconds: secsTime).inMinutes;
    hoursTime = Duration(minutes: minsTime).inHours;
    daysTime = Duration(hours: hoursTime).inDays;
    if (secsTime > 60 && minsTime < 60 && hoursTime < 24) {
      _remainingTime = '$minsTime mins';
      notifyListeners();
    } else if (secsTime > 60 && minsTime > 60 && hoursTime < 24) {
      _remainingTime = '$hoursTime hours';
      notifyListeners();
    } else if (secsTime > 60 && minsTime > 60 && hoursTime > 24) {
      _remainingTime = '$daysTime days';
      notifyListeners();
    } else if (secsTime < 60 && minsTime < 60 && hoursTime < 24) {
      _remainingTime = '$secsTime secs';
      notifyListeners();
    }
  }
}
