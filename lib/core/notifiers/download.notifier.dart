import 'dart:io';

import 'package:flutter/material.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:manager/core/services/logs.dart';

class DownloadNotifier extends ChangeNotifier {
  int downloadedLength = 0;
  int? _progress;
  Color? _progressColor;
  int? get progress => _progress;
  Color get progressColor => _progressColor!;
  Future<void> downloadFile(String uri, String? fileName, String dir,
      {String? value, Color? progressBarColor}) async {
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
        _progressColor = progressBarColor;
        notifyListeners();
        await logger.file(LogTypeTag.INFO, 'Started downloading $fileName.');
        IOSink openFile = File(dir + '\\' + fileName!).openWrite();
        await for (List<int> buffer in response) {
          openFile.add(buffer);
          downloadedLength += buffer.length;
          _progress = (downloadedLength / response.contentLength * 100).floor();
          notifyListeners();
        }
        await logger.file(LogTypeTag.INFO, 'Flushing the buffer...');
        await openFile.flush();
        await logger.file(LogTypeTag.INFO, 'Closing the buffer...');
        await openFile.close();
        _progress = null;
        notifyListeners();
        await logger.file(LogTypeTag.INFO, '$fileName has been downloaded.');
        notifyListeners();
      } else {
        value = 'Error downloading';
        await logger.file(LogTypeTag.ERROR,
            'Error code while downloading $fileName - ${response.statusCode}');
      }
    } catch (e) {
      await logger.file(LogTypeTag.ERROR, e.toString());
    }
  }
}
