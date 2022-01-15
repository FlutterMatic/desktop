// 🎯 Dart imports:
import 'dart:io';

// 🌎 Project imports:
import 'package:manager/core/libraries/services.dart';

Future<void> writeWorkflowSessionLog(
    File file, LogTypeTag type, String message) async {
  String _type() {
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

  String _time = DateTime.now().toString();

  await file.writeAsString(
      '\n' + _type() + '<date_log>' + _time + '</date_log>' + message,
      mode: FileMode.writeOnlyAppend);
}
