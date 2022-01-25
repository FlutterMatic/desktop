// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:flutter_svg/flutter_svg.dart';

// 🌎 Project imports:
import 'package:fluttermatic/app/constants/constants.dart';
import 'package:fluttermatic/components/dialog_templates/dialog_header.dart';
import 'package:fluttermatic/core/libraries/services.dart';
import 'package:fluttermatic/core/libraries/utils.dart';
import 'package:fluttermatic/core/libraries/widgets.dart';
import 'package:fluttermatic/meta/views/workflows/models/workflow.dart';
import 'package:fluttermatic/meta/views/workflows/runner/runner.dart';
import 'package:fluttermatic/meta/views/workflows/startup.dart';
import 'package:fluttermatic/meta/views/workflows/views/confirm_delete.dart';
import 'package:fluttermatic/meta/views/workflows/views/log_history.dart';

class ShowExistingWorkflows extends StatefulWidget {
  final String pubspecPath;

  const ShowExistingWorkflows({
    Key? key,
    required this.pubspecPath,
  }) : super(key: key);

  @override
  _ShowExistingWorkflowsState createState() => _ShowExistingWorkflowsState();
}

class _ShowExistingWorkflowsState extends State<ShowExistingWorkflows> {
  bool _errorWorkflows = false;
  bool _loadingWorkflows = true;

  // Workflow Info
  final List<String> _workflowPaths = <String>[];
  final List<WorkflowTemplate> _workflows = <WorkflowTemplate>[];

  Future<void> _loadWorkflows() async {
    try {
      Directory _dir = Directory(widget.pubspecPath + '\\fmatic');
      if (!await _dir.exists()) {
        setState(() => _loadingWorkflows = false);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          snackBarTile(
            context,
            'Create your first workflow for this project.',
          ),
        );
        Navigator.pop(context);
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => StartUpWorkflow(pubspecPath: widget.pubspecPath),
        );
        return;
      }

      List<FileSystemEntity> _files = _dir.listSync(recursive: true);

      _files.where((FileSystemEntity e) => e.path.endsWith('.json'));

      List<String> _paths = <String>[];
      List<WorkflowTemplate> _templates = <WorkflowTemplate>[];

      for (FileSystemEntity e in _files) {
        // Delete the workflow if the name is empty or the file is empty.
        if (e.path.endsWith('.json') && e.existsSync()) {
          String _fileName = e.path.split('\\').last.split('.').first;
          if (_fileName.isEmpty) {
            await logger.file(LogTypeTag.warning,
                'Found a workflow with an empty file name. Deleting this workflow.');
            e.deleteSync();
            continue;
          }

          String _json = File(e.path).readAsStringSync();
          if (_json.isEmpty) {
            await logger.file(
                LogTypeTag.warning, 'Deleted a workflow file that is empty.');
            e.deleteSync();
            continue;
          }

          Map<String, dynamic> _map = jsonDecode(_json);
          if (_map['name'] == null || (_map['name'] as String).isEmpty) {
            await logger.file(
                LogTypeTag.warning, 'Deleted a workflow with an empty name.');
            e.deleteSync();
            continue;
          }

          _paths.add(e.path);
          _templates.add(WorkflowTemplate.fromJson(_map));
        }
      }

      setState(() {
        _workflows.addAll(_templates);
        _workflowPaths.addAll(_paths);
        _loadingWorkflows = false;
      });
    } catch (_, s) {
      await logger.file(LogTypeTag.error,
          'Couldn\'t load workflows for project at path: ${widget.pubspecPath}',
          stackTraces: s);
      setState(() {
        _errorWorkflows = true;
        _loadingWorkflows = false;
      });
    }
  }

  @override
  void initState() {
    _loadWorkflows();
    super.initState();
  }

  @override
  void dispose() {
    _workflows.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        children: <Widget>[
          const DialogHeader(title: 'Workflows'),
          if (_loadingWorkflows)
            const Padding(
              padding: EdgeInsets.all(15),
              child: Spinner(size: 20, thickness: 2),
            )
          else if (_errorWorkflows)
            informationWidget(
              'Failed to load workflows. Something went wrong when we tried to load the workflows for this project. Files may be missing or corrupted.',
              type: InformationType.error,
            )
          else if (_workflows.isEmpty)
            informationWidget(
              'There are no workflows for this project. Create your first workflow for this project.',
              type: InformationType.info,
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 380),
              child: ListView.builder(
                itemCount: _workflows.length,
                shrinkWrap: true,
                itemBuilder: (_, int i) {
                  bool _isLast = i == _workflows.length - 1;
                  return Padding(
                    padding: EdgeInsets.only(bottom: _isLast ? 0 : 5),
                    child: _WorkflowTile(
                      template: _workflows[i],
                      path: _workflowPaths[i],
                      onDelete: () => setState(() {
                        _workflows.removeAt(i);
                        _workflowPaths.removeAt(i);
                      }),
                    ),
                  );
                },
              ),
            ),
          VSeparators.normal(),
          if (!_loadingWorkflows)
            Row(
              children: <Widget>[
                Expanded(
                  child: RectangleButton(
                    child: const Text('Close'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                HSeparators.normal(),
                Expanded(
                  child: RectangleButton(
                    child: const Text('New Workflow'),
                    onPressed: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) =>
                            StartUpWorkflow(pubspecPath: widget.pubspecPath),
                      );
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _WorkflowTile extends StatefulWidget {
  final String path;
  final WorkflowTemplate template;
  final Function() onDelete;

  const _WorkflowTile({
    Key? key,
    required this.template,
    required this.path,
    required this.onDelete,
  }) : super(key: key);

  @override
  __WorkflowTileState createState() => __WorkflowTileState();
}

class __WorkflowTileState extends State<_WorkflowTile> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (_) => setState(() => _isHovering = true),
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: RoundContainer(
        color: Colors.blueGrey.withOpacity(0.2),
        padding: EdgeInsets.zero,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Text(widget.template.name),
              ),
            ),
            if (!widget.template.isSaved)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Tooltip(
                  message:
                      'This workflow is not completed yet. You can edit it, but you will need to save it before you can run it.',
                  child: SvgPicture.asset(Assets.warn, height: 20),
                ),
              ),
            HSeparators.normal(),
            if (_isHovering)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Tooltip(
                        message: 'Options',
                        waitDuration: const Duration(seconds: 1),
                        child: RectangleButton(
                          width: 30,
                          height: 30,
                          padding: const EdgeInsets.all(2),
                          child: const Icon(Icons.more_vert_rounded, size: 12),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => _ShowWorkflowTileOptions(
                                workflowPath: widget.path,
                                onDelete: widget.onDelete,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    if (widget.template.isSaved)
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Tooltip(
                          message: 'Run',
                          waitDuration: const Duration(seconds: 1),
                          child: RectangleButton(
                            width: 30,
                            height: 30,
                            padding: const EdgeInsets.all(2),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              size: 12,
                              color: kGreenColor,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              showDialog(
                                context: context,
                                builder: (_) => WorkflowRunnerDialog(
                                    workflowPath: widget.path),
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ShowWorkflowTileOptions extends StatelessWidget {
  final String workflowPath;
  final Function() onDelete;

  const _ShowWorkflowTileOptions({
    Key? key,
    required this.workflowPath,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DialogTemplate(
      child: Column(
        children: <Widget>[
          const DialogHeader(title: 'Options'),
          Row(
            children: <Widget>[
              Expanded(
                child: RectangleButton(
                  height: 80,
                  child: Column(
                    children: <Widget>[
                      const Expanded(
                          child: Icon(Icons.preview_rounded, size: 20)),
                      VSeparators.small(),
                      const Text('Preview'),
                    ],
                  ),
                  // TODO: Open preview
                  onPressed: () {},
                ),
              ),
              HSeparators.normal(),
              Expanded(
                child: RectangleButton(
                  height: 80,
                  child: Column(
                    children: <Widget>[
                      const Expanded(child: Icon(Icons.edit_rounded, size: 20)),
                      VSeparators.small(),
                      const Text('Edit'),
                    ],
                  ),
                  onPressed: () {}, // TODO: Open edit view
                ),
              ),
              HSeparators.normal(),
              Expanded(
                child: RectangleButton(
                  height: 80,
                  child: Column(
                    children: <Widget>[
                      const Expanded(child: Icon(Icons.history, size: 20)),
                      VSeparators.small(),
                      const Text('View Logs'),
                    ],
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) =>
                          ShowWorkflowLogHistory(workflowPath: workflowPath),
                    );
                  },
                ),
              ),
            ],
          ),
          VSeparators.normal(),
          Row(
            children: <Widget>[
              Expanded(
                child: RectangleButton(
                  height: 80,
                  child: Column(
                    children: <Widget>[
                      const Expanded(
                        child:
                            Icon(Icons.play_arrow_rounded, color: kGreenColor),
                      ),
                      VSeparators.small(),
                      const Text('Run'),
                    ],
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (_) =>
                          WorkflowRunnerDialog(workflowPath: workflowPath),
                    );
                  },
                ),
              ),
              HSeparators.normal(),
              Expanded(
                child: RectangleButton(
                  height: 80,
                  child: Column(
                    children: <Widget>[
                      const Expanded(
                        child: Icon(Icons.delete_forever,
                            color: AppTheme.errorColor),
                      ),
                      VSeparators.small(),
                      const Text('Delete'),
                    ],
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (_) => ConfirmWorkflowDelete(
                        path: workflowPath,
                        onClose: (bool d) {
                          if (d) {
                            return onDelete();
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
