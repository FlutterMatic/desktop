// 🎯 Dart imports:
import 'dart:io';
import 'dart:isolate';

// 🌎 Project imports:
import 'package:fluttermatic/core/services/logs.dart';

const int _oldLogDays = 30;

Future<void> clearOldLogs(List<dynamic> data) async {
  SendPort port = data[0];
  String path = data[1];

  try {
    Directory dir = Directory('$path\\logs');

    // Gets and parses the name of each file.
    List<String> fileNames = (await dir.list().toList())
        .map((FileSystemEntity e) => e.path)
        .toList();

    // Remove the files that are older than 30 days
    fileNames.removeWhere((String element) {
      try {
        String date = (element.split('.')..removeLast()).join('.');

        List<String> split = date.split('-');

        DateTime dateTime = DateTime(
          int.tryParse(split[split.length - 3]) ?? DateTime.now().year,
          int.tryParse(split[split.length - 2]) ?? DateTime.now().month,
          int.tryParse(split[split.length - 1]) ?? DateTime.now().day,
        );

        return DateTime.now().difference(dateTime).inDays < _oldLogDays;
      } catch (e, s) {
        logger.file(LogTypeTag.error,
            'Failed to parse date time to delete old logs and the file name was: $element.',
            error: e, stackTrace: s, logDir: Directory(path));

        return false;
      }
    });

    // Now delete the files that are older than 30 days
    for (String path in fileNames) {
      File file = File(path);

      await file.delete();
    }

    if (fileNames.isNotEmpty) {
      await logger.file(LogTypeTag.info,
          'Deleted old logs with a total of ${fileNames.length} log(s).',
          logDir: Directory(path));
    }

    port.send(true);
    return;
  } catch (e, s) {
    await logger.file(LogTypeTag.error, 'Failed to delete old logs.',
        error: e, stackTrace: s, logDir: Directory(path));

    port.send(false);
    return;
  }
}
