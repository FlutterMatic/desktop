// 🎯 Dart imports:
import 'dart:io';
import 'dart:isolate';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:file_selector/file_selector.dart' as file_selector;
import 'package:path_provider/path_provider.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/load_activity_msg.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/components/widgets/ui/stage_tile.dart';
import 'package:fluttermatic/core/services/logs.dart';

/// Expects the following data:
/// [<String> filePath, <String> fileName, <SendPort> port]
///
/// Returns:
/// True if the file was successfully sent, false otherwise.
Future<bool> _generateReportOnIsolate(Map<String, dynamic> data) async {
  try {
    ReceivePort receivePort = ReceivePort();

    await Isolate.spawn((Map<String, dynamic> message) async {
      String basePath = message['basePath'];
      String filePath = message['filePath'];
      String fileName = message['fileName'];

      // Will go to the support directory then to the "logs" directory. Will then
      // merge all the files in it that ends with ".log" and generate a report.
      // When merging, will split inside the file each file by adding the file
      // name original file name.
      //
      // The first line will contain information such as the date and time of the
      // report generation.
      String dir = '$basePath\\logs';

      List<FileSystemEntity> logsDir = Directory(dir)
          .listSync(recursive: true)
          .where((e) => e is File && e.path.endsWith('.log'))
          .toList();

      if (logsDir.isEmpty) {
        Isolate.exit(message['port'], true);
      }

      File reportFile = File('$filePath\\$fileName');

      await reportFile.writeAsString(
          'Report generated on ${DateTime.now().toString()}\n\n');

      for (FileSystemEntity logFile in logsDir) {
        List<String> logs = <String>[];

        logs.add(
            '''

---- LOG ----
${logFile.path.split('\\').last.split('.').first}
---- LOG ----

''');

        logs.addAll(await File(logFile.path).readAsLines());

        await reportFile.writeAsString(
          logs.join('\n'),
          mode: FileMode.writeOnlyAppend,
        );
      }

      await logger.file(
          LogTypeTag.info, 'Report generated on ${DateTime.now().toString()}',
          logDir: Directory(basePath));

      Isolate.exit(message['port'], true);
    }, {
      'basePath': data['basePath'],
      'filePath': data['filePath'],
      'fileName': data['fileName'],
      'port': receivePort.sendPort,
    });

    return (await receivePort.first as bool?) ?? false;
  } catch (e, s) {
    await logger.file(LogTypeTag.error, 'Failed to generate issue report.',
        error: e, stackTrace: s);

    return false;
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

  Future<void> _generateReport() async {
    try {
      late String p;

      p = _savePath!;

      await Future.delayed(const Duration(seconds: 10));

      bool result = await _generateReportOnIsolate({
        'basePath': (await getApplicationSupportDirectory()).path,
        'filePath': p,
        'fileName': _fileName,
      });

      if (!result && mounted) {
        Navigator.pop(context);

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          snackBarTile(
            context,
            'Something really weird is happening, and you need to report it! You can find the logs at ${(await getApplicationSupportDirectory()).path}\\logs',
            type: SnackBarType.error,
          ),
        );
      } else if (result && mounted) {
        Navigator.pop(context);

        // Opens file viewer app to show the output.
        if (Platform.isWindows) {
          await shell.run('explorer $p');
        } else if (Platform.isMacOS) {
          await shell.run('open $p');
        } else if (Platform.isLinux) {
          await shell.run('xdg-open $p');
        }

        return;
      }

      setState(() => _savePath = null);
    } catch (e, s) {
      await logger.file(LogTypeTag.error, 'Failed to generate issue report.',
          error: e, stackTrace: s);

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(snackBarTile(
            context, 'Failed to generate issue report. Please try again.',
            type: SnackBarType.error));

        setState(() => _savePath = null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.value(_savePath == null),
      child: DialogTemplate(
        outerTapExit: _savePath == null,
        child: Column(
          children: <Widget>[
            DialogHeader(
              title: 'Generate Report',
              leading: const StageTile(stageType: StageType.beta),
              canClose: _savePath == null,
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
                          String? path = await file_selector.getDirectoryPath(
                              confirmButtonText: 'Report');

                          if (path != null) {
                            setState(() => _savePath = path);
                            await _generateReport();
                          } else if (mounted) {
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
                      child: Text(
                        _savePath!,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                ],
              ),
            ),
            VSeparators.normal(),
            if (_savePath == null)
              RectangleButton(
                width: double.infinity,
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              )
            else
              const LoadActivityMessageElement(message: 'Generating report...'),
          ],
        ),
      ),
    );
  }
}
