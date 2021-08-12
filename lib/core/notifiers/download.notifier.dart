import 'dart:io';

import 'package:flutter/material.dart';
import 'package:manager/app/constants/enum.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:manager/core/services/logs.dart';

class DownloadNotifier extends ChangeNotifier {
  int downloadedLength = 0;
  double? _downloadProgress;
  Progress _progress = Progress.NONE;
  Progress get progress => _progress;
  double? get downloadProgress => _downloadProgress;
  Future<void> downloadFile(String uri, String? fileName, String dir,
      {Color? progressBarColor}) async {
    _progress = Progress.STARTED;
    notifyListeners();

    /// Check for temporary Directory to download files
    bool tmpDir = await Directory(dir).exists();

    /// If tmpDir is false, then create a temporary directory.
    if (!tmpDir) {
      await Directory(dir).create();
      await logger.file(
          LogTypeTag.INFO, 'Created tmp directory while checking Java');
    }
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
        IOSink openFile = File(dir + '\\' + fileName!).openWrite();
        await for (List<int> buffer in response) {
          openFile.add(buffer);
          downloadedLength += buffer.length;
          _downloadProgress = downloadedLength / response.contentLength * 100;
          notifyListeners();
        }
        await logger.file(LogTypeTag.INFO, 'Flushing the buffer...');
        await openFile.flush();
        await logger.file(LogTypeTag.INFO, 'Closing the buffer...');
        await openFile.close();
        _downloadProgress = null;
        notifyListeners();
        await logger.file(LogTypeTag.INFO, '$fileName has been downloaded.');
      } else {
        await logger.file(LogTypeTag.ERROR,
            'Error code while downloading $fileName - ${response.statusCode}');
      }
    } catch (e) {
      await logger.file(LogTypeTag.ERROR, e.toString());
    }
  }
}
