// 🎯 Dart imports:
import 'dart:io';

// 🌎 Project imports:
import 'package:fluttermatic/core/services/logs.dart';

Future<void> writeWorkflowSessionLog(
    File file, LogTypeTag type, String message) async {
  String logType() {
    switch (type) {
      case LogTypeTag.info:
        return 'INFO';
      case LogTypeTag.warning:
        return 'WARNING';
      case LogTypeTag.error:
        return 'ERROR';
      default:
        return 'UNKNOWN';
    }
  }

  String time = DateTime.now().toString();

  await file.writeAsString('\n${logType()}<date_log>$time</date_log>$message',
      mode: FileMode.writeOnlyAppend);
}
