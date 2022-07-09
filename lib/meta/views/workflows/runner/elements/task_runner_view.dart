// 🎯 Dart imports:
import 'dart:async';
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants.dart';
import 'package:fluttermatic/app/enum.dart';
import 'package:fluttermatic/components/widgets/ui/spinner.dart';
import 'package:fluttermatic/core/services/logs.dart';
import 'package:fluttermatic/meta/utils/general/app_theme.dart';
import 'package:fluttermatic/meta/utils/general/extract_pubspec.dart';
import 'package:fluttermatic/meta/views/workflows/actions.dart';
import 'package:fluttermatic/meta/views/workflows/models/workflow.dart';
import 'package:fluttermatic/meta/views/workflows/runner/elements/action_scripts.dart';
import 'package:fluttermatic/meta/views/workflows/runner/models/write_log.dart';

class TaskRunnerView extends StatefulWidget {
  final File logFile;
  final WorkflowTemplate template;
  final List<String> completedActions;
  final WorkflowActionStatus status;
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
    required this.status,
  }) : super(key: key);

  @override
  State<TaskRunnerView> createState() => _TaskRunnerViewState();
}

class _TaskRunnerViewState extends State<TaskRunnerView> {
  final Stopwatch _timeoutStopwatch = Stopwatch();
  int _timeoutMinutes = 0;

  WorkflowActionStatus _status = WorkflowActionStatus.pending;

  // Command Utils
  final List<String> _out = <String>[];
  final List<String> _commands = <String>[];

  int _seconds = 0;

  void _startTimer() {
    Timer.periodic(const Duration(seconds: 1), (Timer t) {
      if (widget.currentAction == widget.action.id && mounted) {
        setState(() => _seconds += 1);
        // Check to see if the timeout has been reached
        if (_timeoutStopwatch.elapsed.inMinutes >= _timeoutMinutes &&
            _timeoutMinutes != 0) {
          _timeoutStopwatch.stop();
          _timeoutStopwatch.reset();
          _timeoutMinutes = 0;
          setState(() => _status = WorkflowActionStatus.timeout);
          // Write a log informing this
          writeWorkflowSessionLog(widget.logFile, LogTypeTag.warning,
                  'Timeout reached for a workflow action: ${widget.action.id}')
              .then((_) {
            widget.onDone();
            t.cancel();
          });
        }

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

  String get _projectPath =>
      widget.dirPath.substring(0, widget.dirPath.indexOf(fmWorkflowDir));

  Future<void> _prepareCommands() async {
    _commands.clear();

    bool isFlutter = false;

    List<String> pubspecLines =
        await File('$_projectPath\\pubspec.yaml').readAsLines();

    isFlutter =
        extractPubspec(lines: pubspecLines, path: '$_projectPath\\pubspec.yaml')
            .isFlutterProject;

    // Analyze project
    if (widget.action.id == WorkflowActionsIds.analyzeDartProject) {
      _commands.addAll(WorkflowActionScripts.analyzeDartProject(isFlutter));
      return;
    }

    // Test project
    if (widget.action.id == WorkflowActionsIds.runProjectTests) {
      _commands.addAll(WorkflowActionScripts.runProjectTests(isFlutter));
      return;
    }

    // Build Web
    if (widget.action.id == WorkflowActionsIds.buildProjectForWeb) {
      _timeoutMinutes = widget.template.webBuildTimeout;
      _commands.addAll(WorkflowActionScripts.buildProjectForWeb(
        mode: widget.template.webBuildMode,
        renderer: widget.template.webRenderer,
      ));
      return;
    }

    // Build for iOS - (This can only be done on a macOS machine)
    if (widget.action.id == WorkflowActionsIds.buildProjectForIOS) {
      // We will skip if this is not a macOS machine.
      if (!Platform.isMacOS) {
        setState(() => _status = WorkflowActionStatus.skipped);
        await writeWorkflowSessionLog(widget.logFile, LogTypeTag.info,
            'Skipped to run build for iOS because you are not on a macOS host.');
        return;
      }

      _timeoutMinutes = widget.template.iOSBuildTimeout;
      _commands.addAll(WorkflowActionScripts.buildProjectForIos(
        widget.template.iOSBuildMode,
      ));
      return;
    }

    // Build for Android
    if (widget.action.id == WorkflowActionsIds.buildProjectForAndroid) {
      _timeoutMinutes = widget.template.androidBuildTimeout;
      _commands.addAll(WorkflowActionScripts.buildProjectForAndroid(
        mode: widget.template.androidBuildMode,
        type: widget.template.androidBuildType,
      ));
      return;
    }

    // Build for Windows - (This can only be done on a Windows machine)
    if (widget.action.id == WorkflowActionsIds.buildProjectForWindows) {
      // We will skip if this is not a Windows machine.
      if (!Platform.isWindows) {
        setState(() => _status = WorkflowActionStatus.skipped);
        await writeWorkflowSessionLog(widget.logFile, LogTypeTag.info,
            'Skipped to run build for Windows because you are not on a Windows host.');
        return;
      }

      _timeoutMinutes = widget.template.windowsBuildTimeout;
      _commands.addAll(WorkflowActionScripts.buildProjectForWindows(
        widget.template.windowsBuildMode,
      ));
      return;
    }

    // Build for macOS - (This can only be done on a macOS machine)
    if (widget.action.id == WorkflowActionsIds.buildProjectForMacOS) {
      // We will skip if this is not a macOS machine.
      if (!Platform.isMacOS) {
        setState(() => _status = WorkflowActionStatus.skipped);
        await writeWorkflowSessionLog(widget.logFile, LogTypeTag.info,
            'Skipped to run build for macOS because you are not on a macOS host.');
        return;
      }

      _timeoutMinutes = widget.template.macosBuildTimeout;
      _commands.addAll(WorkflowActionScripts.buildProjectForMacos(
        widget.template.macosBuildMode,
      ));
      return;
    }

    // Build for Linux - (This can only be done on a Linux machine)
    if (widget.action.id == WorkflowActionsIds.buildProjectForLinux) {
      // We will skip if this is not a Linux machine.
      if (!Platform.isLinux) {
        setState(() => _status = WorkflowActionStatus.skipped);
        await writeWorkflowSessionLog(widget.logFile, LogTypeTag.info,
            'Skipped to run build for Linux because you are not on a Linux host.');
        return;
      }

      _timeoutMinutes = widget.template.linuxBuildTimeout;
      _commands.addAll(WorkflowActionScripts.buildProjectForLinux(
        widget.template.linuxBuildMode,
      ));
      return;
    }

    // Custom Commands
    if (widget.action.id == WorkflowActionsIds.runCustomCommands) {
      await writeWorkflowSessionLog(
          widget.logFile, LogTypeTag.info, 'Running custom commands');
      _commands.addAll(widget.template.customCommands);
      return;
    }
  }

  Future<void> _runAction() async {
    try {
      await _prepareCommands();

      // We will check if preparing commands has decided to skip this action.
      if (_status == WorkflowActionStatus.skipped) {
        widget.onDone();
        return;
      }

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

      // Start the timeout timer
      _timeoutStopwatch.start();

      for (String command in _commands) {
        await logger.file(
            LogTypeTag.info, 'Running command for workflow: $command');

        await shell
            .cd(_projectPath)
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
      opacity: _status == WorkflowActionStatus.running
          ? 1
          : _status == WorkflowActionStatus.skipped
              ? 0.5
              : 0.2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              if (widget.action.id ==
                  WorkflowActionsIds.runCustomCommands) ...<Widget>[
                Tooltip(
                  message: widget.action.description,
                  child: const Icon(Icons.play_circle_outline_rounded),
                ),
                HSeparators.normal(),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(widget.action.name),
                        if (_timeoutMinutes != 0)
                          Text(
                            ' ($_timeoutMinutes minute${_timeoutMinutes > 1 ? 's' : ''} timeout)',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                      ],
                    ),
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
                const Tooltip(
                  padding: EdgeInsets.all(5),
                  message:
                      '''
When a workflow action is skipped, it most likely means that it was 
because this workflow action is not supported on your platform.''',
                  child: Text(
                    'SKIPPED',
                    style: TextStyle(color: kYellowColor),
                  ),
                )
              else if (_status == WorkflowActionStatus.timeout)
                const Text(
                  'TIME',
                  style: TextStyle(color: kRedColor),
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
                  Expanded(
                    child: Text(
                      _out.last,
                      maxLines: 1,
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ),
                  HSeparators.small(),
                  const Spinner(size: 10, thickness: 1),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
