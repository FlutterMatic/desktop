// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/buttons/square_button.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/information_widget.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/views/setup/components/loading_indicator.dart';
import 'package:fluttermatic/meta/views/tabs/sections/projects/projects.dart';
import 'package:fluttermatic/meta/views/workflows/models/workflow.dart';
import 'package:fluttermatic/meta/views/workflows/runner/logs.dart';
import 'package:fluttermatic/meta/views/workflows/runner/runner.dart';

class ShowWorkflowLogHistory extends StatefulWidget {
  final WorkflowTemplate workflow;

  const ShowWorkflowLogHistory({
    Key? key,
    required this.workflow,
  }) : super(key: key);

  @override
  _ShowWorkflowLogHistoryState createState() => _ShowWorkflowLogHistoryState();
}

class _ShowWorkflowLogHistoryState extends State<ShowWorkflowLogHistory> {
  final List<String> _logs = <String>[];

  // More than this number of days is considered to be an old log.
  static const int _oldestLogs = 30;

  Future<void> _cleanOldLogs() async {
    try {
      // ignore: unawaited_futures
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => DialogTemplate(
          width: 300,
          outerTapExit: false,
          child: hLoadingIndicator(),
        ),
      );

      if (_logs.isEmpty) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          snackBarTile(
            context,
            'There are no logs for this workflow.',
            type: SnackBarType.warning,
          ),
        );
        return;
      }

      List<DateTime> logsDates = <DateTime>[];

      for (String log in _logs) {
        List<int> times = log.split('-').map(int.parse).toList();
        DateTime date = DateTime(
            times[0], times[1], times[2], times[3], times[4], times[5]);

        logsDates.add(date);
      }

      // Removes the logs older than 1 month
      logsDates.removeWhere((DateTime date) =>
          DateTime.now().difference(date).inDays < _oldestLogs);

      // Checks to see if any log is older than 1 month
      if (logsDates.isEmpty) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          snackBarTile(
            context,
            'There are no old logs for this workflow. Old logs are logs older than $_oldestLogs days.',
            type: SnackBarType.done,
          ),
        );

        Navigator.pop(context);
        return;
      }

      for (DateTime logDate in logsDates) {
        String date =
            '${logDate.year}-${logDate.month}-${logDate.day}-${logDate.hour}-${logDate.minute}-${logDate.second}.log';
        String path = '${widget.workflow}\\$date';

        if (await File(path).exists()) {
          await File(path).delete();
        }
      }

      await logger.file(LogTypeTag.info,
          'Cleaned old logs for ${widget.workflow} with a total of ${logsDates.length} logs.');

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          snackBarTile(
            context,
            'Cleaned old logs for ${widget.workflow} with a total of ${logsDates.length} log${logsDates.length > 1 ? 's' : ''}.',
            type: SnackBarType.done,
          ),
        );
      }

      if (mounted) {
        setState(_logs.clear);
      }

      await _loadLogs();

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e, s) {
      await logger.file(LogTypeTag.error, 'Failed to clean old logs.',
          error: e, stackTrace: s);

      if (mounted) {
        Navigator.pop(context);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          snackBarTile(
            context,
            'Failed to clean old logs. Please try again.',
            type: SnackBarType.error,
          ),
        );
      }
    }
  }

  Future<void> _loadLogs() async {
    String dir =
        '${(widget.workflow.workflowPath.split('\\')..removeLast()).join('\\')}\\logs\\${widget.workflow.workflowPath.split('\\').last.split('.').first}';

    if (!await Directory(dir).exists()) {
      setState(_logs.clear);

      return;
    }

    List<FileSystemEntity> workflowLogs = Directory(dir).listSync();

    for (FileSystemEntity log in workflowLogs) {
      if (log is File) {
        setState(
            () => _logs.add(log.path.split('\\').last.replaceAll('.log', '')));
      }
    }
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
          DialogHeader(
            title: 'Logs History - ${_logs.length}',
            leading: _logs.isEmpty
                ? null
                : SquareButton(
                    color: Colors.transparent,
                    tooltip: 'Clear Old Logs',
                    icon: const Icon(Icons.cleaning_services_rounded, size: 18),
                    onPressed: _cleanOldLogs,
                  ),
          ),
          if (_logs.isEmpty) ...<Widget>[
            informationWidget(
                'There are no logs for this workflow. Try running this workflow to get logs for it.'),
            VSeparators.normal(),
            Row(
              children: <Widget>[
                Expanded(
                  child: RectangleButton(
                    width: double.infinity,
                    child: const Text('Close'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                HSeparators.normal(),
                Expanded(
                  child: RectangleButton(
                    width: double.infinity,
                    child: const Text('Run'),
                    onPressed: () {
                      Navigator.pop(context);

                      showDialog(
                        context: context,
                        builder: (_) =>
                            WorkflowRunnerDialog(workflow: widget.workflow),
                      );
                    },
                  ),
                ),
              ],
            )
          ] else ...<Widget>[
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (_, int i) {
                  bool isLast = i == _logs.length - 1;

                  return Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
                    child: _LogTile(
                      log: _logs[i],
                      workflow: widget.workflow,
                      onDelete: () async {
                        await File(
                                '${(widget.workflow.workflowPath.split('\\')..removeLast()).join('\\')}\\logs\\${widget.workflow.name}\\${_logs[i]}.log')
                            .delete(recursive: true);

                        await logger.file(LogTypeTag.info,
                            'Deleted log ${_logs[i]} for ${widget.workflow}');

                        if (mounted) {
                          setState(() => _logs.removeAt(i));
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            VSeparators.normal(),
            RectangleButton(
              width: double.infinity,
              child: const Text('Close'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ],
      ),
    );
  }
}

class _LogTile extends StatefulWidget {
  final String log;
  final WorkflowTemplate workflow;
  final Function() onDelete;

  const _LogTile({
    Key? key,
    required this.log,
    required this.workflow,
    required this.onDelete,
  }) : super(key: key);

  @override
  __LogTileState createState() => __LogTileState();
}

class __LogTileState extends State<_LogTile> {
  late final List<int> _log = widget.log.split('-').map(int.parse).toList();
  late final DateTime _date =
      DateTime(_log[0], _log[1], _log[2], _log[3], _log[4], _log[5]);

  bool _isHovering = false;

  String _addZero(int value) => value < 10 ? '0$value' : '$value';

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: RoundContainer(
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                          '${toMonth(_date.month)}, ${_addZero(_date.day)} ${_addZero(_date.hour)}:${_addZero(_date.minute)}:${_addZero(_date.second)}'),
                      HSeparators.xSmall(),
                      Text(
                        _date.year.toString(),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  VSeparators.xSmall(),
                  Text(
                    widget.log + (_isHovering ? '.log' : ''),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (_isHovering) ...<Widget>[
              SquareButton(
                size: 30,
                tooltip: 'Delete',
                icon: const Icon(Icons.delete_forever,
                    color: kRedColor, size: 18),
                onPressed: widget.onDelete,
              ),
              HSeparators.small(),
              SquareButton(
                size: 30,
                tooltip: 'Open Log',
                icon: const Icon(Icons.preview_rounded, size: 18),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => ViewWorkflowSessionLogs(
                        logPath:
                            '${(widget.workflow.workflowPath.split('\\')..removeLast()).join('\\')}\\logs\\${widget.workflow.name}\\${widget.log}.log'),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
