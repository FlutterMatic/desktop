// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:manager/components/dialog_templates/dialog_header.dart';
import 'package:manager/components/widgets/buttons/rectangle_button.dart';
import 'package:manager/components/widgets/ui/dialog_template.dart';
import 'package:manager/components/widgets/ui/snackbar_tile.dart';
import 'package:manager/core/libraries/constants.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:manager/core/libraries/utils.dart';

class ViewWorkflowSessionLogs extends StatefulWidget {
  final String path;
  const ViewWorkflowSessionLogs({Key? key, required this.path})
      : super(key: key);

  @override
  _ViewWorkflowSessionLogsState createState() =>
      _ViewWorkflowSessionLogsState();
}

class _ViewWorkflowSessionLogsState extends State<ViewWorkflowSessionLogs> {
  final List<String> _logs = <String>[];

  Future<void> _loadLogs() async {
    File _logFile = File(widget.path);

    if (!await _logFile.exists()) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        snackBarTile(context, 'This log file no longer exists.',
            type: SnackBarType.error),
      );
      Navigator.pop(context);
      return;
    }

    List<String> logs = await _logFile.readAsLines();

    while (logs.isNotEmpty && logs.first.isEmpty) {
      logs.removeAt(0);
    }

    while (logs.isNotEmpty && logs.last.isEmpty) {
      logs.removeLast();
    }

    setState(() => _logs.addAll(logs));
  }

  @override
  void initState() {
    _loadLogs();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        children: <Widget>[
          const DialogHeader(title: 'Workflow Session Logs'),
          VSeparators.small(),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: Align(
              alignment: Alignment.topCenter,
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (_, int i) {
                  try {
                    if (_logs[i].replaceAll(' ', '').isEmpty) {
                      return VSeparators.small();
                    }

                    String _txt = _logs[i];
                    String _type = 'UNKNOWN';

                    String _startTag = '<date_log>';
                    String _endTag = '</date_log>';

                    if (_txt.startsWith('INFO$_startTag')) {
                      _type = 'INFO';
                    } else if (_txt.startsWith('WARNING$_startTag')) {
                      _type = 'WARNING';
                    } else if (_txt.startsWith('ERROR$_startTag')) {
                      _type = 'ERROR';
                    }

                    String _dateTxt = _txt.substring(
                        _txt.indexOf(_startTag) + _startTag.length,
                        _txt.contains(_endTag) ? _txt.indexOf(_endTag) : null);

                    DateTime? _date = DateTime.tryParse(_dateTxt);

                    String _log;

                    if (_date == null) {
                      _log = _txt;
                    } else {
                      _log = _txt
                          .substring(_txt.indexOf(_endTag) + _endTag.length)
                          .trimLeft();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: SelectableText.rich(
                        TextSpan(
                          children: <TextSpan>[
                            if (_type != 'UNKNOWN')
                              TextSpan(
                                text: '$_type ',
                                style: TextStyle(
                                  color: _type == 'INFO'
                                      ? kGreenColor
                                      : _type == 'WARNING'
                                          ? kYellowColor
                                          : AppTheme.errorColor,
                                ),
                              ),
                            if (_date == null)
                              TextSpan(
                                text: _log,
                                style:
                                    const TextStyle(color: AppTheme.errorColor),
                              )
                            else
                              TextSpan(
                                text:
                                    '${_date.hour < 10 ? '0${_date.hour}' : _date.hour}:${_date.minute < 10 ? '0${_date.minute}' : _date.minute}:${_date.second < 10 ? '0${_date.second}' : _date.second}\n$_log',
                              ),
                          ],
                        ),
                      ),
                    );
                  } catch (_, s) {
                    print(_);
                    logger.file(LogTypeTag.error,
                        'Failed to parse workflow log line message for line $i',
                        stackTraces: s);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: SelectableText(_logs[i]),
                    );
                  }
                },
              ),
            ),
          ),
          VSeparators.normal(),
          RectangleButton(
            width: double.infinity,
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
