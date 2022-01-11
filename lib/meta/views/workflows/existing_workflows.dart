// 🎯 Dart imports:
import 'dart:convert';
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:manager/app/constants/constants.dart';
import 'package:manager/components/dialog_templates/dialog_header.dart';
import 'package:manager/core/libraries/services.dart';
import 'package:manager/core/libraries/widgets.dart';
import 'package:manager/meta/views/workflows/models/workflow.dart';
import 'package:manager/meta/views/workflows/startup.dart';

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

          _templates.add(WorkflowTemplate.fromJson(_map));
        }

        Map<String, dynamic> _workflow =
            jsonDecode(await File(e.path).readAsString());

        _templates.add(WorkflowTemplate.fromJson(
            _workflow)); // TODO: this causes an error to be thrown.
      }

      _workflows.addAll(_templates);

      setState(() => _loadingWorkflows = false);
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
                    child: _WorkflowTile(template: _workflows[i]),
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
  final WorkflowTemplate template;
  const _WorkflowTile({
    Key? key,
    required this.template,
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
        child: Text(widget.template.name),
      ),
    );
  }
}
