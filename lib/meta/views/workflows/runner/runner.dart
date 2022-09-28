// 🎯 Dart imports:
import 'dart:async';
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/app/enum.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/components/widgets/buttons/square_button.dart';
import 'package:fluttermatic/components/widgets/ui/dialog_template.dart';
import 'package:fluttermatic/components/widgets/ui/snackbar_tile.dart';
import 'package:fluttermatic/components/widgets/ui/spinner.dart';
import 'package:fluttermatic/components/widgets/ui/stage_tile.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/general/app_theme.dart';
import 'package:fluttermatic/meta/views/workflows/actions.dart';
import 'package:fluttermatic/meta/views/workflows/models/workflow.dart';
import 'package:fluttermatic/meta/views/workflows/runner/elements/task_runner_view.dart';
import 'package:fluttermatic/meta/views/workflows/runner/models/write_log.dart';
import 'package:fluttermatic/meta/views/workflows/runner/status/error.dart';
import 'package:fluttermatic/meta/views/workflows/runner/status/startup.dart';
import 'package:fluttermatic/meta/views/workflows/runner/status/stopped.dart';
import 'package:fluttermatic/meta/views/workflows/runner/status/success.dart';
import 'package:fluttermatic/meta/views/workflows/startup.dart';

class WorkflowRunnerDialog extends StatefulWidget {
  final WorkflowTemplate workflow;

  const WorkflowRunnerDialog({
    Key? key,
    required this.workflow,
  }) : super(key: key);

  @override
  _WorkflowRunnerDialogState createState() => _WorkflowRunnerDialogState();
}

class _WorkflowRunnerDialogState extends State<WorkflowRunnerDialog> {
  // Workflow Info
  late String workflowPath;
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
      if (!widget.workflow.isSaved) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(snackBarTile(
            context,
            'This workflow is still in edit more. Finish saving this workflow before you can run it.',
            type: SnackBarType.warning,
          ));
        }
        // ignore: unawaited_futures
        showDialog(
          context: context,
          builder: (_) => StartUpWorkflow(
            pubspecPath: '${(widget.workflow.workflowPath.split('\\')
              ..removeLast()
              ..removeLast()).join('\\')}\\pubspec.yaml',
            workflow: widget.workflow,
          ),
        );
        return;
      }

      await logger.file(LogTypeTag.info,
          'Begin loading workflow actions to run workflow. Workflow path: ${widget.workflow.workflowPath}');

      // Ensure that the workflow logs directory exists, and create it if it doesn't.
      // Will also create the log file for this workflow session.
      String footPath = '$fmWorkflowDir\\${widget.workflow.name}.json';

      _workflowSessionLogs = File(
        '${widget.workflow.workflowPath.substring(0, widget.workflow.workflowPath.indexOf(footPath) + fmWorkflowDir.length)}\\logs\\${widget.workflow.name}\\${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}-${DateTime.now().hour}-${DateTime.now().minute}-${DateTime.now().second}.log',
      );

      await _workflowSessionLogs.create(recursive: true);

      await writeWorkflowSessionLog(
          _workflowSessionLogs, LogTypeTag.info, 'Workflow session started.');

      setState(() {
        _workflowActions.addAll(widget.workflow.workflowActions);
        _currentActionRunning = _workflowActions.first;
        _loading = false;
      });
    } catch (_, s) {
      await logger.file(
          LogTypeTag.error, 'Failed to load workflow: ${widget.workflow}: $_',
          stackTraces: s);
      try {
        await writeWorkflowSessionLog(_workflowSessionLogs, LogTypeTag.error,
            'Workflow session failed to initialize.');
      } catch (_, s) {
        await logger.file(
            LogTypeTag.error, 'Failed to write workflow session log: $_',
            stackTraces: s);
      }

      if (mounted) {
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
  }

  String _composeTimeElapsed() {
    int hours = _stopwatch.elapsed.inHours % 24;
    int minutes = _stopwatch.elapsed.inMinutes % 60;
    int seconds = _stopwatch.elapsed.inSeconds % 60 % 60;

    String message = '';

    message += hours > 0 ? '$hours hour${hours == 1 ? '' : 's'}' : '';

    message += minutes > 0 ? '$minutes minute${minutes == 1 ? '' : 's'}' : '';

    if (message.isNotEmpty) {
      message += ' and ';
    }

    message += seconds > 0 ? '$seconds second${seconds == 1 ? '' : 's'}' : '';

    return message.isEmpty ? 'Just started' : message;
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
              leading: const StageTile(stageType: StageType.alpha),
              canClose: !_isRunning,
            ),
            if (_loading)
              const Padding(padding: EdgeInsets.all(50), child: Spinner())
            else if (!_isRunning && !_isCompleted)
              WorkflowStartUp(
                template: widget.workflow,
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
                WorkflowError(
                  logFile: _workflowSessionLogs,
                  workflow: widget.workflow,
                )
              else if (_resultType == WorkflowActionStatus.stopped)
                WorkflowStopped(
                  logFile: _workflowSessionLogs,
                  workflow: widget.workflow,
                )
              else if (_resultType == WorkflowActionStatus.done)
                WorkflowSuccess(
                  elapsedTime: _composeTimeElapsed(),
                  workflow: widget.workflow,
                  logFile: _workflowSessionLogs,
                )
            ] else if (_isRunning && !_isCompleted) ...<Widget>[
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _workflowActions.length,
                itemBuilder: (_, int i) {
                  bool isLast = i == _workflowActions.length - 1;
                  return Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
                    child: TaskRunnerView(
                      workflow: widget.workflow,
                      status: _resultType,
                      logFile: _workflowSessionLogs,
                      completedActions: _completedActions,
                      action: workflowActionModels.firstWhere(
                          (WorkflowActionModel e) =>
                              e.id == _workflowActions[i]),
                      currentAction: _currentActionRunning,
                      onError: (String error) {
                        setState(() {
                          _currentActionRunning = 'none';
                          _isCompleted = true;
                          _isRunning = false;
                          _resultType = WorkflowActionStatus.failed;
                        });
                        _stopwatch.stop();
                      },
                      dirPath: widget.workflow.workflowPath.substring(
                          0, widget.workflow.workflowPath.lastIndexOf('\\')),
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
                    ),
                  );
                },
              ),
              VSeparators.normal(),
              if (_isRunning)
                Align(
                  alignment: Alignment.centerRight,
                  child: SquareButton(
                    tooltip: 'Stop',
                    icon: const Icon(Icons.stop, color: AppTheme.errorColor),
                    onPressed: () async {
                      _stopwatch.stop();
                      await writeWorkflowSessionLog(
                        _workflowSessionLogs,
                        LogTypeTag.warning,
                        'Workflow session force stopped.',
                      );
                      setState(() {
                        _isRunning = false;
                        _isCompleted = true;
                        _resultType = WorkflowActionStatus.stopped;
                      });
                    },
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
