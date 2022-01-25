// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/buttons/square_button.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/core/libraries/components.dart';
import 'package:fluttermatic/core/libraries/services.dart';
import 'package:fluttermatic/core/libraries/views.dart';
import 'package:fluttermatic/meta/views/workflows/runner/logs.dart';
import 'package:fluttermatic/meta/views/workflows/runner/runner.dart';

class ShowWorkflowLogHistory extends StatefulWidget {
  final String workflowPath;
  const ShowWorkflowLogHistory({
    Key? key,
    required this.workflowPath,
  }) : super(key: key);

  @override
  _ShowWorkflowLogHistoryState createState() => _ShowWorkflowLogHistoryState();
}

class _ShowWorkflowLogHistoryState extends State<ShowWorkflowLogHistory> {
  final List<String> _logs = <String>[];
  final List<String> _workflowPaths = <String>[];

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

      List<DateTime> _logsDates = <DateTime>[];

      for (String log in _logs) {
        List<int> _times = log.split('-').map(int.parse).toList();
        DateTime _date = DateTime(
            _times[0], _times[1], _times[2], _times[3], _times[4], _times[5]);

        _logsDates.add(_date);
      }

      // Removes the logs older than 1 month
      _logsDates.removeWhere((DateTime date) =>
          DateTime.now().difference(date).inDays < _oldestLogs);

      // Checks to see if any log is older than 1 month
      if (_logsDates.isEmpty) {
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

      for (DateTime date in _logsDates) {
        String _date =
            '${date.year}-${date.month}-${date.day}-${date.hour}-${date.minute}-${date.second}.log';
        String _path = '${widget.workflowPath}\\$_date';

        if (await File(_path).exists()) {
          await File(_path).delete();
        }
      }

      await logger.file(LogTypeTag.info,
          'Cleaned old logs for ${widget.workflowPath} with a total of ${_logsDates.length} logs.');

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        snackBarTile(
          context,
          'Cleaned old logs for ${widget.workflowPath} with a total of ${_logsDates.length} log${_logsDates.length > 1 ? 's' : ''}.',
          type: SnackBarType.done,
        ),
      );

      if (mounted) {
        setState(() {
          _logs.clear();
          _workflowPaths.clear();
        });
      }

      _loadLogs();

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (_, s) {
      await logger.file(LogTypeTag.error, 'Failed to clean old logs: $_',
          stackTraces: s);

      if (mounted) {
        Navigator.pop(context);
      }

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

  void _loadLogs() {
    String _dir = (widget.workflowPath.split('\\')..removeLast()).join('\\') +
        '\\logs' +
        '\\${widget.workflowPath.split('\\').last.replaceAll('.json', '')}';

    List<FileSystemEntity> _workflowLogs = Directory(_dir).listSync();

    for (FileSystemEntity log in _workflowLogs) {
      if (log is File) {
        _logs.add(log.path.split('\\').last.replaceAll('.log', ''));
        _workflowPaths.add(log.path);
      }
    }

    setState(() {});
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
            title: 'Logs History',
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
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder<Route<Widget>>(
                          transitionDuration: Duration.zero,
                          pageBuilder: (_, __, ___) => const HomeScreen(index: 1),
                        ),
                      );

                      showDialog(
                        context: context,
                        builder: (_) => WorkflowRunnerDialog(
                            workflowPath: widget.workflowPath),
                      );
                    },
                  ),
                ),
              ],
            )
          ] else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: ListView.builder(
                itemCount: _logs.length,
                itemBuilder: (_, int i) {
                  bool _isLast = i == _logs.length - 1;
                  return Padding(
                    padding: EdgeInsets.only(bottom: _isLast ? 0 : 10),
                    child: _LogTile(
                      log: _logs[i],
                      workflowPath: _workflowPaths[i],
                      onDelete: () async {
                        await File(_workflowPaths[i]).delete(recursive: true);

                        await logger.file(LogTypeTag.info,
                            'Deleted log ${_logs[i]} for ${widget.workflowPath}');

                        if (mounted) {
                          setState(() {
                            _logs.removeAt(i);
                            _workflowPaths.removeAt(i);
                          });
                        }
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _LogTile extends StatefulWidget {
  final String log;
  final String workflowPath;
  final Function() onDelete;

  const _LogTile({
    Key? key,
    required this.log,
    required this.workflowPath,
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
        color: Colors.blueGrey.withOpacity(0.2),
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
                    color: kRedColor, size: 20),
                onPressed: widget.onDelete,
              ),
              HSeparators.small(),
              SquareButton(
                size: 30,
                tooltip: 'Open Log',
                icon: const Icon(Icons.preview_rounded, size: 20),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) =>
                        ViewWorkflowSessionLogs(path: widget.workflowPath),
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
