// 🎯 Dart imports:
import 'dart:async';
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:manager/core/libraries/constants.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:manager/core/libraries/utils.dart';
import 'package:manager/core/libraries/widgets.dart';
import 'package:manager/meta/views/workflows/actions.dart';
import 'package:manager/meta/views/workflows/models/workflow.dart';
import 'package:manager/meta/views/workflows/runner/models/write_log.dart';

class TaskRunnerView extends StatefulWidget {
  final File logFile;
  final WorkflowTemplate template;
  final List<String> completedActions;
  final WorkflowActionModel action;
  final String currentAction;
  final Function onDone;
  final Function onError;
  final String dirPath;

  const TaskRunnerView({
    Key? key,
    required this.action,
    required this.currentAction,
    required this.template,
    required this.onDone,
    required this.dirPath,
    required this.completedActions,
    required this.logFile,
    required this.onError,
  }) : super(key: key);

  @override
  State<TaskRunnerView> createState() => _TaskRunnerViewState();
}

class _TaskRunnerViewState extends State<TaskRunnerView> {
  WorkflowActionStatus _status = WorkflowActionStatus.pending;

  // Command Utils
  final List<String> _out = <String>[];
  final List<String> _commands = <String>[];

  int _seconds = 0;

  void _startTimer() {
    Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (widget.currentAction == widget.action.id && mounted) {
        setState(() => _seconds += 1);
        if (_status == WorkflowActionStatus.done ||
            widget.completedActions.contains(widget.action.id)) {
          t.cancel();
        }
        if (_status == WorkflowActionStatus.pending) {
          setState(() => _status = WorkflowActionStatus.running);
          _runAction();
        }
      }
    });
  }

  void _prepareCommands() {
    _commands.clear();

    if (widget.action.id == WorkflowActionsIds.analyzeDartProject) {
      _commands.add('dart analyze');
      _commands.add('flutter analyze');
      return;
    }

    if (widget.action.id == WorkflowActionsIds.runProjectTests) {
      _commands.add('flutter test');
      return;
    }

    if (widget.action.id == WorkflowActionsIds.buildProjectForWeb) {
      _commands.add('flutter clean');
      _commands.add('flutter pub get');
      _commands.add(
          'flutter build web --${widget.template.iOSBuildMode.name} --web-renderer ${widget.template.defaultWebRenderer.name}');
      return;
    }

    if (widget.action.id == WorkflowActionsIds.buildProjectForIOS) {
      _commands.add('flutter clean');
      _commands.add('flutter pub get');
      _commands.add('flutter build ios --${widget.template.iOSBuildMode.name}');
      return;
    }

    if (widget.action.id == WorkflowActionsIds.buildProjectForAndroid) {
      _commands.add('flutter clean');
      _commands.add('flutter pub get');
      _commands.add(
          'flutter build android --${widget.template.androidBuildMode.name}');
      return;
    }
  }

  Future<void> _runAction() async {
    try {
      _prepareCommands();

      await writeWorkflowSessionLog(widget.logFile, LogTypeTag.info,
          'Prepared workflow commands: $_commands');

      if (_commands.isEmpty && mounted) {
        setState(() => _status = WorkflowActionStatus.skipped);
        await writeWorkflowSessionLog(widget.logFile, LogTypeTag.warning,
            'No commands found, skipping...');
        widget.onDone();
        return;
      }

      if (mounted) {
        setState(() => _status = WorkflowActionStatus.running);
      }

      for (String command in _commands) {
        await logger.file(
            LogTypeTag.info, 'Running command for workflow: $command');
        await shell
            .cd(widget.dirPath.substring(0, widget.dirPath.indexOf('fmatic')))
            .run(command)
            .asStream()
            .listen(
              (List<ProcessResult> line) {
                writeWorkflowSessionLog(
                    widget.logFile,
                    LogTypeTag.info,
                    line
                        .map((ProcessResult e) => e.stdout.toString())
                        .join(','));
                if (mounted) {
                  setState(() => _out.add(line.last.stdout.toString()));
                }
              },
            )
            .asFuture()
            .catchError((_) {
              writeWorkflowSessionLog(widget.logFile, LogTypeTag.error,
                  'Error running command for workflow: $command\n${_.toString().startsWith('ShellException') ? 'Failed to run this command with a none zero exit code' : _.toString()}');
              if (mounted) {
                setState(() => _status = WorkflowActionStatus.failed);
              }
              widget.onError(
                  'Failed to complete this workflow action because of an error.');
            });
      }

      if (_status == WorkflowActionStatus.failed) {
        return;
      }

      if (mounted) {
        setState(() => _status = WorkflowActionStatus.done);
      }

      await writeWorkflowSessionLog(widget.logFile, LogTypeTag.info,
          'Workflow action done running: ${widget.action.id}');

      widget.onDone();
    } catch (_, s) {
      await logger.file(LogTypeTag.error,
          'Error running workflow action: ${_commands.join(',')}',
          stackTraces: s);
      await writeWorkflowSessionLog(widget.logFile, LogTypeTag.info,
          'Failed to run workflow action: ${widget.action.id}');
      if (mounted) {
        setState(() => _status = WorkflowActionStatus.failed);
      }
      widget.onDone();
    }
  }

  @override
  void initState() {
    _startTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _status == WorkflowActionStatus.running ? 1 : 0.2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(widget.action.name),
                    VSeparators.xSmall(),
                    Text(
                      widget.action.description,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              HSeparators.normal(),
              // Shows the elapsed time and formats it so that it shows the hours, minutes and seconds.
              Text(
                '${(_seconds ~/ 3600) < 10 ? '0${(_seconds ~/ 3600)}' : (_seconds ~/ 3600)}:${(_seconds ~/ 60) < 10 ? '0${(_seconds ~/ 60)}' : (_seconds ~/ 60)}:${(_seconds % 60) < 10 ? '0${(_seconds % 60)}' : (_seconds % 60)}',
                style: const TextStyle(fontSize: 12),
              ),
              HSeparators.normal(),
              if (_status == WorkflowActionStatus.pending)
                const Text(
                  'PENDING',
                  style: TextStyle(color: Colors.blueGrey),
                )
              else if (_status == WorkflowActionStatus.running)
                const Text(
                  'RUNNING',
                  style: TextStyle(color: kGreenColor),
                )
              else if (_status == WorkflowActionStatus.warning)
                const Text(
                  'WARNING',
                  style: TextStyle(color: kYellowColor),
                )
              else if (_status == WorkflowActionStatus.done)
                const Text(
                  'DONE',
                  style: TextStyle(color: kGreenColor),
                )
              else if (_status == WorkflowActionStatus.skipped)
                const Text(
                  'SKIPPED',
                  style: TextStyle(color: kYellowColor),
                )
              else if (_status == WorkflowActionStatus.failed)
                const Text(
                  'FAILED',
                  style: TextStyle(color: AppTheme.errorColor),
                ),
            ],
          ),
          if (_status == WorkflowActionStatus.running && _out.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: <Widget>[
                  const Spinner(size: 10, thickness: 1),
                  HSeparators.small(),
                  Expanded(
                    child: Text(
                      _out.last,
                      maxLines: 1,
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
