import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

enum ZipFileOperation { includeItem, skipItem, cancel }
typedef OnExtracting = ZipFileOperation Function(
    ZipEntry zipEntry, double progress);

typedef OnZipping = ZipFileOperation Function(
    String filePath, bool isDirectory, double progress);

String _progressOperationToString(ZipFileOperation extractOperation) {
  switch (extractOperation) {
    case ZipFileOperation.skipItem:
      return 'skip';
    case ZipFileOperation.cancel:
      return 'cancel';
    default:
      return 'include';
  }
}

/// Utility class for creating and extracting zip archive files.
class ZipFile {
  static const MethodChannel _channel = MethodChannel('flutter_archive');

  /// Extract [zipFile] to a given [destinationDir]. Optional callback function
  /// [onExtracting] is called before extracting a zip entry.
  ///
  /// [onExtracting] must return one of the following values:
  /// [ZipFileOperation.includeItem] - extract this file/directory
  /// [ZipFileOperation.skipItem] - do not extract this file/directory
  /// [ZipFileOperation.cancel] - cancel the operation
  static Future<void> extractToDirectory(
      {required File zipFile,
      required Directory destinationDir,
      OnExtracting? onExtracting}) async {
    bool reportProgress = onExtracting != null;
    if (reportProgress) {
      if (!_isMethodCallHandlerSet) {
        _channel.setMethodCallHandler(_channelMethodCallHandler);
        _isMethodCallHandlerSet = true;
      }
    }
    int jobId = ++_jobId;
    try {
      if (onExtracting != null) {
        _onExtractingHandlerByJobId[jobId] = onExtracting;
      }

      await _channel.invokeMethod<void>('unzip', <String, dynamic>{
        'zipFile': zipFile.path,
        'destinationDir': destinationDir.path,
        'reportProgress': reportProgress,
        'jobId': jobId,
      });
    } finally {
      _onExtractingHandlerByJobId.remove(jobId);
    }
  }

  static bool _isMethodCallHandlerSet = false;
  static int _jobId = 0;
  static final Map<int, OnExtracting> _onExtractingHandlerByJobId =
      <int, OnExtracting>{};
  static final Map<int, OnZipping> _onZippingHandlerByJobId =
      <int, OnZipping>{};

  static Future<dynamic> _channelMethodCallHandler(MethodCall call) {
    if (call.method == 'progress') {
      Map<String, dynamic> args =
          Map<String, dynamic>.from(call.arguments as Map<String, dynamic>);
      int jobId = args['jobId'] as int? ?? 0;
      ZipEntry zipEntry = ZipEntry.fromMap(args);
      double progress = args['progress'] as double? ?? 0;
      OnExtracting? onExtractHandler = _onExtractingHandlerByJobId[jobId];
      if (onExtractHandler != null) {
        ZipFileOperation result = onExtractHandler(zipEntry, progress);
        return Future<String>.value(_progressOperationToString(result));
      } else {
        OnZipping? onZippingHandler = _onZippingHandlerByJobId[jobId];
        if (onZippingHandler != null) {
          ZipFileOperation result =
              onZippingHandler(zipEntry.name, zipEntry.isDirectory, progress);
          return Future<String>.value(_progressOperationToString(result));
        } else {
          return Future<void>.value();
        }
      }
    }
    return Future<void>.value();
  }
}

enum CompressionMethod { none, deflated }

class ZipEntry {
  const ZipEntry(
      {required this.name,
      required this.isDirectory,
      this.modificationDate,
      this.uncompressedSize,
      this.compressedSize,
      this.crc,
      this.compressionMethod});

  factory ZipEntry.fromMap(Map<String, dynamic> map) {
    return ZipEntry(
      name: map['name'] as String? ?? '',
      isDirectory: (map['isDirectory'] as bool?) == true,
      modificationDate: DateTime.fromMillisecondsSinceEpoch(
          map['modificationDate'] as int? ?? 0),
      uncompressedSize: map['uncompressedSize'] as int?,
      compressedSize: map['compressedSize'] as int?,
      crc: map['crc'] as int?,
      compressionMethod: map['compressionMethod'] == 'none'
          ? CompressionMethod.none
          : CompressionMethod.deflated,
    );
  }

  final String name;
  final bool isDirectory;
  final DateTime? modificationDate;
  final int? uncompressedSize;
  final int? compressedSize;
  final int? crc;
  final CompressionMethod? compressionMethod;
}
