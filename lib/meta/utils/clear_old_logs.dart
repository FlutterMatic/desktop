// 🎯 Dart imports:
import 'dart:io';
import 'dart:isolate';

// 🌎 Project imports:
import 'package:fluttermatic/core/services/logs.dart';

const int _oldLogDays = 30;

Future<void> clearOldLogs(List<dynamic> data) async {
  SendPort _port = data[0];
  String _path = data[1];

  try {
    Directory _dir = Directory(_path + '\\logs');

    // Gets and parses the name of each file.
    List<String> _fileNames = (await _dir.list().toList())
        .map((FileSystemEntity e) => e.path)
        .toList();

    // Remove the files that are older than 30 days
    _fileNames.removeWhere((String element) {
      try {
        String _date = element.split('.').first;

        List<String> _split = _date.split('-');

        DateTime _dateTime = DateTime(
          int.parse(_split[_split.length - 3]),
          int.parse(_split[_split.length - 2]),
          int.parse(_split[_split.length - 1]),
        );

        return DateTime.now().difference(_dateTime).inDays < _oldLogDays;
      } catch (_, s) {
        logger.file(LogTypeTag.error,
            'Failed to parse date time to delete old logs: $_',
            stackTraces: s, logDir: Directory(_path));
        return false;
      }
    });

    // Now delete the files that are older than 30 days
    for (String file in _fileNames) {
      File _file = File(file);

      await _file.delete();
    }

    if (_fileNames.isNotEmpty) {
      await logger.file(LogTypeTag.info,
          'Deleted old logs with a total of ${_fileNames.length} log(s)',
          logDir: Directory(_path));
    }

    _port.send(true);
  } catch (_, s) {
    await logger.file(LogTypeTag.error, 'Failed to delete old logs: $_',
        stackTraces: s, logDir: Directory(_path));
    _port.send(false);
  }
}
