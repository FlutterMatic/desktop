// 🎯 Dart imports:
import 'dart:io';
import 'dart:isolate';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:file_selector/file_selector.dart' as file_selector;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/core/libraries/services.dart';
import 'package:fluttermatic/core/libraries/widgets.dart';

/// Expects the following data:
/// [<String> filePath, <String> fileName, <SendPort> port]
///
/// Returns:
/// True if the file was successfully sent, false otherwise.
Future<void> _generateReportOnIsolate(List<dynamic> data) async {
  String _basePath = data[0];
  String _filePath = data[1];
  String _fileName = data[2];
  SendPort _port = data[3];

  try {
    // Will go to the support directory then to the "logs" directory. Will then
    // merge all the files in it that ends with ".log" and generate a report.
    // When merging, will split inside the file each file by adding the file
    // name original file name.
    //
    // The first line will contain information such as the date and time of the
    // report generation.

    String _dir = p.join(_basePath, 'logs');
    late File _reportFile;
    Directory _logsDir = Directory(_dir);
    List<FileSystemEntity> logsDirList = <FileSystemEntity>[];
    if (await _logsDir.exists()) {
      _reportFile = File(p.join(_filePath, _fileName));
      if (await _reportFile.exists()) {
        logsDirList = await _logsDir
            .list(recursive: true)
            .where((FileSystemEntity e) => e is File && e.path.endsWith('.log'))
            .toList();
      } else {
        await _reportFile.create(recursive: true);
        logsDirList.add(_reportFile);
      }
    } else {
      await _logsDir.create(recursive: true);
      _reportFile = File(p.join(_filePath, _fileName));
      logsDirList.add(_reportFile);
    }

    await _reportFile
        .writeAsString('Report generated on ${DateTime.now().toString()}\n\n');

    for (FileSystemEntity logFile in logsDirList) {
      List<String> _logs = <String>[];

      _logs.add('---- LOG ---- \n' +
          logFile.path.split('\\').last.replaceAll('.log', '') +
          '\n---- LOG ----\n');

      _logs.addAll(await File(logFile.path).readAsLines());

      await _reportFile.writeAsString(
        _logs.join('\n'),
        mode: FileMode.writeOnlyAppend,
      );
    }

    _port.send(true);
  } catch (_, s) {
    await logger.file(LogTypeTag.error, 'Failed to generate issue report. $_',
        stackTraces: s);
    _port.send(false);
  }
}

class BuildLogsDialog extends StatefulWidget {
  const BuildLogsDialog({Key? key}) : super(key: key);

  @override
  _BuildLogsDialogState createState() => _BuildLogsDialogState();
}

class _BuildLogsDialogState extends State<BuildLogsDialog> {
  final String _timestamp =
      '${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}-${DateTime.now().hour}-${DateTime.now().minute}-${DateTime.now().second}';

  late final String _fileName = 'fm_report_$_timestamp.log';

  String? _savePath;

  static final ReceivePort _generatePort =
      ReceivePort('GENERATE_REPORT_ISOLATE_PORT');

  bool _isListening = false;

  Future<void> _generateReport() async {
    Directory _appDir = await getApplicationSupportDirectory();
    try {
      await Isolate.spawn(_generateReportOnIsolate, <dynamic>[
        _appDir.path,
        _savePath,
        _fileName,
        _generatePort.sendPort
      ]);
      if (mounted && !_isListening) {
        _generatePort.asBroadcastStream(onListen: (_) {
          if (mounted) {
            setState(() => _isListening = true);
          }
        }).listen((dynamic message) async {
          if (message is bool == false && mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              snackBarTile(
                context,
                'Something really weird is happening, and you need to report it!',
                type: SnackBarType.error,
              ),
            );
            return;
          }

          if (message && mounted) {
            Navigator.pop(context);
            await Future<void>.delayed(const Duration(seconds: 5));
            // Opens file viewer app to show the output.
            if (Platform.isWindows) {
              await shell.run('start ${_savePath!}');
            } else if (Platform.isMacOS) {
              await shell.run('open ${_savePath!}');
            } else if (Platform.isLinux) {
              await shell.run('xdg-open ${_savePath!}');
            }
            _generatePort.close();
            return;
          } else if (mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              snackBarTile(
                context,
                'Failed to generate issue report. Please try again.',
                type: SnackBarType.error,
              ),
            );
            setState(() => _savePath = null);
            return;
          }
        });
      } else {
        await logger.file(LogTypeTag.error, 'Failed to generate issue report.');
      }
    } catch (_, s) {
      await logger.file(LogTypeTag.error, 'Failed to generate issue report. $_',
          stackTraces: s);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        snackBarTile(
          context,
          'Failed to generate issue report. Please try again.',
          type: SnackBarType.error,
        ),
      );
      setState(() => _savePath = null);
    }
  }

  @override
  void dispose() {
    _generatePort.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        children: <Widget>[
          const DialogHeader(title: 'Generate Report'),
          const Text(
            'If you need to create an issue on GitHub, please include the following information:',
          ),
          VSeparators.normal(),
          RoundContainer(
            color: Colors.blueGrey.withOpacity(0.2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                          'Select where you want to save the report as "$_fileName".'),
                    ),
                    HSeparators.normal(),
                    RectangleButton(
                      width: 100,
                      disable: _savePath != null,
                      child: const Text('Select Path'),
                      onPressed: () async {
                        String? _info = await file_selector.getDirectoryPath(
                          confirmButtonText: 'Select Path',
                        );

                        if (_info != null) {
                          setState(() => _savePath = _info);
                          await _generateReport();
                        } else {
                          ScaffoldMessenger.of(context).clearSnackBars();
                          ScaffoldMessenger.of(context).showSnackBar(
                            snackBarTile(
                              context,
                              'Please select a directory path to save report to.',
                              type: SnackBarType.warning,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
                if (_savePath != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            _savePath!,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                        HSeparators.normal(),
                        const Spinner(size: 15, thickness: 2),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          VSeparators.normal(),
          RectangleButton(
            width: double.infinity,
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
