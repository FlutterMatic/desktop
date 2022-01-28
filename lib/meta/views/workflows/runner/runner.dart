// 🎯 Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/app/constants/enum.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/buttons/rectangle_button.dart';
import 'package:fluttermatic/components/widgets/ui/beta_tile.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/round_container.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/components/widgets/ui/spinner.dart';
import 'package:fluttermatic/components/widgets/ui/warning_widget.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/views/dialogs/documentation.dart';
import 'package:fluttermatic/meta/views/workflows/actions.dart';
import 'package:fluttermatic/meta/views/workflows/models/workflow.dart';
import 'package:fluttermatic/meta/views/workflows/runner/elements/log_view_builder.dart';
import 'package:fluttermatic/meta/views/workflows/runner/elements/task_runner_view.dart';
import 'package:fluttermatic/meta/views/workflows/runner/logs.dart';
import 'package:fluttermatic/meta/views/workflows/runner/models/write_log.dart';

class WorkflowRunnerDialog extends StatefulWidget {
  final String workflowPath;

  const WorkflowRunnerDialog({
    Key? key,
    required this.workflowPath,
  }) : super(key: key);

  @override
  _WorkflowRunnerDialogState createState() => _WorkflowRunnerDialogState();
}

class _WorkflowRunnerDialogState extends State<WorkflowRunnerDialog> {
  // Workflow Info
  late WorkflowTemplate _template;
  final List<String> _workflowActions = <String>[];
  final List<String> _completedActions = <String>[];

  final Stopwatch _stopwatch = Stopwatch();

  late final File _workflowSessionLogs;

  // Utils
  WorkflowActionStatus _resultType = WorkflowActionStatus.pending;
  bool _loading = true;
  bool _isRunning = false;
  bool _isCompleted = false;
  String _currentActionRunning = 'none';

  Future<void> _loadWorkflow() async {
    try {
      File _workflow = File(widget.workflowPath);

      WorkflowTemplate _workflowTemplate =
          WorkflowTemplate.fromJson(jsonDecode(await _workflow.readAsString()));

      setState(() => _template = _workflowTemplate);

      await logger.file(LogTypeTag.info,
          'Begin loading workflow actions to run workflow. Workflow path: ${_workflow.path}');

      // Ensure that the workflow logs directory exists, and create it if it doesn't.
      // Will also create the log file for this workflow session.
      String _fmatic = 'fmatic';
      String _footPath = '$_fmatic\\${_template.name}.json';

      _workflowSessionLogs = File(
        '${widget.workflowPath.substring(0, widget.workflowPath.indexOf(_footPath) + _fmatic.length)}\\logs\\${_template.name}\\${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}-${DateTime.now().hour}-${DateTime.now().minute}-${DateTime.now().second}.log',
      );

      await _workflowSessionLogs.create(recursive: true);

      await writeWorkflowSessionLog(
          _workflowSessionLogs, LogTypeTag.info, 'Workflow session started.');

      setState(() {
        _workflowActions.addAll(_workflowTemplate.workflowActions);
        _currentActionRunning = _workflowActions.first;
        _loading = false;
      });
    } catch (_, s) {
      await logger.file(LogTypeTag.error,
          'Failed to load workflow: ${widget.workflowPath}: $_',
          stackTraces: s);
      try {
        await writeWorkflowSessionLog(_workflowSessionLogs, LogTypeTag.error,
            'Workflow session failed to initialize.');
      } catch (_, s) {
        await logger.file(
            LogTypeTag.error, 'Failed to write workflow session log: $_',
            stackTraces: s);
      }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        snackBarTile(
          context,
          'Sorry, we failed to load the workflow.',
          type: SnackBarType.error,
        ),
      );
      Navigator.pop(context);
    }
  }

  String _composeTimeElapsed() {
    int _hours = _stopwatch.elapsed.inHours % 24;
    int _minutes = _stopwatch.elapsed.inMinutes % 60;
    int _seconds = _stopwatch.elapsed.inSeconds % 60 % 60;

    String _message = '';

    _message +=
        _hours > 0 ? _hours.toString() + ' hour${_hours == 1 ? '' : 's'}' : '';

    _message += _minutes > 0
        ? _minutes.toString() + ' minute${_minutes == 1 ? '' : 's'}'
        : '';

    if (_message.isNotEmpty) {
      _message += ' and ';
    }

    _message += _seconds > 0
        ? _seconds.toString() + ' second${_seconds == 1 ? '' : 's'}'
        : '';

    return _message;
  }

  @override
  void initState() {
    _loadWorkflow();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await writeWorkflowSessionLog(_workflowSessionLogs, LogTypeTag.warning,
            'Attempted to close workflow session.');
        return false;
      },
      child: DialogTemplate(
        width: 800,
        outerTapExit: false,
        child: Column(
          children: <Widget>[
            DialogHeader(
              title: 'Workflow Runner',
              leading: const BetaTile(),
              canClose: !_isRunning,
            ),
            if (_loading)
              const Padding(padding: EdgeInsets.all(50), child: Spinner())
            else if (!_isRunning && !_isCompleted)
              _WorkflowStartUp(
                template: _template,
                onRun: () {
                  setState(() => _isRunning = true);
                  _stopwatch.start();
                  writeWorkflowSessionLog(_workflowSessionLogs, LogTypeTag.info,
                      'Workflow started running.');
                },
              )
            else if (!_isRunning && _isCompleted) ...<Widget>[
              // If error occurred, show error message, else will show success.
              if (_resultType == WorkflowActionStatus.failed)
                _WorkflowError(
                  logFile: _workflowSessionLogs,
                  path: widget.workflowPath,
                )
              else if (_resultType == WorkflowActionStatus.done)
                _WorkflowSuccess(
                  elapsedTime: _composeTimeElapsed(),
                  template: _template,
                  logFile: _workflowSessionLogs,
                )
            ] else if (_isRunning && !_isCompleted)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _workflowActions.length,
                itemBuilder: (_, int i) {
                  bool _isLast = i == _workflowActions.length - 1;
                  return Padding(
                    padding: EdgeInsets.only(bottom: _isLast ? 0 : 10),
                    child: TaskRunnerView(
                      logFile: _workflowSessionLogs,
                      completedActions: _completedActions,
                      template: _template,
                      action: workflowActionModels.firstWhere(
                          (WorkflowActionModel e) =>
                              e.id == _workflowActions[i]),
                      currentAction: _currentActionRunning,
                      onDone: () async {
                        if (_isCompleted) {
                          return;
                        }

                        if (!_completedActions.contains(_workflowActions[i])) {
                          setState(
                              () => _completedActions.add(_workflowActions[i]));
                        }

                        if (_currentActionRunning == _workflowActions.last &&
                            _workflowActions.length ==
                                _completedActions.length) {
                          await writeWorkflowSessionLog(
                              _workflowSessionLogs,
                              LogTypeTag.info,
                              'Workflow running session completed.');

                          if (mounted) {
                            setState(() {
                              _isRunning = false;
                              _isCompleted = true;
                              _resultType = WorkflowActionStatus.done;
                            });
                          }

                          _stopwatch.stop();
                        } else {
                          await writeWorkflowSessionLog(
                              _workflowSessionLogs,
                              LogTypeTag.info,
                              'Moving to next workflow action: ${_workflowActions[i + 1]}');
                          setState(() =>
                              _currentActionRunning = _workflowActions[i + 1]);
                        }
                      },
                      onError: (String error) {
                        setState(() {
                          _currentActionRunning = 'none';
                          _isCompleted = true;
                          _isRunning = false;
                          _resultType = WorkflowActionStatus.failed;
                        });
                        _stopwatch.stop();
                      },
                      dirPath: widget.workflowPath
                          .substring(0, widget.workflowPath.lastIndexOf('\\')),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _WorkflowStartUp extends StatelessWidget {
  final Function() onRun;
  final WorkflowTemplate template;

  const _WorkflowStartUp({
    Key? key,
    required this.onRun,
    required this.template,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        RoundContainer(
          width: 500,
          color: Colors.blueGrey.withOpacity(0.2),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(template.name),
                    VSeparators.xSmall(),
                    Text(template.description,
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              HSeparators.normal(),
              SvgPicture.asset(Assets.done, color: kGreenColor, height: 20),
            ],
          ),
        ),
        VSeparators.normal(),
        SizedBox(
          width: 500,
          child: informationWidget(
            'You won\'t be able to use FlutterMatic until the workflow is completed.',
            type: InformationType.info,
          ),
        ),
        VSeparators.normal(),
        RectangleButton(
          child: const Text('Start'),
          onPressed: onRun,
        ),
      ],
    );
  }
}

class _WorkflowError extends StatelessWidget {
  final String path;
  final File logFile;

  const _WorkflowError({
    Key? key,
    required this.path,
    required this.logFile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        RoundContainer(
          width: 500,
          height: 230,
          color: Colors.blueGrey.withOpacity(0.2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('.... Click on "Logs" to view entire log'),
              Expanded(
                child: LogViewBuilder(
                  logs: logFile
                      .readAsLinesSync()
                      .sublist(logFile.readAsLinesSync().length - 6),
                ),
              ),
            ],
          ),
        ),
        VSeparators.normal(),
        SizedBox(
          width: 500,
          child: informationWidget(
            'The workflow failed to complete because of some error. Check the logs to see what went wrong.',
            type: InformationType.warning,
          ),
        ),
        VSeparators.normal(),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RectangleButton(
                width: 100,
                child: const Text('Close'),
                onPressed: () {
                  writeWorkflowSessionLog(
                      logFile, LogTypeTag.info, 'Workflow session closed.');
                  Navigator.of(context).pop();
                },
              ),
              HSeparators.small(),
              RectangleButton(
                width: 100,
                child: const Text('Logs'),
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (_) => ViewWorkflowSessionLogs(path: logFile.path),
                  );
                },
              ),
              HSeparators.small(),
              RectangleButton(
                width: 100,
                child: const Text('Re-run'),
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (_) => WorkflowRunnerDialog(workflowPath: path),
                  );
                },
              ),
              HSeparators.small(),
              RectangleButton(
                width: 100,
                child: const Text('View Docs'),
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (_) => const FMaticDocumentationDialog(),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WorkflowSuccess extends StatelessWidget {
  final WorkflowTemplate template;
  final String elapsedTime;
  final File logFile;

  const _WorkflowSuccess({
    Key? key,
    required this.elapsedTime,
    required this.template,
    required this.logFile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        VSeparators.normal(),
        SvgPicture.asset(Assets.done, color: kGreenColor),
        VSeparators.normal(),
        SizedBox(
          width: 500,
          child: Text(
            'Your workflow has completed running. It took $elapsedTime to complete. If you need to check the logs of this workflow run session, you can click to open it.',
            textAlign: TextAlign.center,
          ),
        ),
        VSeparators.normal(),
        RoundContainer(
          width: 500,
          color: Colors.blueGrey.withOpacity(0.2),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(template.name),
                    VSeparators.xSmall(),
                    Text(template.description,
                        style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              HSeparators.normal(),
              RectangleButton(
                width: 100,
                child: const Text('Logs'),
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (_) => ViewWorkflowSessionLogs(path: logFile.path),
                  );
                },
              ),
              HSeparators.normal(),
              RectangleButton(
                width: 100,
                child: const Text('Close'),
                onPressed: () {
                  writeWorkflowSessionLog(
                      logFile, LogTypeTag.info, 'Workflow session closed.');
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
