// 🎯 Dart imports:
import 'dart:io';
import 'dart:isolate';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:file_selector/file_selector.dart' as file_selector;
import 'package:path_provider/path_provider.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/components/widgets/ui/spinner.dart';
import 'package:fluttermatic/components/widgets/ui/stage_tile.dart';
import 'package:fluttermatic/core/services/logs.dart';

/// Expects the following data:
/// [<String> filePath, <String> fileName, <SendPort> port]
///
/// Returns:
/// True if the file was successfully sent, false otherwise.
Future<void> _generateReportOnIsolate(List<dynamic> data) async {
  SendPort _port = data[0];
  String _basePath = data[1];
  String _filePath = data[2];
  String _fileName = data[3];

  try {
    // Will go to the support directory then to the "logs" directory. Will then
    // merge all the files in it that ends with ".log" and generate a report.
    // When merging, will split inside the file each file by adding the file
    // name original file name.
    //
    // The first line will contain information such as the date and time of the
    // report generation.

    String _dir = _basePath + '\\logs';

    List<FileSystemEntity> _logsDir = Directory(_dir)
        .listSync(recursive: true)
        .where((FileSystemEntity e) => e is File && e.path.endsWith('.log'))
        .toList();

    File _reportFile = File(_filePath + '\\' + _fileName);

    await _reportFile
        .writeAsString('Report generated on ${DateTime.now().toString()}\n\n');

    for (FileSystemEntity logFile in _logsDir) {
      List<String> _logs = <String>[];

      _logs.add(
        '''

---- LOG ----
${logFile.path.split('\\').last.split('.').first}
---- LOG ----

''',
      );

      _logs.addAll(await File(logFile.path).readAsLines());

      await _reportFile.writeAsString(
        _logs.join('\n'),
        mode: FileMode.writeOnlyAppend,
      );
    }

    await logger.file(
        LogTypeTag.info, 'Report generated on ${DateTime.now().toString()}',
        logDir: Directory(_basePath));

    _port.send(true);
    return;
  } catch (_, s) {
    await logger.file(LogTypeTag.error, 'Failed to generate issue report. $_',
        stackTraces: s, logDir: Directory(_basePath));
    _port.send(false);
    return;
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
    try {
      late String _p;

      _p = _savePath!;

      Isolate _i = await Isolate.spawn(_generateReportOnIsolate, <dynamic>[
        _generatePort.sendPort,
        (await getApplicationSupportDirectory()).path,
        _p,
        _fileName,
      ]);

      try {
        if (!_isListening) {
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
                  'Something really weird is happening, and you need to report it! Make an exception and don\'t about uploading a report. Just make sure to describe it well!',
                  type: SnackBarType.error,
                ),
              );
              _i.kill();
              return;
            }

            if (message && mounted) {
              Navigator.pop(context);
              // Opens file viewer app to show the output.
              if (Platform.isWindows) {
                await shell.run('explorer $_p');
              } else if (Platform.isMacOS) {
                await shell.run('open $_p');
              } else if (Platform.isLinux) {
                await shell.run('xdg-open $_p');
              }

              _i.kill();

              await Future<void>.delayed(const Duration(seconds: 5));

              if (mounted) {
                Navigator.pop(context);
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

              _i.kill();
              _generatePort.close();
              return;
            }
          });
        }
      } catch (_) {
        // ..Ignore..
      }

      setState(() => _savePath = null);
    } catch (_, s) {
      await logger.file(LogTypeTag.error, 'Failed to generate issue report. $_',
          stackTraces: s);

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(snackBarTile(
          context, 'Failed to generate issue report. Please try again.',
          type: SnackBarType.error));

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
          const DialogHeader(
            title: 'Generate Report',
            leading: StageTile(stageType: StageType.prerelease),
          ),
          const Text(
            'If you need to create an issue on GitHub, please include the following information:',
          ),
          VSeparators.normal(),
          RoundContainer(
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
                        String? _path = await file_selector.getDirectoryPath(
                            confirmButtonText: 'Report');

                        if (_path != null) {
                          setState(() => _savePath = _path);
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
